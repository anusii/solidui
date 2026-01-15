/// Theme toggle helper functions for Solid Scaffold.
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

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:solidui/src/widgets/solid_preferences_models.dart';
import 'package:solidui/src/widgets/solid_preferences_notifier.dart';
import 'package:solidui/src/widgets/solid_theme_models.dart';
import 'package:solidui/src/widgets/solid_theme_notifier.dart';

/// Helper class for theme toggle operations.

class SolidThemeToggleHelpers {
  /// Builds theme toggle button for AppBar actions.

  static Widget buildThemeToggleButton(
    SolidThemeToggleConfig themeConfig,
    ThemeMode currentThemeMode,
    VoidCallback? themeToggleCallback,
  ) {
    return Builder(
      builder: (context) {
        // Determine the tooltip message based on enabled modes.

        final themeModeConfig = solidPreferencesNotifier.themeModeConfig;
        String tooltipMessage;
        if (themeConfig.tooltip != null) {
          tooltipMessage = themeConfig.tooltip!;
        } else {
          tooltipMessage =
              solidThemeNotifier.getTooltipForCurrentMode(themeModeConfig);
        }

        // Get the next mode to determine which icon to show.

        final nextMode = getNextThemeModeWithContext(context, currentThemeMode);

        // Get the icon for the next mode.

        final iconWidget =
            Icon(_getIconForModeWithContext(context, nextMode, themeConfig));

        Widget themeButton = IconButton(
          icon: iconWidget,
          onPressed: themeToggleCallback,
        );

        return MarkdownTooltip(
          message: tooltipMessage,
          child: themeButton,
        );
      },
    );
  }

  /// Returns the icon for a specific theme mode.
  /// When the mode is System, returns the icon based on current system theme.

  static IconData _getIconForModeWithContext(
    BuildContext context,
    ThemeMode mode,
    SolidThemeToggleConfig config,
  ) {
    switch (mode) {
      case ThemeMode.light:
        return config.lightModeIcon ?? Icons.wb_sunny_outlined;
      case ThemeMode.dark:
        return config.darkModeIcon ?? Icons.dark_mode;
      case ThemeMode.system:
        // Show the icon based on current system theme.

        final systemBrightness = MediaQuery.platformBrightnessOf(context);
        return systemBrightness == Brightness.light
            ? (config.lightModeIcon ?? Icons.wb_sunny_outlined)
            : (config.darkModeIcon ?? Icons.dark_mode);
    }
  }

  /// Returns the next theme mode using adaptive toggle logic with context.
  /// Uses MediaQuery for real-time system theme detection.

  static ThemeMode getNextThemeModeWithContext(
    BuildContext context,
    ThemeMode currentMode,
  ) {
    switch (currentMode) {
      case ThemeMode.system:
        // Use MediaQuery for real-time system theme detection.

        final systemBrightness = MediaQuery.platformBrightnessOf(context);
        return systemBrightness == Brightness.light
            ? ThemeMode.dark
            : ThemeMode.light;

      case ThemeMode.light:
      case ThemeMode.dark:
        // Return to System mode.

        return ThemeMode.system;
    }
  }

  /// Returns the next theme mode using adaptive toggle logic.

  static ThemeMode getNextThemeMode(
    ThemeMode currentMode,
    SolidThemeModeConfig? modeConfig,
  ) {
    switch (currentMode) {
      case ThemeMode.system:
        // Return opposite of current system theme.

        final systemBrightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        return systemBrightness == Brightness.light
            ? ThemeMode.dark
            : ThemeMode.light;

      case ThemeMode.light:
      case ThemeMode.dark:
        // Return to System mode.

        return ThemeMode.system;
    }
  }

  /// Builds the theme mode icon using context for real-time theme.

  static Widget buildSystemModeIcon({
    double iconSize = 24.0,
    BuildContext? context,
    ThemeMode currentMode = ThemeMode.system,
  }) {
    Brightness systemBrightness;
    if (context != null) {
      systemBrightness = MediaQuery.platformBrightnessOf(context);
    } else {
      systemBrightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
    }

    // When in Light or Dark mode, show the current system theme icon.

    if (currentMode != ThemeMode.system) {
      final systemIcon = systemBrightness == Brightness.light
          ? Icons.wb_sunny_outlined
          : Icons.dark_mode;
      return Icon(systemIcon, size: iconSize);
    }

    // When in System mode, show the opposite of current theme mode.

    final nextModeIcon = systemBrightness == Brightness.light
        ? Icons.dark_mode
        : Icons.wb_sunny_outlined;

    return Icon(nextModeIcon, size: iconSize);
  }

  /// Gets the current theme mode based on internal management.

  static ThemeMode getCurrentThemeMode(
    bool usesInternalManagement,
    SolidThemeNotifier solidThemeNotifier,
    SolidThemeToggleConfig? themeToggle,
  ) {
    if (usesInternalManagement) {
      return solidThemeNotifier.themeMode;
    }
    return themeToggle?.currentThemeMode ?? ThemeMode.system;
  }

  /// Gets theme toggle callback.

  static VoidCallback? getThemeToggleCallback(
    bool usesInternalManagement,
    SolidThemeNotifier solidThemeNotifier,
    SolidThemeToggleConfig? themeToggle,
  ) {
    if (usesInternalManagement) {
      return () {
        solidThemeNotifier.toggleTheme();
      };
    }
    return themeToggle?.onToggleTheme;
  }

  /// Checks if uses internal management.

  static bool getUsesInternalManagement(SolidThemeToggleConfig? themeToggle) {
    return themeToggle?.usesInternalManagement ?? false;
  }
}
