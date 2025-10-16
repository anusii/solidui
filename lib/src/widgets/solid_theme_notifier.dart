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

  /// Toggles between theme modes.
  /// On first toggle from System mode, switches to Light mode.
  /// Afterwards, toggles only between Light and Dark modes.

  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.light);
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
