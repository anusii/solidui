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

import 'package:solidpod/solidpod.dart' show KeyManager;

/// Helper class for Security Key operations.

class SecurityKeyOperations {
  /// Checks if a security key exists and is valid.

  static Future<bool> checkKeyStatus() async {
    try {
      final hasKey = await KeyManager.hasSecurityKey();
      debugPrint(
          'Security key status check: ${hasKey ? "exists" : "not found"}');
      return hasKey;
    } catch (e) {
      debugPrint('Error checking key status: $e');
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
      // Check if verification key exists in POD to determine the scenario.

      String verificationKey = '';
      bool hasVerificationKey = false;

      try {
        verificationKey = await KeyManager.getVerificationKey();
        hasVerificationKey = verificationKey.isNotEmpty;
      } catch (e) {
        // If getting verification key fails, it means no key file exists yet.

        debugPrint('No verification key found, will initialise new keys: $e');
        hasVerificationKey = false;
      }

      if (hasVerificationKey) {
        // Scenario: User has key file in POD but forgot the key locally.
        // Use setSecurityKey() to load the existing key into memory.

        await KeyManager.setSecurityKey(key);
        debugPrint('Security key loaded successfully.');
      } else {
        // Scenario: First time setting up security key (no key file in POD).
        // Use initPodKeys() to create new key files and save to POD.

        await KeyManager.initPodKeys(key);
        debugPrint('Security key initialised successfully.');
      }

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
      } else if (errorStr.contains('verify') ||
          errorStr.contains('unable to verify')) {
        errorMessage = 'Incorrect security key. Please check and try again.';
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
