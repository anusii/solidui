/// Default theme system for SolidUI applications.
///
// Time-stamp: <Tuesday 2025-08-27 14:30:00 +1000 Tony Chen>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

/// Default theme constants for SolidUI applications.

class SolidDefaultTheme {
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
  
  static ThemeData lightTheme({
    Color? primaryColor,
    ColorScheme? colorScheme,
  }) {
    final seedColor = primaryColor ?? SolidDefaultTheme.primaryColor;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme ?? ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
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
  
  static ThemeData darkTheme({
    Color? primaryColor,
    ColorScheme? colorScheme,
  }) {
    final seedColor = primaryColor ?? SolidDefaultTheme.primaryColor;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme ?? ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
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

class SolidDefaultThemeConfig {
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
  
  const SolidDefaultThemeConfig({
    this.primaryColor = SolidDefaultTheme.primaryColor,
    this.defaultPadding = SolidDefaultTheme.defaultPadding,
    this.defaultBorderRadius = SolidDefaultTheme.defaultBorderRadius,
    this.primaryTextColor = SolidDefaultTheme.primaryTextColor,
    this.secondaryTextColor = SolidDefaultTheme.secondaryTextColor,
  });

  /// Creates light and dark themes based on this configuration.
  
  ThemeData get lightTheme => SolidDefaultTheme.lightTheme(
    primaryColor: primaryColor,
  );

  /// Creates dark theme based on this configuration.
  
  ThemeData get darkTheme => SolidDefaultTheme.darkTheme(
    primaryColor: primaryColor,
  );
}
