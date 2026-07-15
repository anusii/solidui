/// Backup and restore of an app's POD data folder as a single portable file.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///
/// Authors: Tony Chen

library;

import 'dart:convert';
import 'dart:math' show Random;
import 'dart:typed_data';

import 'package:archive/archive.dart' show GZipEncoder, GZipDecoder;
import 'package:crypto/crypto.dart' show Hmac, sha256;
import 'package:encrypter_plus/encrypter_plus.dart'
    show AES, AESMode, Encrypted, Encrypter, IV, Key;
import 'package:flutter/foundation.dart' show debugPrint;

import 'package:solidpod/solidpod.dart'
    show
        SecurityKeyVerificationException,
        deleteFile,
        getDataDirPath,
        getDirUrl,
        getResourcesInContainer,
        isFileEncrypted,
        isUserLoggedIn,
        readPod,
        verifyAppSecurityKey,
        writePod;

// Format constants.

/// The magic string that identifies a solidui backup file. Stored (in the
/// clear, once the outer gzip layer is removed) at the top of the header so a
/// wrong or corrupt file can be rejected before any key is requested.

const String kBackupMagic = 'solidui-backup';

/// The backup container format version. Bump this whenever the on-disk layout
/// or the key-derivation / encryption scheme changes in an incompatible way.

const int kBackupFormatVersion = 1;

/// The file extension used for solidui backup files. It is a custom, opaque
/// container (gzip-wrapped JSON with an encrypted payload), so a bespoke
/// extension keeps it from being mistaken for a plain archive or document.

const String kBackupFileExtension = 'solidbak';

// Number of PBKDF2-HMAC-SHA256 iterations used to stretch a security key into
// the AES key that protects the backup payload. High enough to make offline
// guessing expensive, low enough to stay responsive on a phone.

const int _kdfIterations = 150000;

// Length in bytes of the derived AES key (AES-256) and of the random salt.

const int _aesKeyLength = 32;
const int _saltLength = 16;
const int _ivLength = 16;

// Domain-separation labels mixed into the two independent one-way derivations
// so the stored fingerprint can never be used to reconstruct the AES key, and
// vice versa.

const String _kdfInfoAesKey = 'solidui-backup/v1/aes-key';
const String _kdfInfoFingerprint = 'solidui-backup/v1/fingerprint';

// Public models.

/// The metadata read from a backup file's header before any decryption.
///
/// This is what [SolidBackupService.inspect] returns so the UI can decide
/// whether the file even belongs to this application, and later verify a
/// user-supplied security key against [keyFingerprint] — all without touching
/// the (still-encrypted) payload.

class SolidBackupHeader {
  /// Constructor.

  const SolidBackupHeader({
    required this.formatVersion,
    required this.appId,
    required this.appUrl,
    required this.createdAt,
    required this.fileCount,
    required this.saltBase64,
    required this.ivBase64,
    required this.keyFingerprint,
    required this.payloadBase64,
  });

  /// The backup container format version (see [kBackupFormatVersion]).

  final int formatVersion;

  /// The canonical application identifier (the app's POD folder name), used to
  /// verify that a backup was created by the same application even when it
  /// originated on a different POD (which changes [appUrl]).

  final String appId;

  /// The full URL of the source app's data folder at export time. Kept for
  /// display and provenance; cross-POD verification relies on [appId], which is
  /// derived from this URL and is POD-independent.

  final String appUrl;

  /// When the backup was created (ISO-8601, UTC).

  final String createdAt;

  /// The number of data files stored in the backup.

  final int fileCount;

  /// The base64 salt used both to derive the AES key from the original
  /// security key and to compute [keyFingerprint].

  final String saltBase64;

  /// The base64 initialisation vector for the AES-CBC payload.

  final String ivBase64;

  /// A one-way fingerprint of the security key used at export time. It cannot
  /// reconstruct the key but uniquely confirms whether a supplied key matches.

  final String keyFingerprint;

  /// The base64 AES-CBC ciphertext of the (JSON) file bundle.

  final String payloadBase64;
}

/// The outcome of an export operation.

class SolidBackupExport {
  /// Constructor.

  const SolidBackupExport({
    required this.bytes,
    required this.suggestedFileName,
    required this.fileCount,
  });

  /// The complete, self-contained backup file content (gzip-compressed).

