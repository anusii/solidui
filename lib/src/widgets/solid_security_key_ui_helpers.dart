/// Security Key UI Helper Functions.
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

/// Helper class for Security Key UI components.

class SecurityKeyUIHelpers {
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
      backgroundColor: isDestructive
          ? theme.colorScheme.error
          : theme.colorScheme.surface,
      foregroundColor: isDestructive
          ? theme.colorScheme.onError
          : theme.colorScheme.primary,
      side: BorderSide(
        color: isDestructive
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
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
}
