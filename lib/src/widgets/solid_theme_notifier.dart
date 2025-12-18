/// Theme notifier for managing application-wide theme state.
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
import 'package:shared_preferences/shared_preferences.dart';

import 'package:solidui/src/widgets/solid_preferences_models.dart';
import 'package:solidui/src/widgets/solid_preferences_notifier.dart';

/// SharedPreferences key for storing the current theme mode.

const String _themeModeKey = 'solidui_theme_mode';

/// Notifier for managing theme state across the application.
/// The current theme mode is persisted to SharedPreferences.

class SolidThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  /// Creates a new SolidThemeNotifier.

  SolidThemeNotifier();

  /// The current theme mode.

  ThemeMode get themeMode => _themeMode;

  /// Whether the notifier has been initialised.

  bool get isInitialized => _isInitialized;

  /// Initialises the notifier by loading the saved theme mode from
  /// SharedPreferences.

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeModeKey);

      if (savedMode != null) {
        _themeMode = _themeModeFromString(savedMode);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initialising theme notifier: $e');
      _isInitialized = true;
    }
  }

  /// Sets a specific theme mode and persists it to SharedPreferences.

  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    _saveThemeMode();
    notifyListeners();
  }

  /// Saves the current theme mode to SharedPreferences.

  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeModeToString(_themeMode));
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  /// Converts a ThemeMode to a string for storage.

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  /// Converts a stored string back to a ThemeMode.

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Gets the enabled theme modes from preferences.

  List<ThemeMode> _getEnabledModes() {
    return solidPreferencesNotifier.themeModeConfig.enabledModes;
  }

  /// Toggles between theme modes based on the enabled modes in preferences.
  ///
  /// The toggle behaviour depends on the number of enabled modes:
  /// - Single mode: App stays in that single mode.
  /// - Two modes: Mechanically toggles between the two modes.
  /// - Three modes (all enabled): Behaviour depends on the smartToggle setting.
  ///   - Smart toggle ON: When in System mode, switches to the opposite of
  ///     system brightness, then cycles between Light and Dark.
  ///   - Smart toggle OFF: Mechanically cycles System → Light → Dark → System.

  void toggleTheme() {
    final enabledModes = _getEnabledModes();

    // If no modes are enabled (shouldn't happen), do nothing.

    if (enabledModes.isEmpty) return;

    // Case 1: Single mode enabled - stay in that mode.

    if (enabledModes.length == 1) {
      setThemeMode(enabledModes.first);
      return;
    }

    // Case 2: Two modes enabled - mechanically toggle between them.

    if (enabledModes.length == 2) {
      _toggleBetweenTwoModes(enabledModes);
      return;
    }

    // Case 3: All three modes enabled - check smartToggle setting.

    final smartToggle = solidPreferencesNotifier.themeModeConfig.smartToggle;
    if (smartToggle) {
      _toggleAllThreeModesSmart();
    } else {
      _toggleAllThreeModesSequential(enabledModes);
    }
  }

  /// Toggles mechanically between exactly two enabled modes.

  void _toggleBetweenTwoModes(List<ThemeMode> enabledModes) {
    final currentIndex = enabledModes.indexOf(_themeMode);

    if (currentIndex == -1) {
      // Current mode is not enabled, switch to first enabled mode.

      setThemeMode(enabledModes.first);
    } else {
      // Toggle to the other mode.

      final nextIndex = (currentIndex + 1) % 2;
      setThemeMode(enabledModes[nextIndex]);
    }
  }

  /// Toggles with smart logic when all three modes are enabled.
  /// System mode → opposite of system brightness → remaining mode → cycle.

  void _toggleAllThreeModesSmart() {
    switch (_themeMode) {
      case ThemeMode.system:
        // Detect current system brightness and switch to the opposite mode.

        final systemBrightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        if (systemBrightness == Brightness.light) {
          setThemeMode(ThemeMode.dark);
        } else {
          setThemeMode(ThemeMode.light);
        }
        break;

      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;

      case ThemeMode.dark:
        setThemeMode(ThemeMode.light);
        break;
    }
  }

  /// Toggles sequentially through all three modes: System → Light → Dark.

  void _toggleAllThreeModesSequential(List<ThemeMode> enabledModes) {
    final currentIndex = enabledModes.indexOf(_themeMode);

    if (currentIndex == -1) {
      // Current mode is not in list, switch to first enabled mode.

      setThemeMode(enabledModes.first);
    } else {
      // Cycle to next mode in sequence.

      final nextIndex = (currentIndex + 1) % enabledModes.length;
      setThemeMode(enabledModes[nextIndex]);
    }
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
}

/// Global instance of the theme notifier.

final SolidThemeNotifier solidThemeNotifier = SolidThemeNotifier();