  final Uint8List bytes;

  /// A sensible default file name, e.g. `myapp_backup_20260715_1032.solidbak`.

  final String suggestedFileName;

  /// The number of data files captured.

  final int fileCount;
}

/// The outcome of an import operation.

class SolidBackupImport {
  /// Constructor.

  const SolidBackupImport({
    required this.restoredCount,
    required this.removedCount,
    required this.skipped,
  });

  /// The number of files written (re-encrypted) to the destination POD.

  final int restoredCount;

  /// The number of pre-existing data files removed to mirror the backup.

  final int removedCount;

  /// Files that could not be restored, mapped to the reason. Empty on a fully
  /// successful import.

  final Map<String, String> skipped;
}

/// Thrown when an imported backup was created by a different application.

class BackupAppMismatchException implements Exception {
  /// Constructor.

  BackupAppMismatchException(this.backupAppId, this.currentAppId);

  /// The application identifier recorded in the backup.

  final String backupAppId;

  /// The identifier of the application attempting the import.

  final String currentAppId;

  @override
  String toString() => 'BackupAppMismatchException: backup was created by '
      '"$backupAppId" but this application is "$currentAppId"';
}

/// Thrown when a file's content is not a well-formed solidui backup.

class InvalidBackupFileException implements Exception {
  /// Constructor.

  InvalidBackupFileException(this.message);

  /// The error message.

  final String message;

  @override
  String toString() => 'InvalidBackupFileException: $message';
}

// A single backed-up file: its path relative to the app's data folder, the
// decrypted content, and whether it was encrypted at rest on the source POD
// (so it can be written back with the same protection).

class _BackupEntry {
  _BackupEntry({
    required this.path,
    required this.content,
    required this.encrypted,
  });

  factory _BackupEntry.fromJson(Map<String, dynamic> json) => _BackupEntry(
        path: json['path'] as String,
        content: json['content'] as String,
        encrypted: json['encrypted'] as bool? ?? true,
      );

  final String path;
  final String content;
  final bool encrypted;

  Map<String, dynamic> toJson() => {
        'path': path,
        'content': content,
        'encrypted': encrypted,
      };
}

// Service.

/// Exports and imports the current application's POD data folder as a single
/// compressed, encrypted backup file that can be restored onto the same POD or
/// a different one.
///
/// The design follows five rules drawn from the feature specification:
///   1. Everything is written to a single, self-contained file.
///   2. The header records the source application's full URL so an import can
///      confirm the backup belongs to the same application.
///   3. The header stores a one-way fingerprint of the export security key so
///      a user-supplied key can be verified without ever revealing the key.
///   4. The payload stays encrypted and the whole file is compressed.
///   5. Import re-encrypts the data with the destination POD's own security
///      key before uploading, overwriting the data folder's contents.

class SolidBackupService {
  /// Shared singleton instance.

  static final SolidBackupService instance = SolidBackupService._();

  SolidBackupService._();

  // Export.

  /// Read and decrypt every file in the current app's data folder and package
  /// them into an encrypted, compressed backup.
  ///
  /// [securityKey] is the current application's security key. It is verified
  /// against the app's own encryption keys first (so a wrong key fails fast),
  /// then used to derive both the payload's AES key and the stored fingerprint.
  ///
  /// [now] is injected so callers (and tests) control the timestamp used in the
  /// header and suggested file name.
  ///
  /// Throws [SecurityKeyVerificationException] if [securityKey] is incorrect.

