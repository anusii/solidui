/// Security Key Manager Helper Functions.
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
/// Authors: Ashley Tang, Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart'
    show KeyManager, SolidFunctionCallStatus, getEncKeyPath, writePod;

/// Helper class for Security Key Manager operations.

class SolidSecurityKeyManagerHelpers {
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
                'Key found in POD but not in memory, attempting to load...');
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

        // As fallback, check memory status.

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

  /// Handles showing key input dialog for existing keys.

  static Future<void> handleExistingKeyChange(
    Future<void> Function() changeKeyFunction,
    void Function(String message) showErrorFunction,
  ) async {
    try {
      await changeKeyFunction();
    } catch (e) {
      showErrorFunction(e.toString());
    }
  }

  /// Gets the version to display.

  static String getVersionToDisplay() {
    return '0.0.0+0';
  }

  /// Returns decoration for input fields.

  static InputDecoration getInputDecoration(String label, ThemeData theme) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: theme.colorScheme.outline),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  /// Defines consistent button styles.

  static ButtonStyle getButtonStyle(
    ThemeData theme, {
    bool isDestructive = false,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor:
          isDestructive ? theme.colorScheme.error : theme.colorScheme.surface,
      foregroundColor:
          isDestructive ? theme.colorScheme.onError : theme.colorScheme.primary,
      side: BorderSide(
        color:
            isDestructive ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  /// Shows an error dialog with detailed message.

  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shows a snack bar with an error message.

  static void showErrorSnackBar(BuildContext context, String message) {
    showErrorDialog(context, 'Error', message);
  }

  /// Shows success snack bar.

  static void showSuccessSnackBar(BuildContext context, String message) {
    showErrorDialog(context, 'Success', message);
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

        // Write the key directly to POD without encryption.

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

      // Verify the key was actually set by checking the file.

      await Future.delayed(const Duration(milliseconds: 500));

      bool keySetSuccessfully = false;
      try {
        final fileContent = await readFunction(filePath);

        keySetSuccessfully = fileContent.isNotEmpty &&
            fileContent != SolidFunctionCallStatus.notLoggedIn.toString() &&
            fileContent != SolidFunctionCallStatus.fail.toString();

        if (keySetSuccessfully) {
          debugPrint('Security key verified in POD storage at: $filePath');
        }
      } catch (verifyError) {
        debugPrint('Key verification failed: $verifyError');
        keySetSuccessfully = false;
      }

      if (keySetSuccessfully) {
        // Success - show success message.

        showSuccessFunction('Security key set and verified successfully');
        return true;
      } else {
        // Key was set in memory but file verification failed.

        showErrorFunction('Key set but not verified in your POD storage.');
        return true; // Still update status as key is at least in memory
      }
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

  static Future<void> showNewKeyDialog(
    BuildContext context,
    TextEditingController keyController,
    TextEditingController confirmKeyController,
    Future<void> Function() onKeyChanged,
    Future<bool> Function(String key, String confirmKey)
        handleSubmissionFunction,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Set Security Key',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: getInputDecoration('Enter Security Key', ThemeData()),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmKeyController,
              decoration: getInputDecoration(
                'Confirm Security Key',
                ThemeData(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (keyController.text != confirmKeyController.text) {
                showErrorSnackBar(context, 'Keys do not match');
                return;
              }
              if (keyController.text.length < 6) {
                showErrorSnackBar(context, 'Key must be at least 6 characters');
                return;
              }
              Navigator.of(context).pop();
              final success = await handleSubmissionFunction(
                keyController.text,
                confirmKeyController.text,
              );
              if (success) {
                await onKeyChanged();
              }
            },
            style: getButtonStyle(ThemeData()),
            child: const Text('Set Key'),
          ),
        ],
      ),
    );
  }
}
