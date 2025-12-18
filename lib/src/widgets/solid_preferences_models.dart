/// Models for user preferences configuration in Solid applications.
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

/// Represents an AppBar action item that can be reordered and configured
/// for overflow behaviour.

class SolidAppBarActionItem {
  /// Unique identifier for this action item.

  final String id;

  /// Display label for the action.

  final String label;

  /// Icon for the action.

  final IconData icon;

  /// Whether this item should appear in the overflow menu when screen is narrow.

  final bool showInOverflow;

  /// Whether this item is visible in the AppBar.

  final bool isVisible;

  /// Priority order for display (lower numbers appear first).

  final int order;

  const SolidAppBarActionItem({
    required this.id,
    required this.label,
    required this.icon,
    this.showInOverflow = false,
    this.isVisible = true,
    this.order = 0,
  });

  /// Creates a copy of this item with the given fields replaced.

  SolidAppBarActionItem copyWith({
    String? id,
    String? label,
    IconData? icon,
    bool? showInOverflow,
    bool? isVisible,
    int? order,
  }) {
    return SolidAppBarActionItem(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      showInOverflow: showInOverflow ?? this.showInOverflow,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
    );
  }
}

/// Configuration for theme mode availability in the theme toggle cycle.

class SolidThemeModeConfig {
  /// Whether light mode is available in the toggle cycle.

  final bool lightModeEnabled;

  /// Whether dark mode is available in the toggle cycle.

  final bool darkModeEnabled;

  /// Whether system mode is available in the toggle cycle.

  final bool systemModeEnabled;

  /// Whether to use smart toggle behaviour when all three modes are enabled.
  ///
  /// When true (default): In System mode, detects current system brightness
  /// and switches to the opposite mode, then toggles between Light and Dark.
  ///
  /// When false: Mechanically cycles through all three modes in order:
  /// System → Light → Dark → System...

  final bool smartToggle;

  const SolidThemeModeConfig({
    this.lightModeEnabled = true,
    this.darkModeEnabled = true,
    this.systemModeEnabled = true,
    this.smartToggle = true,
  });

  /// Returns the list of enabled theme modes.

  List<ThemeMode> get enabledModes {
    final modes = <ThemeMode>[];
    if (systemModeEnabled) modes.add(ThemeMode.system);
    if (lightModeEnabled) modes.add(ThemeMode.light);
    if (darkModeEnabled) modes.add(ThemeMode.dark);
    return modes;
  }

  /// Creates a copy with modified values.

  SolidThemeModeConfig copyWith({
    bool? lightModeEnabled,
    bool? darkModeEnabled,
    bool? systemModeEnabled,
    bool? smartToggle,
  }) {
    return SolidThemeModeConfig(
      lightModeEnabled: lightModeEnabled ?? this.lightModeEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      systemModeEnabled: systemModeEnabled ?? this.systemModeEnabled,
      smartToggle: smartToggle ?? this.smartToggle,
    );
  }

  /// Validates that at least one mode is enabled.

  bool get isValid =>
      lightModeEnabled || darkModeEnabled || systemModeEnabled;
}

/// Complete preferences configuration for SolidScaffold.

class SolidPreferencesConfig {
  /// Configuration for which theme modes are enabled.

  final SolidThemeModeConfig themeModeConfig;

  /// Ordered list of AppBar action items with their visibility and overflow settings.

  final List<SolidAppBarActionItem> appBarActions;

  const SolidPreferencesConfig({
    this.themeModeConfig = const SolidThemeModeConfig(),
    this.appBarActions = const [],
  });

  /// Creates a copy with modified values.

  SolidPreferencesConfig copyWith({
    SolidThemeModeConfig? themeModeConfig,
    List<SolidAppBarActionItem>? appBarActions,
  }) {
    return SolidPreferencesConfig(
      themeModeConfig: themeModeConfig ?? this.themeModeConfig,
      appBarActions: appBarActions ?? this.appBarActions,
    );
  }
}

/// Standard AppBar action IDs used by SolidScaffold.

class SolidAppBarActionIds {
  static const String themeToggle = 'theme_toggle';
  static const String about = 'about';
  static const String logout = 'logout';
  static const String preferences = 'preferences';

  SolidAppBarActionIds._();
}
