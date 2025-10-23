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

import 'package:solidpod/solidpod.dart'
    show KeyManager, SolidFunctionCallStatus, getEncKeyPath, writePod;

/// Helper class for Security Key operations.

class SecurityKeyOperations {
  /// Checks if a security key exists and is valid.

  static Future<bool> checkKeyStatus(
    Future<String> Function() getKeyPathFunction,
    Future<String> Function(String filePath) readFunction,
  ) async {
    try {
      // Try to check if the key file exists in POD.

      try {
        final filePath = await getKeyPathFunction();
        final fileContent = await readFunction(filePath);

        // Check if we got valid content from POD.

        final hasValidKeyFile = fileContent.isNotEmpty &&
            fileContent != SolidFunctionCallStatus.notLoggedIn.toString() &&
            fileContent != SolidFunctionCallStatus.fail.toString();

        if (hasValidKeyFile) {
          // Key file exists in POD.

          debugPrint('Security key file found in POD at: $filePath');

          // Check if it's also in memory.

          final hasKeyInMemory = await KeyManager.hasSecurityKey();

          if (!hasKeyInMemory) {
            // File exists but not in memory - try to load it into memory.

            debugPrint(
              'Key found in POD but not in memory, attempting to load...',
            );
            try {
              // Try to set the key in memory from the file content.

              await KeyManager.setSecurityKey(fileContent);
              debugPrint('Successfully loaded key from POD into memory');
            } catch (e) {
              debugPrint('Could not load key into memory: $e');
            }
          }

          return true;
        } else {
          // No valid key file in POD.

          debugPrint('No valid security key file found in POD');

          // Clear memory if it thinks there's a key.

          final hasKeyInMemory = await KeyManager.hasSecurityKey();
          if (hasKeyInMemory) {
            debugPrint('Clearing stale key from memory');
            await KeyManager.forgetSecurityKey();
          }

          return false;
        }
      } catch (e) {
        // File check failed - could be network issue or not logged in.

        debugPrint('Key file verification failed: $e');

        // Check if this is a "not found" error (file doesn't exist).

        final errorStr = e.toString().toLowerCase();
        final isFileNotFound = errorStr.contains('404') ||
            errorStr.contains('notfound') ||
            errorStr.contains('not found');

        if (isFileNotFound) {
          // File definitely doesn't exist - ensure memory is also cleared.

          debugPrint('Key file not found in POD, clearing memory state');

          try {
            final hasKeyInMemory = await KeyManager.hasSecurityKey();
            if (hasKeyInMemory) {
              await KeyManager.forgetSecurityKey();
              debugPrint('Cleared stale key from memory');
            }
          } catch (memError) {
            debugPrint('Error clearing memory: $memError');
          }

          return false;
        }

        // For other errors (network, auth), check memory as fallback.

        try {
          final hasKeyInMemory = await KeyManager.hasSecurityKey();
          if (hasKeyInMemory) {
            debugPrint('Key file check failed but key exists in memory');
            return true;
          }
        } catch (memError) {
          debugPrint('Memory check also failed: $memError');
        }

        return false;
      }
    } catch (e) {
      debugPrint('Error checking key status: $e');
      return false;
    }
  }

  /// Handles key submission validation and setting.

  static Future<bool> handleKeySubmission(
    String key,
    String confirmKey,
    Future<String> Function(String filePath) readFunction,
    void Function(String message) showErrorFunction,
    void Function(String message) showSuccessFunction, {
    BuildContext? context,
    Widget? appWidget,
  }) async {
    if (key.isEmpty || confirmKey.isEmpty) {
      showErrorFunction('Please enter both keys');
      return false;
    }

    if (key != confirmKey) {
      showErrorFunction('Keys do not match');
      return false;
    }

    try {
      // Get the encryption key path where it should be stored in the POD.

      final filePath = await getEncKeyPath();
      debugPrint('Security key will be stored at POD path: $filePath');

      // If context and appWidget are provided, write the key directly to POD
      // first.

      if (context != null && appWidget != null) {
        if (!context.mounted) {
          showErrorFunction('Context not available for POD write');
          return false;
        }

        // Write the key directly to POD with encryption.

        final result = await writePod(
          filePath,
          key,
          context,
          appWidget,
          encrypted: true,
        );

        if (result != SolidFunctionCallStatus.success) {
          throw Exception('Failed to write security key to POD');
        }

        debugPrint('Security key successfully written to POD at: $filePath');

        // Now initialise the KeyManager with the key to generate verification keys.
        // This will set up the key in memory and create verification data.

        try {
          await KeyManager.initPodKeys(key);
          debugPrint('KeyManager initialised with the security key');
        } catch (e) {
          debugPrint('KeyManager initialisation warning (may be ok): $e');
        }
      } else {
        // Fallback to original method if context not provided.

        debugPrint('Using legacy key storage method');
        await KeyManager.initPodKeys(key);
      }

      // Key is now set in memory and written to POD.

      debugPrint('Security key successfully set in memory and written to POD');
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
      } else if (errorStr.contains('verify')) {
        errorMessage = 'Key verification issue. The key was written to POD but '
            'verification failed. Please try logging out and back in.';
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
