/// Layout constants for UI elements.
///
/// Copyright (C) 2025-2026, Software Innovation Institute, ANU.
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
/// Authors: Ashley Tang, Jess Moore, Tony Chen

library;

import 'package:flutter/material.dart';

/// Layout constants used across security dialogs and prompts.

class SecurityLayout {
  /// Horizontal gap between elements.

  static const horizontalGap = SizedBox(width: 16);

  /// Standard padding for dialog content.

  static const contentPadding = EdgeInsets.all(20);

  /// Padding for form sections.

  static const formPadding = EdgeInsets.fromLTRB(20, 20, 20, 8);

  /// Padding for button sections.

  static const buttonsPadding = EdgeInsets.fromLTRB(20, 8, 20, 20);

  /// Margin for green divider under heading.

  static const dividerMargin = EdgeInsets.only(top: 4, bottom: 14);

  /// Padding for WebID display.

  static const webIdPadding = EdgeInsets.only(top: 4, bottom: 20);

  /// Input field spacing.

  static const inputFieldSpacing = EdgeInsets.only(bottom: 16);

  /// Button padding.

  static const buttonPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  );

  /// Standard width for security dialogs.

  static const dialogWidth = 480.0;

  /// Maximum width constraint for security dialogs.

  static const maxDialogWidth = 500.0;

  /// Border radius for cards and buttons.

  static const borderRadius = 8.0;

  /// Border radius for buttons.

  static const buttonRadius = 6.0;

  /// Height for divider lines.

  static const dividerHeight = 1.5;

  /// Height for separator lines.

  static const separatorHeight = 1.0;
}

/// Layout constants for scrollbars.

class ScrollbarLayout {
  /// Vertical gap between edge widget and scrollbar to avoid
  /// horizontal scrollbar overlapping bottom edge of wrapped
  /// content.

  static const verticalGap = SizedBox(height: 30);

  /// Horizontal gap between edge widget and scrollbar to avoid
  /// vertical scrollbar overlapping the right edge of wrapped
  /// content

  static const horizontalGap = SizedBox(width: 10);
}

/// Layout constants used for WebId dialogs.

class WebIdLayout {
  /// Vertical gap between paragraphs.

  static const paraVertGap = SizedBox(height: 10);

  /// Standard padding for dialog content.

  static const contentPadding = EdgeInsets.symmetric(horizontal: 50);

  /// Standard width for security dialogs.

  static const dialogWidth = 480.0;

  /// Height of dropdown suggestion box.

  static const dropdownHeight = 120.0;

  /// Elevation of dropdown suggestion cards.

  static double dropdownElevation = 5;

  /// Padding of dropdown suggestion list.

  static const listPadding = EdgeInsets.fromLTRB(0, 5, 0, 5);
}

/// Layout constants used for Grant Permission Form Dialog.

class GrantPermFormLayout {
  /// Vertical gap between paragraphs.

  static const paraVertGap = SizedBox(height: 10);

  /// Standard padding for dialog content.

  static const contentPadding = EdgeInsets.symmetric(horizontal: 50);

  /// Padding for dialog input sections.

  static const inputPadding = EdgeInsets.all(8);

  /// Standard width for security dialogs.

  static const dialogWidth = 480.0;

  /// Height of dropdown suggestion box.

  static const dropdownHeight = 120.0;

  /// Elevation of dropdown suggestion cards.

  static double dropdownElevation = 5;

  /// Padding of dropdown suggestion list.

  static const listPadding = EdgeInsets.fromLTRB(0, 5, 0, 5);
}

/// Layout constants used for sharing page.

class SharingPageLayout {
  /// Padding for dialog input sections.

  static const inputPadding = EdgeInsets.all(8);
}
