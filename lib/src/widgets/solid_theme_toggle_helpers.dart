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
    // Determine the tooltip message based on enabled modes.

    final themeModeConfig = solidPreferencesNotifier.themeModeConfig;
    String tooltipMessage;
    if (themeConfig.tooltip != null) {
      tooltipMessage = themeConfig.tooltip!;
    } else {
      tooltipMessage =
          solidThemeNotifier.getTooltipForCurrentMode(themeModeConfig);
    }

    Widget iconWidget;

    // Get the next mode to determine which icon to show.

    final nextMode = getNextThemeMode(currentThemeMode, themeModeConfig);

    // Only show the system mode icon (with 'A' badge) when the next mode is
    // system mode.

    if (nextMode == ThemeMode.system) {
      iconWidget = buildSystemModeIcon();
    } else {
      iconWidget =
          Icon(themeConfig.getNextIcon(currentThemeMode, themeModeConfig));
    }

    Widget themeButton = IconButton(
      icon: iconWidget,
      onPressed: themeToggleCallback,
    );

    return MarkdownTooltip(
      message: tooltipMessage,
      child: themeButton,
    );
  }

  /// Returns the next theme mode in the cycle.

  static ThemeMode getNextThemeMode(
    ThemeMode currentMode,
    SolidThemeModeConfig? modeConfig,
  ) {
    final enabledModes = modeConfig?.enabledModes ??
        [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    final smartToggle = modeConfig?.smartToggle ?? true;

    final currentIndex = enabledModes.indexOf(currentMode);

    if (currentIndex == -1 || enabledModes.length <= 1) {
      return currentMode;
    }

    // Special handling for system mode with smart toggle enabled.

    if (currentMode == ThemeMode.system &&
        smartToggle &&
        enabledModes.length == 3) {
      final systemBrightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      final targetMode = systemBrightness == Brightness.light
          ? ThemeMode.dark
          : ThemeMode.light;

      if (enabledModes.contains(targetMode)) {
        return targetMode;
      }
    }

    // Get the next mode in the cycle (sequential toggle).

    final nextIndex = (currentIndex + 1) % enabledModes.length;
    return enabledModes[nextIndex];
  }

  /// Builds the system mode icon with an 'A' badge.
  /// The icon is a sun (light) or moon (dark) based on the current system
  /// brightness, with the main icon centred and 'A' as a small badge in the
  /// bottom-right corner.

  static Widget buildSystemModeIcon({double iconSize = 24.0}) {
    final systemBrightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final baseIcon = systemBrightness == Brightness.light
        ? Icons.wb_sunny_outlined
        : Icons.dark_mode;

    // Use a fixed size container to keep the icon centred.
    // Use Builder to get context for theme-aware icon colour.

    return Builder(
      builder: (context) {
        final iconColor = IconTheme.of(context).color;

        return SizedBox(
          width: iconSize,
          height: iconSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Main icon centred.

              Icon(baseIcon, size: iconSize),

              // 'A' badge in the bottom-right corner, using outlined style
              // with the same colour as the icon.

              Positioned(
                right: -4,
                bottom: -4,
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: iconSize * 0.42,
                    fontWeight: FontWeight.w500,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1.2
                      ..color = iconColor ?? Colors.black,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
