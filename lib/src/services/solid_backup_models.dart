/// Data models for the backup service (see `solid_backup_service.dart`).
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

part of 'solid_backup_service.dart';

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
//
// A "large" entry is one of solidpod's chunked large files (see _PodFile).
// Its bytes are arbitrary binary, so the content is base64 rather than the
// file's text.

class _BackupEntry {
  _BackupEntry({
    required this.path,
    required this.content,
    required this.encrypted,
    this.large = false,
  });

  factory _BackupEntry.fromJson(Map<String, dynamic> json) => _BackupEntry(
        path: json['path'] as String,
        content: json['content'] as String,
        encrypted: json['encrypted'] as bool? ?? true,
        large: json['large'] as bool? ?? false,
      );

  final String path;
  final String content;
  final bool encrypted;
  final bool large;

  Map<String, dynamic> toJson() => {
        'path': path,
        'content': content,
        'encrypted': encrypted,
        if (large) 'large': true,
      };
}

// A file discovered in the data folder.
//
// solidpod stores a large file (written with writeLargeFile()) as a hidden
// "<name>.chunks" directory of encrypted binary chunks plus a "<name>.ttl"
// metadata file. Those parts cannot be read or restored individually — the
// chunks are not text, and their key is bound to the source POD — so the walk
// reports the large file itself and the backup goes through solidpod's
// large-file API instead.

class _PodFile {
  _PodFile(this.path, {required this.large});

  final String path;
  final bool large;
}