  Future<SolidBackupExport> export({
    required String securityKey,
    DateTime? now,
  }) async {
    if (!await isUserLoggedIn()) {
      throw Exception('You must be logged in to create a backup.');
    }

    final appId = await _currentAppId();
    final appRootUrl = await getDirUrl(appId);
    final dataDirPath = await getDataDirPath();
    final dataDirUrl = await getDirUrl(dataDirPath);

    // Verify the security key against this app's stored verification value.
    // This confirms the key is correct before we bind the backup to it, so an
    // export never produces a file that only a wrong key could open.

    await verifyAppSecurityKey(appRootUrl, securityKey);

    // Collect every data file (recursively) and read its decrypted content.

    final relativePaths = <String>[];
    await _collectFiles(dataDirUrl, '', relativePaths);

    final entries = <_BackupEntry>[];
    for (final relativePath in relativePaths) {
      try {
        final content = await readPod(relativePath);
        final encrypted = await isFileEncrypted(relativePath);
        entries.add(
          _BackupEntry(
            path: relativePath,
            content: content,
            encrypted: encrypted,
          ),
        );
      } on Object catch (e) {
        // A single unreadable file should not abort the whole backup; skip it
        // and carry on so the user still captures everything else.

        debugPrint('[SolidBackupService] skipping "$relativePath": $e');
      }
    }

    // Serialise the file bundle, then encrypt it with a key derived from the
    // security key and a fresh random salt.

    final bundleJson = jsonEncode({
      'files': entries.map((e) => e.toJson()).toList(),
    });

    final salt = _randomBytes(_saltLength);
    final iv = IV(_randomBytes(_ivLength));
    final aesKey = Key(_deriveKey(securityKey, salt, _kdfInfoAesKey));
    final payloadBase64 = Encrypter(AES(aesKey, mode: AESMode.cbc))
        .encrypt(bundleJson, iv: iv)
        .base64;

    final createdAt = (now ?? DateTime.now()).toUtc();

    final header = {
      'magic': kBackupMagic,
      'formatVersion': kBackupFormatVersion,
      'appId': appId,
      'appUrl': dataDirUrl,
      'createdAt': createdAt.toIso8601String(),
      'fileCount': entries.length,
      'kdf': {
        'algorithm': 'PBKDF2-HMAC-SHA256',
        'iterations': _kdfIterations,
        'salt': base64.encode(salt),
      },
      'cipher': {
        'algorithm': 'AES-256-CBC',
        'iv': iv.base64,
      },
      'keyFingerprint': _fingerprint(securityKey, salt),
      'payload': payloadBase64,
    };

    // Compress the whole document. Import therefore decompresses first (step 1)
    // and only then decrypts the payload (step 2).

    final compressed = Uint8List.fromList(
      const GZipEncoder().encodeBytes(utf8.encode(jsonEncode(header))),
    );

    return SolidBackupExport(
      bytes: compressed,
      suggestedFileName:
          '${appId}_backup_${_timestamp(createdAt.toLocal())}.$kBackupFileExtension',
      fileCount: entries.length,
    );
  }

  // Inspect.

  /// Decompress and parse a backup file's header without decrypting anything.
  ///
  /// Throws [InvalidBackupFileException] if the bytes are not a solidui backup
  /// or use an unsupported format version.

  SolidBackupHeader inspect(Uint8List bytes) {
    Map<String, dynamic> header;
    try {
      final decompressed = const GZipDecoder().decodeBytes(bytes);
      header = jsonDecode(utf8.decode(decompressed)) as Map<String, dynamic>;
    } on Object catch (e) {
      throw InvalidBackupFileException(
        'The selected file is not a valid solidui backup ($e).',
      );
    }

    if (header['magic'] != kBackupMagic) {
      throw InvalidBackupFileException(
        'The selected file is not a solidui backup.',
      );
    }

    final formatVersion = header['formatVersion'] as int? ?? -1;
    if (formatVersion != kBackupFormatVersion) {
      throw InvalidBackupFileException(
        'Unsupported backup format version: $formatVersion. This application '
        'supports version $kBackupFormatVersion.',
      );
    }

    final kdf = header['kdf'] as Map<String, dynamic>?;
    final cipher = header['cipher'] as Map<String, dynamic>?;
    if (kdf == null || cipher == null) {
      throw InvalidBackupFileException('The backup header is incomplete.');
    }

    return SolidBackupHeader(
      formatVersion: formatVersion,
      appId: header['appId'] as String? ?? '',
      appUrl: header['appUrl'] as String? ?? '',
      createdAt: header['createdAt'] as String? ?? '',
      fileCount: header['fileCount'] as int? ?? 0,
      saltBase64: kdf['salt'] as String? ?? '',
      ivBase64: cipher['iv'] as String? ?? '',
      keyFingerprint: header['keyFingerprint'] as String? ?? '',
      payloadBase64: header['payload'] as String? ?? '',
    );
  }

  /// Whether a backup with [header] was created by the application currently
  /// running, comparing the POD-independent [SolidBackupHeader.appId].

