/// Security Key Manager Dialogue Components.
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
    show SolidFunctionCallStatus, changeKeyPopup, getEncKeyPath, readPod;

import 'package:solidui/src/widgets/solid_security_key_ui_helpers.dart';
import 'package:solidui/src/widgets/solid_security_key_view.dart';

/// Dialog management for Security Key Manager.

class SolidSecurityKeyManagerDialogs {
  /// Shows the key input dialog for existing keys.

  static Future<void> showKeyInputDialog(
    BuildContext context,
    Widget appWidget,
    Future<void> Function() onKeyChanged,
  ) async {
    try {
      await changeKeyPopup(context, appWidget);
      await onKeyChanged();
    } catch (e) {
      if (context.mounted) {
        SecurityKeyUIHelpers.showErrorSnackBar(context, e.toString());
      }
    }
  }

  /// Shows the new key dialogue.

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
      builder: (context) => _SetKeyDialog(
        keyController: keyController,
        confirmKeyController: confirmKeyController,
        onKeyChanged: onKeyChanged,
        handleSubmissionFunction: handleSubmissionFunction,
      ),
    );
  }

  /// Shows the key file not found dialogue.

  static Future<void> showKeyFileNotFoundDialog(
    BuildContext context,
    Future<void> Function() checkKeyStatus,
    Future<void> Function(BuildContext) showKeyInputDialog,
  ) async {
    await SecurityKeyUIHelpers.showErrorDialog(
      context,
      'Security Key File Not Found',
      'The security key file could not be found. Would you like to set a new '
          'security key?',
    );
    // Clear key manager state and show input dialogue
    await checkKeyStatus();
    if (context.mounted) {
      await showKeyInputDialog(context);
    }
  }

  /// Shows the private key data.

  static Future<void> showPrivateData(
    String title,
    BuildContext context,
    bool hasExistingKey,
    Widget appWidget,
    void Function(bool) setLoading,
    void Function(bool) onKeyStatusChanged,
    Future<void> Function() checkKeyStatus,
    Future<void> Function(BuildContext) showKeyFileNotFoundDialog,
  ) async {
    if (!hasExistingKey) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Notice'),
          content: const Text(
            'No security key found. Please set a security key first.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    setLoading(true);

    try {
      final filePath = await getEncKeyPath();
      if (!context.mounted) return;

      final fileContent = await readPod(
        filePath,
        context,
        appWidget,
      );
      if (!context.mounted) return;

      if (fileContent == SolidFunctionCallStatus.notLoggedIn.toString()) {
        await SecurityKeyUIHelpers.showErrorDialog(
          context,
          'Not Logged In',
          'You must be logged in to view security keys.',
        );
        return;
      }
      if (fileContent == SolidFunctionCallStatus.fail.toString()) {
        await showKeyFileNotFoundDialog(context);
        return;
      }
      if (fileContent.isNotEmpty) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SolidSecurityKeyView(title: title, keyInfo: fileContent),
          ),
        );
      } else {
        await SecurityKeyUIHelpers.showErrorDialog(
          context,
          'Empty Key File',
          'The security key file exists but appears to be empty.',
        );
      }
    } catch (e) {
      debugPrint('Exception reading security key: $e');
      if (context.mounted) {
        await SecurityKeyUIHelpers.showErrorDialog(
          context,
          'Error Reading Key',
          e.toString(),
        );
      }
    } finally {
      setLoading(false);
    }
  }
}

/// Dialog for setting a new security key with loading state.

class _SetKeyDialog extends StatefulWidget {
  final TextEditingController keyController;
  final TextEditingController confirmKeyController;
  final Future<void> Function() onKeyChanged;
  final Future<bool> Function(String key, String confirmKey)
      handleSubmissionFunction;

  const _SetKeyDialog({
    required this.keyController,
    required this.confirmKeyController,
    required this.onKeyChanged,
    required this.handleSubmissionFunction,
  });

  @override
  State<_SetKeyDialog> createState() => _SetKeyDialogState();
}

class _SetKeyDialogState extends State<_SetKeyDialog> {
  bool _isLoading = false;
  bool _obscureKey = true;
  bool _obscureConfirmKey = true;

  Future<void> _handleSetKey() async {
    if (widget.keyController.text != widget.confirmKeyController.text) {
      SecurityKeyUIHelpers.showErrorSnackBar(
        context,
        'Keys do not match',
      );
      return;
    }
    if (widget.keyController.text.length < 6) {
      SecurityKeyUIHelpers.showErrorSnackBar(
        context,
        'Key must be at least 6 characters',
      );
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.handleSubmissionFunction(
        widget.keyController.text,
        widget.confirmKeyController.text,
      );

      if (!mounted) return;

      if (success) {
        // Update the key status first.

        await widget.onKeyChanged();

        if (!mounted) return;

        // Close the Set Key dialog.

        Navigator.of(context).pop();

        if (!mounted) return;

        // Close the Security Key Manager dialog.

        Navigator.of(context).pop();

        // Show success dialog.

        await SecurityKeyUIHelpers.showErrorDialog(
          context,
          'Success',
          'Security key has been set successfully.',
        );
      } else {
        // Only hide loading if operation failed (to allow retry).

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      SecurityKeyUIHelpers.showErrorSnackBar(
        context,
        'Failed to set key: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Set Security Key',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isLoading) ...[
              TextField(
                controller: widget.keyController,
                decoration: SecurityKeyUIHelpers.getInputDecoration(
                  'Enter Security Key',
                  ThemeData(),
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureKey ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureKey = !_obscureKey;
                      });
                    },
                  ),
                ),
                obscureText: _obscureKey,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.confirmKeyController,
                decoration: SecurityKeyUIHelpers.getInputDecoration(
                  'Confirm Security Key',
                  ThemeData(),
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmKey
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmKey = !_obscureConfirmKey;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmKey,
              ),
            ] else ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                'Setting security key...',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
        actions: _isLoading
            ? []
            : [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _handleSetKey,
                  style: SecurityKeyUIHelpers.getButtonStyle(ThemeData()),
                  child: const Text('Set Key'),
                ),
              ],
      ),
    );
  }
}
