/// Security Key Operations.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
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

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:solidpod/solidpod.dart' show KeyManager;

/// The key used by solidpod to store the security key in secure storage.

const String _securityKeyStorageKey = '_solid_security_key';

/// Helper class for Security Key operations.

class SecurityKeyOperations {
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  /// Checks if a security key is cached locally and valid.
  ///
  /// This method performs a detailed check with three possible outcomes:
  /// 1. Key found in local cache and verified successfully
  /// 2. No key found in local cache
  /// 3. Key found in local cache but verification failed (cache cleared)
  ///
  /// Returns true only if the key is cached locally AND verified successfully.

  static Future<bool> checkKeyStatus() async {
    try {
      // First, check if there's a key in local secure storage.

      final cachedKey = await _secureStorage.read(key: _securityKeyStorageKey);
      final hadCachedKey = cachedKey != null && cachedKey.isNotEmpty;

      if (!hadCachedKey) {
        // Case 2: No key found in local secure storage.

        debugPrint(
          'Security key status: No cached key found in local secure storage',
        );
        return false;
      }

      // Key exists in local storage, now verify it against POD's verification
      // key using KeyManager.hasSecurityKey().

      debugPrint(
        'Security key status: Found cached key in local secure storage, '
        'verifying against POD...',
      );

      final isValid = await KeyManager.hasSecurityKey();

      if (isValid) {
        // Case 1: Key found and verified successfully.

        debugPrint(
          'Security key status: Cached key verified successfully - '
          'Cached Locally',
        );
        return true;
      } else {
        // Case 3: Key was found but verification failed.
        // KeyManager.hasSecurityKey() has already called forgetSecurityKey()
        // to clear the invalid cached key.

        debugPrint(
          'Security key status: Cached key verification FAILED - '
          'local cache has been cleared automatically',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error checking security key status: $e');
      return false;
    }
  }

  /// Handles key submission validation and setting.

  static Future<bool> handleKeySubmission(
    String key,
    String confirmKey,
    void Function(String message) showErrorFunction,
  ) async {
    // Validate input.

    if (key.isEmpty || confirmKey.isEmpty) {
      showErrorFunction('Please enter both keys');
      return false;
    }

    if (key != confirmKey) {
      showErrorFunction('Keys do not match');
      return false;
    }

    try {
      // Use initPodKeys() to re-initialise the security key.

      // await KeyManager.initPodKeys(key);
      // debugPrint('Security key successfully initialised.');
      return true;
    } catch (e) {
      debugPrint('Error setting security key: $e');
      String errorMessage = 'Failed to set security key.';

      final errorStr = e.toString().toLowerCase();

      if (errorStr.contains('not logged in') ||
          errorStr.contains('authentication')) {
        errorMessage = 'You must be logged in to set a security key.';
      } else if (errorStr.contains('network') ||
          errorStr.contains('connection')) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      } else if (errorStr.contains('permission')) {
        errorMessage =
            'Permission denied. Please check your POD access rights.';
      } else {
        // Include part of the actual error for debugging.

        errorMessage =
            'Failed to set security key: ${e.toString().split('\n').first}';
      }

      try {
        showErrorFunction(errorMessage);
      } catch (displayError) {
        debugPrint('Error displaying error message: $displayError');
      }

      return false;
    }
  }
}