  Future<bool> isSameApplication(SolidBackupHeader header) async {
    final currentAppId = await _currentAppId();
    return header.appId.isNotEmpty && header.appId == currentAppId;
  }

  /// Whether [securityKey] matches the key used to create the backup, checked
  /// against the one-way [SolidBackupHeader.keyFingerprint].

  bool verifyOriginalKey(SolidBackupHeader header, String securityKey) {
    final salt = base64.decode(header.saltBase64);
    return _constantTimeEquals(
      header.keyFingerprint,
      _fingerprint(securityKey, salt),
    );
  }

  // Import.

  /// Restore a backup onto the current POD.
  ///
  /// Steps, mirroring the specification's import workflow:
  ///   1. The file is already decompressed by [inspect] to obtain [header].
  ///   2. Decrypt the payload with [originalKey] (the key used at export time).
  ///   3. Re-encrypt each file with [currentKey] (the destination POD's key).
  ///   4. Upload the re-encrypted files, overwriting the data folder.
  ///
  /// [currentKey] is verified against the destination app's own encryption
  /// keys; [originalKey] is verified against the backup's fingerprint. When
  /// [clearExisting] is true (the default) any pre-existing data files not
  /// present in the backup are removed so the folder mirrors the backup.
  ///
  /// Throws [BackupAppMismatchException] if the backup belongs to another
  /// application, and [SecurityKeyVerificationException] if either key fails
  /// verification.

