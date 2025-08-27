/// Theme notifier for managing application-wide theme state.
///
// Time-stamp: <Monday 2025-08-25 15:30:00 +1000 Tony Chen>
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

import 'package:shared_preferences/shared_preferences.dart';

class SolidThemeNotifier extends ChangeNotifier {
  static const String _themeModeKey = 'solid_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  /// Creates a new SolidThemeNotifier.
  ///
  /// Call [initialize] to load the saved theme mode.

  SolidThemeNotifier();

  /// The current theme mode.

  ThemeMode get themeMode => _themeMode;

  /// Whether the notifier has been initialised.

  bool get isInitialized => _isInitialized;

  /// Initialises the notifier by loading the saved theme mode.
  ///
  /// This should be called once during app initialisation.

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadThemeMode();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing SolidThemeNotifier: $e');
      _isInitialized = true; // Mark as initialized even if loading failed
    }
  }

  /// Loads the theme mode from SharedPreferences.

  Future<void> _loadThemeMode() async {
    if (_prefs == null) return;

    final String? themeModeString = _prefs!.getString(_themeModeKey);
    if (themeModeString != null) {
      final ThemeMode newThemeMode;
      switch (themeModeString) {
        case 'light':
          newThemeMode = ThemeMode.light;
          break;
        case 'dark':
          newThemeMode = ThemeMode.dark;
          break;
        case 'system':
          newThemeMode = ThemeMode.system;
          break;
        default:
          newThemeMode = ThemeMode.system;
          break;
      }

      // Only update and notify if the theme mode actually changed.

      if (_themeMode != newThemeMode) {
        _themeMode = newThemeMode;
        notifyListeners();
      }
    }
  }

  /// Saves the current theme mode to SharedPreferences.

  Future<void> _saveThemeMode() async {
    if (_prefs == null) return;

    String themeModeString;
    switch (_themeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }

    await _prefs!.setString(_themeModeKey, themeModeString);
  }

  /// Sets a specific theme mode.

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    notifyListeners();
    await _saveThemeMode();
  }

  /// Toggles between theme modes in the cycle: System → Light → Dark → System.

  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
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
