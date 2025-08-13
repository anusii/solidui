/// Service for managing security keys in Solid applications.
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
import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart' show KeyManager;

/// Service for managing security keys used for POD encryption in Solid
/// applications.
///
/// This service provides a centralised way to check and manage security key status
/// across Solid applications. It extends ChangeNotifier to allow UI components
/// to listen for security key status changes.

class SolidSecurityKeyService extends ChangeNotifier {
  SolidSecurityKeyService();

  // Track the last known key status to prevent unnecessary notifications.

  bool? _lastKnownKeyStatus;

  /// Checks if a security key is currently saved.
  ///
  /// Returns true if a security key exists in memory, false otherwise.
  /// This method handles exceptions gracefully and logs errors for debugging.
  
  Future<bool> isKeySaved() async {
    try {
      return await KeyManager.hasSecurityKey();
    } catch (e) {
      debugPrint('Error checking security key status: $e');
      return false;
    }
  }

  /// Fetches the security key status and optionally triggers a callback.
  ///
  /// This function checks if an encryption key is available for the user.
  /// Instead of directly triggering a key prompt, it simply checks if the key exists.
  /// If a key exists, it triggers a callback to update the UI.
  ///
  /// Parameters:
  /// - [onKeyStatusChanged]: Optional callback function that receives the key status
  ///
  /// Returns true if a security key exists, false otherwise.
  
  Future<bool> fetchKeySavedStatus([Function(bool)? onKeyStatusChanged]) async {
    try {
      // Check if the security key exists in memory.

      final hasKey = await KeyManager.hasSecurityKey();
      
      // Call the callback if provided.
      
      if (onKeyStatusChanged != null) {
        onKeyStatusChanged(hasKey);
      }
      
      // Only notify listeners if the status has actually changed.

      if (_lastKnownKeyStatus != hasKey) {
        _lastKnownKeyStatus = hasKey;
        notifyListeners();
      }
      
      return hasKey;
    } catch (e) {
      debugPrint('Error fetching security key status: $e');
      
      // On error, assume no key and notify if needed.

      if (_lastKnownKeyStatus != false) {
        _lastKnownKeyStatus = false;
        if (onKeyStatusChanged != null) {
          onKeyStatusChanged(false);
        }
        notifyListeners();
      }
      
      return false;
    }
  }

  /// Forces a refresh of the security key status.
  ///
  /// This method triggers a fresh check of the security key status
  /// and notifies all listeners of any changes.
  
  Future<void> refreshKeyStatus() async {
    // Reset the last known status to force notification.

    _lastKnownKeyStatus = null;
    await fetchKeySavedStatus();
  }

  /// Checks if a security key is needed for the current user.
  ///
  /// This method not only checks if a key exists but also determines
  /// if one is actually needed based on the verification key.
  
  Future<bool> isSecurityKeyNeeded() async {
    try {
      // If key already exists, it's not needed to be set.

      final hasKey = await KeyManager.hasSecurityKey();
      if (hasKey) return false;

      // Check if a verification key exists (indicating encryption is used).

      final verificationKey = await KeyManager.getVerificationKey();
      return verificationKey.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if security key is needed: $e');
      return false;
    }
  }

  /// Validates that a security key is properly set up.
  ///
  /// This method performs a comprehensive validation by checking
  /// the KeyManager state. File validation is handled by UI components.
  
  Future<bool> validateSecurityKeySetup() async {
    try {
      return await KeyManager.hasSecurityKey();
    } catch (e) {
      debugPrint('Error validating security key setup: $e');
      return false;
    }
  }
}
