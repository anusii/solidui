/// Text style constants for UI elements.
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

import 'package:solidui/src/constants/ui_colors.dart';

/// Text styles used across security dialogs and prompts.

class SecurityTextStyles {
  /// Style for main headings (e.g. "Security Key").

  static const heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: SecurityColors.primary,
  );

  /// Style for regular text content.

  static const body = TextStyle(fontSize: 15, color: SecurityColors.text);

  /// Style for the WebID display.

  static const webId = TextStyle(fontSize: 13, fontWeight: FontWeight.w500);

  /// Style for the "Currently logged in as:" label.

  static const label = TextStyle(fontSize: 13, color: SecurityColors.labelGrey);

  /// Style for button text.

  static const button = TextStyle(fontSize: 14, color: Colors.white);
}

/// Helper class to obtain theme-aware text styles for security UI components.

class SecurityThemeTextStyles {
  /// Returns the heading style based on the current theme.

  static TextStyle heading(BuildContext context) {
    return TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: SecurityThemeColors.primary(context),
    );
  }

  /// Returns the body text style based on the current theme.

  static TextStyle body(BuildContext context) {
    return TextStyle(fontSize: 15, color: SecurityThemeColors.text(context));
  }

  /// Returns the WebID style based on the current theme.

  static TextStyle webId(BuildContext context, {bool isLoggedIn = true}) {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: isLoggedIn ? SecurityThemeColors.primary(context) : Colors.red,
    );
  }

  /// Returns the label style based on the current theme.

  static TextStyle label(BuildContext context) {
    return TextStyle(
      fontSize: 13,
      color: SecurityThemeColors.labelGrey(context),
    );
  }

  /// Returns the button text style.

  static const button = TextStyle(fontSize: 14, color: Colors.white);

  /// Returns the cancel button style based on the current theme.

  static TextStyle cancelButton(BuildContext context) {
    return TextStyle(fontSize: 14, color: SecurityThemeColors.text(context));
  }
}

/// Text styles used for permission form.

class RecipientTextStyle {
  /// Style for the label.

  static const label = TextStyle(fontSize: 15, fontWeight: FontWeight.w500);

  /// Style for the WebID display.

  static const webId = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.blueAccent,
  );
}

/// Layout constants for sub headings.

class SubHeadingStyle {
  /// Font size.

  static const double fontsize = 17.0;

  /// Font colour.

  static const Color fontcolor = Color.fromRGBO(96, 125, 139, 1);

  /// Font weight.

  static const FontWeight fontweight = FontWeight.bold;

  /// Padding.

  static const double padding = 8.0;
}

/// Layout constants for headings.

class HeadingStyle {
  /// Font size.

  static const double fontsize = 22.0;

  /// Font colour.

  static const Color fontcolor = Color.fromRGBO(96, 125, 139, 1);

  /// Font weight.

  static const FontWeight fontweight = FontWeight.bold;

  /// Padding.

  static const double padding = 8.0;
}
