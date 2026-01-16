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

import 'package:solidui/src/widgets/solid_preferences_models.dart';

/// Notifier for managing theme state across the application.
/// The theme always starts in System mode.

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
  /// Theme always starts in System mode.

  Future<void> initialize() async {
    if (_isInitialized) return;

    _themeMode = ThemeMode.system;
    _isInitialized = true;
    notifyListeners();
  }

  /// Sets a specific theme mode.

  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    notifyListeners();
  }

  /// Toggles between System mode and the opposite of current system mode.
  ///
  /// When in System mode, switches to the opposite of current system
  /// mode. When in Light or Dark mode, switches back to System mode.

  void toggleTheme() {
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
      case ThemeMode.dark:
        // Switch back to System mode.

        setThemeMode(ThemeMode.system);
        break;
    }
  }

  /// Returns the tooltip message for the current theme mode.

  String getTooltipForCurrentMode(SolidThemeModeConfig config) {
    switch (_themeMode) {
      case ThemeMode.light:
        return '''

  **Theme:** Currently **Light Mode** is active. Light Mode is best for
  viewing in light conditions. Tap to switch back to System Mode.

  ''';
      case ThemeMode.dark:
        return '''

  **Theme:** Currently **Dark Mode** is active. Dark Mode is best for viewing in
  low light conditions. Tap to switch back to System Mode.

  ''';
      case ThemeMode.system:
        return '''

  **Theme:** Currently **System Mode** is active. System Mode follows your
  device settings. Tap to switch to the opposite theme.

  ''';
    }
  }
}

/// Global instance of the theme notifier.

final SolidThemeNotifier solidThemeNotifier = SolidThemeNotifier();
