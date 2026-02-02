/// Colour constants for UI elements.
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

// Standard colours for actions and results.

class ActionColors {
  /// Green colour used for success.

  static const success = Colors.green;

  // Red colour used for error/failure.

  static const error = Colors.red;

  // Colour used for warning.

  static const warning = Color.fromARGB(255, 204, 99, 1);

  // Red colour used for delete action.

  static const delete = Colors.red;
}

/// Colours used across security dialogs and prompts.

class SecurityColors {
  /// Primary colour (Forest Green) used for headings and important elements.

  static const primary = Color(0xFF2E7D32);

  /// Primary colour for dark mode (lighter green for better contrast).

  static const primaryDark = Color(0xFF66BB6A);

  /// Accent colour (Lighter Green) used for dividers and secondary elements.

  static const accent = Color(0xFF4CAF50);

  /// Accent colour for dark mode.

  static const accentDark = Color(0xFF81C784);

  /// Background colour (Light Grey) used for dialog backgrounds.

  static const background = Color(0xFFF5F5F5);

  /// Background colour for dark mode.

  static const backgroundDark = Color(0xFF1E1E1E);

  /// Text colour (Dark Grey) used for main text content.

  static const text = Color(0xFF212121);

  /// Text colour for dark mode.

  static const textDark = Color(0xFFE0E0E0);

  /// Grey colour used for labels and secondary text.

  static const labelGrey = Colors.grey;

  /// Label colour for dark mode.

  static const labelGreyDark = Color(0xFF9E9E9E);

  /// Card background colour for light mode.

  static const cardBackground = Colors.white;

  /// Card background colour for dark mode.

  static const cardBackgroundDark = Color(0xFF2D2D2D);

  /// Separator colour for light mode.

  static const separator = Color(0xFFE0E0E0);

  /// Separator colour for dark mode.

  static const separatorDark = Color(0xFF424242);
}

/// Helper class to obtain theme-aware colours for security UI components.
///
/// This class provides methods that return appropriate colours based on the
/// current theme brightness (light or dark mode).

class SecurityThemeColors {
  /// Returns the primary colour based on the current theme.

  static Color primary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? SecurityColors.primaryDark : SecurityColors.primary;
  }

  /// Returns the accent colour based on the current theme.

  static Color accent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? SecurityColors.accentDark : SecurityColors.accent;
  }

  /// Returns the background colour based on the current theme.

  static Color background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? SecurityColors.backgroundDark : SecurityColors.background;
  }

  /// Returns the text colour based on the current theme.

  static Color text(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? SecurityColors.textDark : SecurityColors.text;
  }

  /// Returns the label grey colour based on the current theme.

  static Color labelGrey(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? SecurityColors.labelGreyDark : SecurityColors.labelGrey;
  }

  /// Returns the card background colour based on the current theme.

  static Color cardBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? SecurityColors.cardBackgroundDark
        : SecurityColors.cardBackground;
  }

  /// Returns the separator colour based on the current theme.

  static Color separator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? SecurityColors.separatorDark : SecurityColors.separator;
  }
}

/// Colours used across dropdown dialogs and prompts.

class DropdownColors {
  /// Primary colour (Forest Green) used for dropdown elements

  static const primary = Color(0xFF2E7D32);

  /// Accent colour (Lighter Green) used for dividers and secondary elements.

  static const accent = Color(0xFF4CAF50);
}
