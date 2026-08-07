/// Set Key Dialog Widget.
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

import 'package:solidui/src/widgets/solid_security_key_ui_helpers.dart';

/// Dialog for setting a new security key with loading state.

class SetKeyDialog extends StatefulWidget {
  final TextEditingController keyController;
  final TextEditingController confirmKeyController;
  final Future<void> Function() onKeyChanged;
  final Future<bool> Function(String key, String confirmKey)
  handleSubmissionFunction;

  const SetKeyDialog({
    super.key,
    required this.keyController,
    required this.confirmKeyController,
    required this.onKeyChanged,
    required this.handleSubmissionFunction,
  });

  @override
  State<SetKeyDialog> createState() => _SetKeyDialogState();
}

class _SetKeyDialogState extends State<SetKeyDialog> {
  bool _isLoading = false;
  bool _obscureKey = true;
  bool _obscureConfirmKey = true;
  String? _keyErrorText;
  String? _confirmKeyErrorText;

  @override
  void initState() {
    super.initState();
    widget.keyController.addListener(_validateKeyInput);
    widget.confirmKeyController.addListener(_validateConfirmKeyInput);
  }

  @override
  void dispose() {
    widget.keyController.removeListener(_validateKeyInput);
    widget.confirmKeyController.removeListener(_validateConfirmKeyInput);
    super.dispose();
  }

  void _validateKeyInput() {
    setState(() {
      if (widget.keyController.text.isEmpty) {
        _keyErrorText = null;
      } else if (widget.keyController.text.length < 6) {
        _keyErrorText = 'Key must be at least 6 characters';
      } else {
        _keyErrorText = null;
      }

      // Also validate confirm key when main key changes.

      _validateConfirmKeyMatch();
    });
  }

  void _validateConfirmKeyInput() {
    setState(() {
      _validateConfirmKeyMatch();
    });
  }

  void _validateConfirmKeyMatch() {
    if (widget.confirmKeyController.text.isEmpty) {
      _confirmKeyErrorText = null;
    } else if (widget.keyController.text != widget.confirmKeyController.text) {
      _confirmKeyErrorText = 'Keys do not match';
    } else {
      _confirmKeyErrorText = null;
    }
  }

  bool get _isInputValid {
    return widget.keyController.text.length >= 6 &&
        widget.confirmKeyController.text.length >= 6 &&
        widget.keyController.text == widget.confirmKeyController.text;
  }

  Future<void> _handleSetKey() async {
    // Validation is now done inline, so we can proceed directly.

    if (!_isInputValid) {
      return;
    }

    // Show loading state.

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

      SecurityKeyUIHelpers.showErrorSnackBar(context, 'Failed to set key: $e');
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
                decoration:
                    SecurityKeyUIHelpers.getInputDecoration(
                      'Enter Security Key',
                      ThemeData(),
                    ).copyWith(
                      errorText: _keyErrorText,
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
                keyboardType: TextInputType.visiblePassword,
                enableSuggestions: false,
                autocorrect: false,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.confirmKeyController,
                decoration:
                    SecurityKeyUIHelpers.getInputDecoration(
                      'Confirm Security Key',
                      ThemeData(),
                    ).copyWith(
                      errorText: _confirmKeyErrorText,
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
                keyboardType: TextInputType.visiblePassword,
                enableSuggestions: false,
                autocorrect: false,
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
                  onPressed: _isInputValid ? _handleSetKey : null,
                  style: SecurityKeyUIHelpers.getButtonStyle(ThemeData()),
                  child: const Text('Set Key'),
                ),
              ],
      ),
    );
  }
}
