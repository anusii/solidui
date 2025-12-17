/// Theme notifier for managing application-wide theme state.
///
// Time-stamp: <Monday 2025-08-25 15:30:00 +1000 Tony Chen>
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
import 'package:solidui/src/widgets/solid_preferences_notifier.dart';

/// Notifier for managing theme state across the application.

class SolidThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  /// Creates a new SolidThemeNotifier.

  SolidThemeNotifier();

  /// The current theme mode.

  ThemeMode get themeMode => _themeMode;

  /// Whether the notifier has been initialised.

  bool get isInitialized => _isInitialized;

  /// Initialises the notifier.

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  /// Sets a specific theme mode.

  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    notifyListeners();
  }

  /// Gets the enabled theme modes from preferences.

  List<ThemeMode> _getEnabledModes() {
    return solidPreferencesNotifier.themeModeConfig.enabledModes;
  }

  /// Toggles between theme modes based on the enabled modes in preferences.

  void toggleTheme() {
    final enabledModes = _getEnabledModes();

    // If no modes are enabled (shouldn't happen), do nothing.

    if (enabledModes.isEmpty) return;

    // If only one mode is enabled, set to that mode.

    if (enabledModes.length == 1) {
      setThemeMode(enabledModes.first);
      return;
    }

    // Find the current mode index in enabled modes.

    final currentIndex = enabledModes.indexOf(_themeMode);

    if (currentIndex == -1) {
      // Current mode is not enabled, switch to first enabled mode.

      setThemeMode(enabledModes.first);
      return;
    }

    // Handle special case for System mode: switch to opposite of system brightness.

    if (_themeMode == ThemeMode.system) {
      final systemBrightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      final targetMode = systemBrightness == Brightness.light
          ? ThemeMode.dark
          : ThemeMode.light;

      // Check if target mode is enabled.

      if (enabledModes.contains(targetMode)) {
        setThemeMode(targetMode);
      } else {
        // Target mode not enabled, go to next enabled mode.

        final nextIndex = (currentIndex + 1) % enabledModes.length;
        setThemeMode(enabledModes[nextIndex]);
      }
      return;
    }

    // Cycle to the next enabled mode.

    final nextIndex = (currentIndex + 1) % enabledModes.length;
    setThemeMode(enabledModes[nextIndex]);
  }

  /// Returns the tooltip message for the current theme mode based on enabled
  /// modes.

  String getTooltipForCurrentMode(SolidThemeModeConfig config) {
    final enabledModes = config.enabledModes;

    if (enabledModes.length == 1) {
      return _getSingleModeTooltip(_themeMode);
    }

    return _getMultipleModeTooltip(_themeMode, enabledModes);
  }

  String _getSingleModeTooltip(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '''

  **Theme:** **Light Mode** is active and is the only enabled mode.

  ''';
      case ThemeMode.dark:
        return '''

  **Theme:** **Dark Mode** is active and is the only enabled mode.

  ''';
      case ThemeMode.system:
        return '''

  **Theme:** **System Mode** is active and is the only enabled mode.
  The theme follows your device settings.

  ''';
    }
  }

  String _getMultipleModeTooltip(ThemeMode mode, List<ThemeMode> enabledModes) {
    final modeNames = enabledModes.map((m) {
      switch (m) {
        case ThemeMode.light:
          return 'Light';
        case ThemeMode.dark:
          return 'Dark';
        case ThemeMode.system:
          return 'System';
      }
    }).join(', ');

    switch (mode) {
      case ThemeMode.light:
        return '''

  **Theme:** Currently **Light Mode** is active. Light Mode is best for
  viewing in light conditions. Tap to toggle between enabled modes: $modeNames.

  ''';
      case ThemeMode.dark:
        return '''

  **Theme:** Currently **Dark Mode** is active. Dark Mode is best for viewing in
  low light conditions. Tap to toggle between enabled modes: $modeNames.

  ''';
      case ThemeMode.system:
        return '''

  **Theme:** Currently **System Mode** is active. System Mode follows your
  device settings. Tap to toggle between enabled modes: $modeNames.

  ''';
    }
  }

  /// Disposes of the notifier.

  @override
  void dispose() {
    super.dispose();
  }
}

/// Global instance of the theme notifier.

final SolidThemeNotifier solidThemeNotifier = SolidThemeNotifier();