  Future<SolidBackupImport> import({
    required SolidBackupHeader header,
    required String originalKey,
    required String currentKey,
    bool clearExisting = true,
  }) async {
    if (!await isUserLoggedIn()) {
      throw Exception('You must be logged in to restore a backup.');
    }

    // Reject a backup created by a different application outright.

    final currentAppId = await _currentAppId();
    if (header.appId != currentAppId) {
      throw BackupAppMismatchException(header.appId, currentAppId);
    }

    // Verify the original key against the fingerprint the backup carries.

    if (!verifyOriginalKey(header, originalKey)) {
      throw SecurityKeyVerificationException(
        'The original security key does not match this backup.',
      );
    }

    // Verify the current (destination) key against the live app's keys. This
    // guarantees the writes below re-encrypt under a key the user actually
    // controls, so the restored data is decryptable afterwards.

    final appRootUrl = await getDirUrl(currentAppId);
    await verifyAppSecurityKey(appRootUrl, currentKey);

    // Decrypt the payload with the original key.

    final salt = base64.decode(header.saltBase64);
    final aesKey = Key(_deriveKey(originalKey, salt, _kdfInfoAesKey));
    final iv = IV.fromBase64(header.ivBase64);

    String bundleJson;
    try {
      bundleJson = Encrypter(AES(aesKey, mode: AESMode.cbc))
          .decrypt(Encrypted.fromBase64(header.payloadBase64), iv: iv);
    } on Object catch (e) {
      throw InvalidBackupFileException(
        'Failed to decrypt the backup payload ($e).',
      );
    }

    final bundle = jsonDecode(bundleJson) as Map<String, dynamic>;
    final entries = (bundle['files'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(_BackupEntry.fromJson)
        .toList();

    final restorePaths = entries.map((e) => e.path).toSet();

    // (Overwrite) Remove pre-existing data files that are not part of the
    // backup so the folder ends up mirroring the backup exactly.

    var removedCount = 0;
    if (clearExisting) {
      final dataDirUrl = await getDirUrl(await getDataDirPath());
      final existing = <String>[];
      await _collectFiles(dataDirUrl, '', existing);
      for (final relativePath in existing) {
        if (restorePaths.contains(relativePath)) continue;
        try {
          // getDirUrl() returns the data folder URL with a trailing slash, so
          // appending the data-relative path yields the file's absolute URL
          // (getFileUrl() would instead resolve against the POD root).

          await deleteFile(fileUrl: '$dataDirUrl$relativePath');
          removedCount++;
        } on Object catch (e) {
          debugPrint(
            '[SolidBackupService] could not remove "$relativePath": $e',
          );
        }
      }
    }

    // Re-encrypt with the destination key (writePod uses the live
    // KeyManager master key) and upload, overwriting existing files.

    final skipped = <String, String>{};
    var restoredCount = 0;
    for (final entry in entries) {
      try {
        await writePod(
          entry.path,
          entry.content,
          encrypted: entry.encrypted,
          overwrite: true,
        );
        restoredCount++;
      } on Object catch (e) {
        skipped[entry.path] = e.toString();
        debugPrint('[SolidBackupService] failed to restore "${entry.path}": $e');
      }
    }

    return SolidBackupImport(
      restoredCount: restoredCount,
      removedCount: removedCount,
      skipped: skipped,
    );
  }

  // Internal helpers.

  // The canonical app identifier is the first segment of the data directory
  // path. It is the same on every POD, which is what lets an import tell
  // whether two backups came from the same app.

  Future<String> _currentAppId() async {
    final dataDirPath = await getDataDirPath();
    final appId = dataDirPath.split('/').first;
    if (appId.isEmpty) {
      throw Exception('Unable to determine the current application name.');
    }
    return appId;
  }

  // Walk a container recursively, appending the data-relative path of every
  // file found. ACL and metadata sidecars are skipped: solidpod recreates them
  // when writePod restores each file.

  Future<void> _collectFiles(
    String dirUrl,
    String relativePrefix,
    List<String> out,
  ) async {
    final normalisedDirUrl = dirUrl.endsWith('/') ? dirUrl : '$dirUrl/';
    final listing = await getResourcesInContainer(normalisedDirUrl);

    for (final file in listing.files) {
      if (file.endsWith('.acl') || file.endsWith('.meta')) continue;
      out.add('$relativePrefix$file');
    }

    for (final subDir in listing.subDirs) {
      await _collectFiles(
        '$normalisedDirUrl$subDir/',
        '$relativePrefix$subDir/',
        out,
      );
    }
  }

  // Cryptographically secure random bytes.

  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  // Derive a 32-byte AES key from a security key and salt using PBKDF2-HMAC-
  // SHA256, mixing in [info] so different call sites (key vs fingerprint) never
  // produce the same bytes.

  Uint8List _deriveKey(String securityKey, List<int> salt, String info) {
    final password = <int>[...utf8.encode(info), ...utf8.encode(securityKey)];
    return _pbkdf2(
      password: password,
      salt: salt,
      iterations: _kdfIterations,
      keyLength: _aesKeyLength,
    );
  }

  // A one-way fingerprint of the security key: a second, domain-separated
  // PBKDF2 derivation. It is expensive to brute-force and cannot be inverted to
  // recover the key, yet uniquely confirms a supplied key.

  String _fingerprint(String securityKey, List<int> salt) {
    final password = <int>[
      ...utf8.encode(_kdfInfoFingerprint),
      ...utf8.encode(securityKey),
    ];
    final digest = _pbkdf2(
      password: password,
      salt: salt,
      iterations: _kdfIterations,
      keyLength: 32,
    );
    return base64.encode(digest);
  }

  // A self-contained PBKDF2-HMAC-SHA256 implementation (RFC 2898). Avoids an
  // extra dependency: the `crypto` package already provides the HMAC-SHA256
  // primitive it is built on.

  Uint8List _pbkdf2({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int keyLength,
  }) {
    final hmac = Hmac(sha256, password);
    const blockSize = 32; // SHA-256 output length in bytes.
    final blockCount = (keyLength + blockSize - 1) ~/ blockSize;
    final derived = Uint8List(blockCount * blockSize);

    for (var block = 1; block <= blockCount; block++) {
      // U1 = HMAC(password, salt || INT_32_BE(block)).

      final blockIndex = Uint8List(4)
        ..[0] = (block >> 24) & 0xff
        ..[1] = (block >> 16) & 0xff
        ..[2] = (block >> 8) & 0xff
        ..[3] = block & 0xff;

      var u = hmac.convert([...salt, ...blockIndex]).bytes;
      final t = List<int>.from(u);

      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < blockSize; j++) {
          t[j] ^= u[j];
        }
      }

      derived.setRange((block - 1) * blockSize, block * blockSize, t);
    }

    return Uint8List.sublistView(derived, 0, keyLength);
  }

  // A filename-friendly timestamp, YYYYMMDD_HHMM, from a local [DateTime].

  String _timestamp(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}${two(t.month)}${two(t.day)}_${two(t.hour)}${two(t.minute)}';
  }

  // Constant-time string comparison so fingerprint verification does not leak
  // a matching prefix via timing.

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
