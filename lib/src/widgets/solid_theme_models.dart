/// Models for theme toggle functionality in Solid applications.
///
// Time-stamp: <Monday 2025-08-18 15:30:00 +1000 Tony Chen>
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
    if (tooltip != null) return tooltip!;

    switch (themeMode) {
      case ThemeMode.light:
        return '''
**Theme Toggle**

☀️ **Light Mode** (Current)

Tap to switch to Dark Mode for better viewing in low light conditions.

Cycle: Light → Dark → System
''';
      case ThemeMode.dark:
        return '''
**Theme Toggle**

🌙 **Dark Mode** (Current)

Tap to switch to System Mode to follow your device settings.

Cycle: Light → Dark → System
''';
      case ThemeMode.system:
        return '''
**Theme Toggle**

🖥️ **System Mode** (Current)

Following your device settings. Tap to switch to Light Mode.

Cycle: Light → Dark → System
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

  /// A simple configuration that handles theme management internally.

  const SolidThemeToggleConfig.managed({
    this.enabled = true,
    this.lightModeIcon,
    this.darkModeIcon,
    this.systemModeIcon,
    this.showInAppBarActions = true,
    String? tooltip,
    this.label = 'Toggle Theme',
    this.priority = 1,
    this.showOnNarrowScreen = true,
    this.showOnVeryNarrowScreen = true,
  })  : onToggleTheme = null,
        currentThemeMode = null,
        tooltip = tooltip ??
            '''
**Theme Toggle**

Switch between system, light and dark modes for optimal viewing experience.

🌙 **Dark Mode**: Better for low-light environments

☀️ **Light Mode**: Better for bright environments

🖥️ **System Mode**: Follows your device settings
''';

  /// Whether this config uses internal theme management.

  bool get usesInternalManagement =>
      onToggleTheme == null && currentThemeMode == null;
}
