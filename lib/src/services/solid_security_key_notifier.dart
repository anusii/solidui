/// Security Key Status Notifier.
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

import 'package:flutter/foundation.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:solidpod/solidpod.dart' show KeyManager;

/// The key used by solidpod to store the security key in secure storage.

const String _securityKeyStorageKey = '_solid_security_key';

/// Global notifier for security key status.

class SecurityKeyNotifier extends ChangeNotifier {
  bool _isKeySaved = false;
  bool _isChecking = false;

  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  /// Current security key status.

  bool get isKeySaved => _isKeySaved;

  /// Whether a status check is in progress.

  bool get isChecking => _isChecking;

  /// Updates the security key status and notifies listeners.

  void updateStatus(bool isKeySaved) {
    if (_isKeySaved != isKeySaved) {
      _isKeySaved = isKeySaved;
      notifyListeners();
    }
  }

  /// Refreshes the security key status.

  Future<bool> refreshStatus() async {
    if (_isChecking) {
      return _isKeySaved;
    }

    _isChecking = true;
    notifyListeners();

    try {
      // First check if there's a key in local secure storage.

      final cachedKey = await _secureStorage.read(key: _securityKeyStorageKey);
      final hadCachedKey = cachedKey != null && cachedKey.isNotEmpty;

      if (!hadCachedKey) {
        // No key in local storage.

        debugPrint(
          'SecurityKeyNotifier: No cached key found in local secure storage',
        );

        if (_isKeySaved) {
          _isKeySaved = false;
          _isChecking = false;
          notifyListeners();
        } else {
          _isChecking = false;
          notifyListeners();
        }

        return false;
      }

      // Key exists, verify it against POD.

      debugPrint(
        'SecurityKeyNotifier: Found cached key, verifying against POD...',
      );

      final isValid = await KeyManager.hasSecurityKey();

      if (isValid) {
        debugPrint(
          'SecurityKeyNotifier: Cached key verified successfully - '
          'Cached Locally',
        );

        if (!_isKeySaved) {
          _isKeySaved = true;
          _isChecking = false;
          notifyListeners();
        } else {
          _isChecking = false;
          notifyListeners();
        }

        return true;
      } else {
        // Verification failed - KeyManager has cleared the cache.

        debugPrint(
          'SecurityKeyNotifier: Cached key verification FAILED - '
          'local cache has been cleared automatically',
        );

        if (_isKeySaved) {
          _isKeySaved = false;
          _isChecking = false;
          notifyListeners();
        } else {
          _isChecking = false;
          notifyListeners();
        }

        return false;
      }
    } catch (e) {
      debugPrint('SecurityKeyNotifier: Error refreshing status: $e');
      _isChecking = false;
      notifyListeners();
      return _isKeySaved;
    }
  }

  /// Resets the notifier to initial state.

  void reset() {
    _isKeySaved = false;
    _isChecking = false;
    notifyListeners();
  }
}

/// Global instance of the security key notifier.

final securityKeyNotifier = SecurityKeyNotifier();
