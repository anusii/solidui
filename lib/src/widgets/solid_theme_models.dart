/// Models for theme toggle functionality in Solid applications.
///
// Time-stamp: <Sunday 2025-10-26 15:42:49 +1100 Graham Williams>
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
import 'package:flutter/scheduler.dart';

import 'package:solidui/src/widgets/solid_preferences_models.dart';

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

  /// Light mode tooltip.

  final lightModeTooltip = '''

  **Theme**

  Currently **Light Mode** is active. Light Mode is best for
  viewing in light conditions. Tap here to switch to Dark Mode for low
  light conditions.

  ''';

  /// Dark mode tooltip.

  final darkModeTooltip = '''

  **Theme**

  Currently **Dark Mode** is active. Dark Mode is best for viewing in
  low light conditions. Tap here to switch to Light Mode for bright viewing
  conditions.

  ''';

  /// System mode tooltip.

  final systemModeTooltip = '''

  **Theme**

  Currently **System Mode** is active. System Mode follows your
  device settings. This is the initial mode. Tap here to switch to the opposite
  of your current system theme, and afterwards toggle between Light and Dark
  modes.

  ''';

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

  /// Returns the appropriate icon for the next theme mode.

  IconData getNextIcon(
    ThemeMode themeMode, [
    SolidThemeModeConfig? modeConfig,
  ]) {
    final enabledModes = modeConfig?.enabledModes ??
        [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    final smartToggle = modeConfig?.smartToggle ?? true;

    // Find what the next mode will be based on enabled modes.

    final currentIndex = enabledModes.indexOf(themeMode);

    if (currentIndex == -1 || enabledModes.length <= 1) {
      // Current mode not in enabled list or only one mode, show current mode
      // icon.

      return _getIconForMode(themeMode);
    }

    // Special handling for system mode with smart toggle enabled.
    // Only apply smart logic when all three modes are enabled and smartToggle
    // is on.

    if (themeMode == ThemeMode.system &&
        smartToggle &&
        enabledModes.length == 3) {
      final systemBrightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      final targetMode = systemBrightness == Brightness.light
          ? ThemeMode.dark
          : ThemeMode.light;

      if (enabledModes.contains(targetMode)) {
        return _getIconForMode(targetMode);
      }
    }

    // Get the next mode in the cycle (sequential toggle).

    final nextIndex = (currentIndex + 1) % enabledModes.length;
    final nextMode = enabledModes[nextIndex];
    return _getIconForMode(nextMode);
  }

  /// Returns the icon for a specific theme mode.

  IconData _getIconForMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return lightModeIcon ?? Icons.wb_sunny_outlined;
      case ThemeMode.dark:
        return darkModeIcon ?? Icons.dark_mode;
      case ThemeMode.system:
        return systemModeIcon ?? Icons.brightness_auto;
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
