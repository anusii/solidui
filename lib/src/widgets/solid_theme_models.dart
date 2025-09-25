/// Models for theme toggle functionality in Solid applications.
///
// Time-stamp: <Sunday 2025-08-31 11:06:35 +1000 Graham Williams>
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

  /// Custom icon for system mode (defaults to computer icon).

  final IconData? systemModeIcon;

  /// Callback when theme is toggled. Should handle the theme change logic.
  /// If null, SolidScaffold will manage theme state internally.

  final VoidCallback? onToggleTheme;

  /// Current theme mode to determine which icon to show.
  /// Only used for external state management. If null, internal state will be
  /// used.

  final ThemeMode? currentThemeMode;

  /// Whether to show as icon button in AppBar actions or in overflow menu.

  final bool showInAppBarActions;

  /// Tooltip text for the theme toggle button.

  final String? tooltip;

  /// Label text for theme toggle in overflow menu.

  final String label;

  /// Priority for ordering in overflow menu (higher numbers appear later).

  final int priority;

  /// Whether to show the theme toggle on narrow screens.

  final bool showOnNarrowScreen;

  /// Whether to show the theme toggle on very narrow screens.

  final bool showOnVeryNarrowScreen;

  const SolidThemeToggleConfig({
    this.enabled = true,
    this.lightModeIcon,
    this.darkModeIcon,
    this.systemModeIcon,
    this.onToggleTheme,
    this.currentThemeMode,
    this.showInAppBarActions = true,
    this.tooltip,
    this.label = 'Toggle Theme',
    this.priority = 1,
    this.showOnNarrowScreen = true,
    this.showOnVeryNarrowScreen = true,
  });

  /// Returns the appropriate icon based on current theme mode.

  IconData getCurrentIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return lightModeIcon ?? Icons.light_mode;
      case ThemeMode.dark:
        return darkModeIcon ?? Icons.dark_mode;
      case ThemeMode.system:
        return systemModeIcon ?? Icons.computer;
    }
  }

  /// Returns tooltip text based on current theme mode.

  String getCurrentTooltip(ThemeMode themeMode) {
    // If a custom tooltip is provided, use it instead of the default one.

    if (tooltip != null) return tooltip!;

    // Return responsive tooltip based on current theme mode.

    switch (themeMode) {
      case ThemeMode.light:
        return '''
**Theme Toggle**

☀️ **Light Mode** (Current)

Light Mode is best for viewing in light conditions. Tap here to switch to Dark
Mode for low light conditions.

Toggle: ☀️ Light ⇄ 🌙 Dark
''';
      case ThemeMode.dark:
        return '''
**Theme Toggle**

🌙 **Dark Mode** (Current)

Dark Mode is best for viewing in low light conditions. Tap here to switch to
Light Mode for bright viewing conditions.

Toggle: ☀️ Light ⇄ 🌙 Dark
''';
      case ThemeMode.system:
        return '''
**Theme Toggle**

🖥️ **System Mode** (Current)

System Mode follows your device settings. This is the initial mode. Tap here to
switch to Light Mode, and afterwards toggle between Light and Dark modes.

First Switch: 🖥️ System → ☀️ Light
Then Toggle: ☀️ Light ⇄ 🌙 Dark
''';
    }
  }

  /// Returns overflow menu label based on current theme mode.

  String getCurrentOverflowLabel(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light Mode ☀️';
      case ThemeMode.dark:
        return 'Dark Mode 🌙';
      case ThemeMode.system:
        return 'System Mode 🖥️';
    }
  }

  /// Returns the appropriate icon for the next theme mode.

  IconData getNextIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return darkModeIcon ?? Icons.dark_mode;
      case ThemeMode.dark:
        return lightModeIcon ?? Icons.light_mode;
      case ThemeMode.system:
        return lightModeIcon ?? Icons.light_mode;
    }
  }

  /// Returns tooltip text for switching to the next theme mode.

  String getNextTooltip(ThemeMode themeMode) {
    // If a custom tooltip is provided, use it instead of the default one.

    if (tooltip != null) return tooltip!;

    // Return responsive tooltip based on next theme mode.

    switch (themeMode) {
      case ThemeMode.light:
        return '''
**Theme Toggle**

☀️ **Light Mode** (Current)

Light Mode is best for viewing in bright conditions. Tap here to switch to Dark
Mode for low light conditions.

Next: 🌙 **Dark Mode**
''';
      case ThemeMode.dark:
        return '''
**Theme Toggle**

🌙 **Dark Mode** (Current)

Dark Mode is best for viewing in low light conditions. Tap here to switch back
to Light Mode for bright viewing conditions.

Next: ☀️ **Light Mode**
''';
      case ThemeMode.system:
        return '''
**Theme Toggle**

🖥️ **System Mode** (Current)

System Mode follows your device settings. This is the initial mode. Tap here to
switch to Light Mode and begin toggling between Light and Dark modes.

Next: ☀️ **Light Mode**
''';
    }
  }

  /// Returns overflow menu label for the next theme mode.

  String getNextOverflowLabel(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Switch to Dark Mode 🌙';
      case ThemeMode.dark:
        return 'Switch to Light Mode ☀️';
      case ThemeMode.system:
        return 'Switch to Light Mode ☀️';
    }
  }

  /// Whether this config uses internal theme management.
  ///
  /// Returns `true` when both `onToggleTheme` and `currentThemeMode` are null,
  /// indicating that SolidScaffold should automatically manage theme state
  /// using `SolidThemeNotifier`.
  ///
  /// Returns `false` when external theme management is being used, requiring
  /// both parameters to be provided for proper functionality.

  bool get usesInternalManagement =>
      onToggleTheme == null && currentThemeMode == null;
}
