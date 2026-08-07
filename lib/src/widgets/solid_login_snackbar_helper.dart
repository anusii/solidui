/// Snackbar helper for SolidLogin widget.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
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

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:solidui/src/models/snackbar_config.dart';
import 'package:solidui/src/widgets/solid_login_helper.dart';

/// Helper class for showing snackbars in the SolidLogin widget.

class SolidLoginSnackbarHelper {
  /// Shows a snackbar with consistent theming.

  static void showSnackbar(
    BuildContext context, {
    required String message,
    required bool isDarkMode,
    required SolidLoginThemeMode currentTheme,
    required SnackbarConfig snackbarConfig,
    Duration? duration,
    bool showAction = true,
  }) {
    final backgroundColor =
        snackbarConfig.backgroundColor ??
        (isDarkMode
            ? currentTheme.backgroundColor.withValues(alpha: 0.9)
            : currentTheme.backgroundColor.withValues(alpha: 0.7));

    final effectiveDuration = duration ?? snackbarConfig.duration;

    final controller = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: snackbarConfig.textColor != Colors.black
                ? snackbarConfig.textColor
                : currentTheme.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        duration: effectiveDuration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(snackbarConfig.borderRadius),
          side: BorderSide(color: currentTheme.dividerColor, width: 0.5),
        ),
        action: showAction
            ? SnackBarAction(
                label: 'OK',
                textColor: snackbarConfig.actionTextColor != Colors.black
                    ? snackbarConfig.actionTextColor
                    : currentTheme.titleColor,
                onPressed: () {},
              )
            : null,
      ),
    );

    // Flutter keeps a SnackBar that has an action on screen indefinitely when
    // accessible navigation is active, ignoring the duration. Close it
    // explicitly so it always disappears, while still offering the OK action.

    var alreadyClosed = false;
    controller.closed.then((_) => alreadyClosed = true);
    Timer(effectiveDuration, () {
      if (!alreadyClosed) controller.close();
    });
  }
}
