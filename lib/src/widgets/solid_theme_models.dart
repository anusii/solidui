/// Models for theme toggle functionality in Solid applications.
///
// Time-stamp: <Monday 2025-01-06 15:30:00 +1000 Tony Chen>
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

/// Configuration for theme toggle functionality in the Solid scaffold.

class SolidThemeToggleConfig {
  /// Whether the theme toggle is enabled.

  final bool enabled;

  /// Custom icon for light mode (defaults to sun icon).

  final IconData? lightModeIcon;

  /// Custom icon for dark mode (defaults to moon icon).

  final IconData? darkModeIcon;

  /// Callback when theme is toggled. Should handle the theme change logic.

  final VoidCallback? onToggleTheme;

  /// Current theme mode to determine which icon to show.

  final ThemeMode currentThemeMode;

  /// Whether to show as icon button in AppBar actions or in overflow menu.

  final bool showInAppBarActions;

  /// Tooltip text for the theme toggle button.

  final String? tooltip;

  /// Label text for theme toggle in overflow menu.

  final String label;

  /// Priority for ordering in overflow menu (higher numbers appear later).

  final int priority;

  /// Whether to hide the theme toggle on narrow screens.

  final bool hideOnNarrowScreen;

  /// Whether to hide the theme toggle on very narrow screens.

  final bool hideOnVeryNarrowScreen;

  const SolidThemeToggleConfig({
    this.enabled = true,
    this.lightModeIcon,
    this.darkModeIcon,
    this.onToggleTheme,
    this.currentThemeMode = ThemeMode.system,
    this.showInAppBarActions = true,
    this.tooltip,
    this.label = 'Toggle Theme',
    this.priority = 1,
    this.hideOnNarrowScreen = false,
    this.hideOnVeryNarrowScreen = true,
  });

  /// Returns the appropriate icon based on current theme mode.

  IconData get currentIcon {
    switch (currentThemeMode) {
      case ThemeMode.light:
        return darkModeIcon ?? Icons.dark_mode;
      case ThemeMode.dark:
        return lightModeIcon ?? Icons.light_mode;
      case ThemeMode.system:
        // For system mode, show dark mode icon as toggle action
        return darkModeIcon ?? Icons.dark_mode;
    }
  }

  /// Returns tooltip text based on current theme mode.

  String get currentTooltip {
    if (tooltip != null) return tooltip!;

    switch (currentThemeMode) {
      case ThemeMode.light:
        return '''
**Theme Toggle**

🌙 Switch to **Dark Mode**

Tap to switch to dark theme for better viewing in low light conditions.
''';
      case ThemeMode.dark:
        return '''
**Theme Toggle**

☀️ Switch to **Light Mode**

Tap to switch to light theme for better viewing in bright conditions.
''';
      case ThemeMode.system:
        return '''
**Theme Toggle**

🎨 **Toggle Theme**

Tap to toggle between light and dark themes. Currently following system settings.
''';
    }
  }

  /// Returns overflow menu label based on current theme mode.

  String get currentOverflowLabel {
    switch (currentThemeMode) {
      case ThemeMode.light:
        return 'Dark Mode';
      case ThemeMode.dark:
        return 'Light Mode';
      case ThemeMode.system:
        return label;
    }
  }
}
