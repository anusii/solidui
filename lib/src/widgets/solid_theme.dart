/// Theme system for SolidUI applications.
///
// Time-stamp: <Tuesday 2025-08-27 14:30:00 +1000 Tony Chen>
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

/// Theme constants for SolidUI applications.

class SolidTheme {
  /// Default primary color for SolidUI applications.

  static const Color primaryColor = Colors.blue;

  /// Default padding used throughout the application.

  static const double defaultPadding = 16.0;

  /// Default border radius for UI elements.

  static const double defaultBorderRadius = 8.0;

  /// Default text color for primary text.

  static const Color primaryTextColor = Colors.black87;

  /// Default text color for secondary text.

  static const Color secondaryTextColor = Colors.black54;

  /// Creates a light theme with optional customisation.

  static ThemeData lightTheme({Color? primaryColor, ColorScheme? colorScheme}) {
    final seedColor = primaryColor ?? SolidTheme.primaryColor;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme ??
          ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
          ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        contentPadding: const EdgeInsets.all(defaultPadding),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding * 2,
            vertical: defaultPadding,
          ),
        ),
      ),
    );
  }

  /// Creates a dark theme with optional customisation.

  static ThemeData darkTheme({Color? primaryColor, ColorScheme? colorScheme}) {
    final seedColor = primaryColor ?? SolidTheme.primaryColor;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme ??
          ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
          ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        contentPadding: const EdgeInsets.all(defaultPadding),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding * 2,
            vertical: defaultPadding,
          ),
        ),
      ),
    );
  }
}

/// Configuration for customising SolidUI theme.

class SolidThemeConfig {
  /// Primary color for the application.

  final Color primaryColor;

  /// Default padding used throughout the application.

  final double defaultPadding;

  /// Default border radius for UI elements.

  final double defaultBorderRadius;

  /// Text color for primary text.

  final Color primaryTextColor;

  /// Text color for secondary text.

  final Color secondaryTextColor;

  /// Creates a theme configuration.

  const SolidThemeConfig({
    this.primaryColor = SolidTheme.primaryColor,
    this.defaultPadding = SolidTheme.defaultPadding,
    this.defaultBorderRadius = SolidTheme.defaultBorderRadius,
    this.primaryTextColor = SolidTheme.primaryTextColor,
    this.secondaryTextColor = SolidTheme.secondaryTextColor,
  });

  /// Creates light and dark themes based on this configuration.

  ThemeData get lightTheme => SolidTheme.lightTheme(primaryColor: primaryColor);

  /// Creates dark theme based on this configuration.

  ThemeData get darkTheme => SolidTheme.darkTheme(primaryColor: primaryColor);
}
