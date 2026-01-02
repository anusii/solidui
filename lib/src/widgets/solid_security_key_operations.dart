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
        'Security key status check: ${hasKey ? "exists" : "not found"}',
      );
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
      // Use initPodKeys() to re-initialise the security key.
      await KeyManager.initPodKeys(key);
      debugPrint('Security key successfully initialised and saved.');
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

  /// Handles restoring/verifying an existing security key.
  /// This is used when the server has enc-keys.ttl but local storage doesn't.
  /// Unlike handleKeySubmission, this uses setSecurityKey which VERIFIES
  /// against the server's verification key instead of overwriting it.

  static Future<bool> handleRestoreKey(
    String key,
    void Function(String message) showErrorFunction,
  ) async {
    if (key.isEmpty) {
      showErrorFunction('Please enter your security key');
      return false;
    }

    try {
      // Use setSecurityKey() which verifies against server's verification key.
      // This will throw if the key doesn't match.
      await KeyManager.setSecurityKey(key);
      debugPrint('Security key successfully restored and verified.');
      return true;
    } catch (e) {
      debugPrint('Error restoring security key: $e');
      String errorMessage = 'Incorrect security key.';

      final errorStr = e.toString().toLowerCase();

      if (errorStr.contains('not logged in') ||
          errorStr.contains('authentication')) {
        errorMessage = 'You must be logged in to restore your security key.';
      } else if (errorStr.contains('network') ||
          errorStr.contains('connection')) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      } else if (errorStr.contains('verify')) {
        errorMessage =
            'Incorrect security key. Please enter the key you originally set.';
      }

      try {
        showErrorFunction(errorMessage);
      } catch (displayError) {
        debugPrint('Error displaying error message: $displayError');
      }

      return false;
    }
  }

  /// Handles initializing new encryption keys after a full reset.
  /// Shows the new key dialog and calls initPodKeys to create fresh keys.
  static Future<void> handleNewKeyInit(
    BuildContext context,
    TextEditingController keyController,
    TextEditingController confirmKeyController,
    Future<void> Function() onKeySet,
  ) async {
    keyController.clear();
    confirmKeyController.clear();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _NewKeyInitDialog(
        keyController: keyController,
        confirmKeyController: confirmKeyController,
        onKeySet: onKeySet,
      ),
    );
  }
}

/// Dialog for setting a new security key after reset.
class _NewKeyInitDialog extends StatefulWidget {
  const _NewKeyInitDialog({
    required this.keyController,
    required this.confirmKeyController,
    required this.onKeySet,
  });

  final TextEditingController keyController;
  final TextEditingController confirmKeyController;
  final Future<void> Function() onKeySet;

  @override
  State<_NewKeyInitDialog> createState() => _NewKeyInitDialogState();
}

class _NewKeyInitDialogState extends State<_NewKeyInitDialog> {
  bool _isLoading = false;
  bool _obscureKey = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Row(
        children: [
          Icon(Icons.key, color: Colors.green),
          SizedBox(width: 8),
          Text('Set New Security Key', style: TextStyle(fontSize: 18)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your old encryption keys have been deleted.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please set a new security key to encrypt your data.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.keyController,
            obscureText: _obscureKey,
            enabled: !_isLoading,
            decoration: InputDecoration(
              labelText: 'New Security Key',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.confirmKeyController,
            obscureText: _obscureConfirm,
            enabled: !_isLoading,
            decoration: InputDecoration(
              labelText: 'Confirm Security Key',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Set Key'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    final key = widget.keyController.text;
    final confirmKey = widget.confirmKeyController.text;

    if (key.isEmpty || confirmKey.isEmpty) {
      setState(() => _errorMessage = 'Please enter both fields');
      return;
    }

    if (key != confirmKey) {
      setState(() => _errorMessage = 'Keys do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await KeyManager.initPodKeys(key);
      if (!mounted) return;
      Navigator.of(context).pop();
      await widget.onKeySet();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to set key: ${e.toString().split('\n').first}';
      });
    }
  }
}
