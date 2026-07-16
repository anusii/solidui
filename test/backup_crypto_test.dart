/// Tests for the cryptographic core used by the backup service.
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
import 'dart:typed_data';

import 'package:archive/archive.dart' show GZipDecoder, GZipEncoder;
import 'package:crypto/crypto.dart' show Hmac, sha256;
import 'package:encrypter_plus/encrypter_plus.dart'
    show AES, AESMode, Encrypted, Encrypter, IV, Key;
import 'package:flutter_test/flutter_test.dart';

// Run the test file:
//
// ```bash
// cd solidui
// flutter test test/backup_crypto_test.dart
// ```
//
// Other useful options:
//
// ```bash
// # Show detailed output for each test
// flutter test test/backup_crypto_test.dart --reporter expanded
//
// # Run only tests whose names match a specific keyword
// flutter test test/backup_crypto_test.dart --name "AES"
//
// # Generate a code coverage report (output: coverage/lcov.info)
// flutter test --coverage
// ```

// A copy of the service's PBKDF2 so the test can reproduce the exact bytes.

Uint8List pbkdf2({
  required List<int> password,
  required List<int> salt,
  required int iterations,
  required int keyLength,
}) {
  final hmac = Hmac(sha256, password);
  const blockSize = 32;
  final blockCount = (keyLength + blockSize - 1) ~/ blockSize;
  final derived = Uint8List(blockCount * blockSize);

  for (var block = 1; block <= blockCount; block++) {
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

void main() {
  const salt = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];

  test('PBKDF2 is deterministic and produces the requested length', () {
    final a = pbkdf2(
      password: utf8.encode('secret-key'),
      salt: salt,
      iterations: 1000,
      keyLength: 32,
    );
    final b = pbkdf2(
      password: utf8.encode('secret-key'),
      salt: salt,
      iterations: 1000,
      keyLength: 32,
    );

    expect(a.length, 32);
    expect(a, equals(b));
  });

  test('PBKDF2 with domain separation yields distinct outputs', () {
    final aesKey = pbkdf2(
      password: [...utf8.encode('aes'), ...utf8.encode('key')],
      salt: salt,
      iterations: 1000,
      keyLength: 32,
    );
    final fingerprint = pbkdf2(
      password: [...utf8.encode('fingerprint'), ...utf8.encode('key')],
      salt: salt,
      iterations: 1000,
      keyLength: 32,
    );

    expect(aesKey, isNot(equals(fingerprint)));
  });

  test('AES-256-CBC round-trips the payload', () {
    final key = Key(
      pbkdf2(
        password: utf8.encode('the-key'),
        salt: salt,
        iterations: 1000,
        keyLength: 32,
      ),
    );
    final iv = IV(Uint8List.fromList(List<int>.filled(16, 7)));
    final plaintext = jsonEncode({
      'files': [
        {'path': 'notes/a.ttl', 'content': 'hello world', 'encrypted': true},
      ],
    });

    final cipherText = Encrypter(AES(key, mode: AESMode.cbc))
        .encrypt(plaintext, iv: iv)
        .base64;
    final recovered = Encrypter(AES(key, mode: AESMode.cbc))
        .decrypt(Encrypted.fromBase64(cipherText), iv: iv);

    expect(recovered, equals(plaintext));
  });

  test('Wrong key fails to recover the plaintext', () {
    final iv = IV(Uint8List.fromList(List<int>.filled(16, 7)));
    final right = Key(
      pbkdf2(
        password: utf8.encode('right'),
        salt: salt,
        iterations: 1000,
        keyLength: 32,
      ),
    );
    final wrong = Key(
      pbkdf2(
        password: utf8.encode('wrong'),
        salt: salt,
        iterations: 1000,
        keyLength: 32,
      ),
    );
    const plaintext = 'sensitive backup payload';

    final cipherText = Encrypter(AES(right, mode: AESMode.cbc))
        .encrypt(plaintext, iv: iv)
        .base64;

    // A wrong key either throws (padding failure) or returns garbage; either
    // way it must not reproduce the plaintext.

    String? recovered;
    try {
      recovered = Encrypter(AES(wrong, mode: AESMode.cbc))
          .decrypt(Encrypted.fromBase64(cipherText), iv: iv);
    } on Object {
      recovered = null;
    }
    expect(recovered, isNot(equals(plaintext)));
  });

  test('gzip round-trips the header document', () {
    final header = jsonEncode({
      'magic': 'solidui-backup',
      'formatVersion': 1,
      'payload': base64.encode(List<int>.generate(256, (i) => i % 256)),
    });

    final compressed = const GZipEncoder().encodeBytes(utf8.encode(header));
    final decompressed =
        utf8.decode(const GZipDecoder().decodeBytes(compressed));

    expect(decompressed, equals(header));
  });
}
