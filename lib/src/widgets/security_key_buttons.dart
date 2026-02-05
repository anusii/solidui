/// Button row component for the SecurityKeyUI widget.
///
/// Copyright (C) 2024-2025, Software Innovation Institute, ANU.
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
/// Authors: Ashley Tang

library;

import 'package:flutter/material.dart';

import 'package:solidui/src/constants/ui.dart';

/// A button row widget for security key UI submit and cancel actions.

class SecurityKeyButtons extends StatelessWidget {
  /// Creates security key action buttons.

  const SecurityKeyButtons({
    required this.canSubmit,
    required this.onSubmit,
    required this.onCancel,
    super.key,
  });

  /// Whether the submit button should be enabled.

  final bool canSubmit;

  /// Callback when the submit button is pressed.

  final VoidCallback onSubmit;

  /// Callback when the cancel button is pressed.

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final submitButton = ElevatedButton(
      onPressed: canSubmit ? onSubmit : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: SecurityThemeColors.primary(context),
        padding: SecurityLayout.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SecurityLayout.buttonRadius),
        ),
      ),
      child: const Text(
        SecurityStrings.submit,
        style: SecurityThemeTextStyles.button,
      ),
    );

    final cancelButton = TextButton(
      onPressed: onCancel,
      style: TextButton.styleFrom(
        padding: SecurityLayout.buttonPadding,
      ),
      child: Text(
        SecurityStrings.cancel,
        style: SecurityThemeTextStyles.cancelButton(context),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        cancelButton,
        SecurityLayout.horizontalGap,
        submitButton,
      ],
    );
  }
}
