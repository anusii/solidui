/// Preferences notifier for managing application-wide preferences state.
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

import 'package:solidui/src/widgets/solid_preferences_models.dart';

/// Notifier for managing preferences state across the application.

class SolidPreferencesNotifier extends ChangeNotifier {
  SolidPreferencesConfig _config;

  /// Creates a new SolidPreferencesNotifier with optional initial configuration.

  SolidPreferencesNotifier([SolidPreferencesConfig? initialConfig])
      : _config = initialConfig ?? const SolidPreferencesConfig();

  /// The current preferences configuration.

  SolidPreferencesConfig get config => _config;

  /// The current theme mode configuration.

  SolidThemeModeConfig get themeModeConfig => _config.themeModeConfig;

  /// The current AppBar action items.

  List<SolidAppBarActionItem> get appBarActions => _config.appBarActions;

  /// Updates the entire preferences configuration.

  void setConfig(SolidPreferencesConfig config) {
    if (_config == config) return;
    _config = config;
    notifyListeners();
  }

  /// Updates only the theme mode configuration.

  void setThemeModeConfig(SolidThemeModeConfig themeModeConfig) {
    if (!themeModeConfig.isValid) {
      debugPrint(
        'Warning: Attempted to set invalid theme mode config (no modes enabled)',
      );
      return;
    }
    if (_config.themeModeConfig == themeModeConfig) return;
    _config = _config.copyWith(themeModeConfig: themeModeConfig);
    notifyListeners();
  }

  /// Sets whether light mode is enabled in the toggle cycle.

  void setLightModeEnabled(bool enabled) {
    final newConfig =
        _config.themeModeConfig.copyWith(lightModeEnabled: enabled);
    if (!newConfig.isValid) return;
    setThemeModeConfig(newConfig);
  }

  /// Sets whether dark mode is enabled in the toggle cycle.

  void setDarkModeEnabled(bool enabled) {
    final newConfig = _config.themeModeConfig.copyWith(darkModeEnabled: enabled);
    if (!newConfig.isValid) return;
    setThemeModeConfig(newConfig);
  }

  /// Sets whether system mode is enabled in the toggle cycle.

  void setSystemModeEnabled(bool enabled) {
    final newConfig = _config.themeModeConfig.copyWith(systemModeEnabled: enabled);
    if (!newConfig.isValid) return;
    setThemeModeConfig(newConfig);
  }

  /// Updates the AppBar action items.

  void setAppBarActions(List<SolidAppBarActionItem> actions) {
    _config = _config.copyWith(appBarActions: actions);
    notifyListeners();
  }

  /// Reorders an action item from one position to another.

  void reorderAppBarAction(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _config.appBarActions.length ||
        newIndex < 0 ||
        newIndex >= _config.appBarActions.length) {
      return;
    }

    final actions = List<SolidAppBarActionItem>.from(_config.appBarActions);
    final item = actions.removeAt(oldIndex);
    actions.insert(newIndex, item);

    // Update order values.

    final updatedActions = <SolidAppBarActionItem>[];
    for (int i = 0; i < actions.length; i++) {
      updatedActions.add(actions[i].copyWith(order: i));
    }

    _config = _config.copyWith(appBarActions: updatedActions);
    notifyListeners();
  }

  /// Toggles whether an action should appear in the overflow menu.

  void toggleActionOverflow(String actionId) {
    final actions = _config.appBarActions.map((action) {
      if (action.id == actionId) {
        return action.copyWith(showInOverflow: !action.showInOverflow);
      }
      return action;
    }).toList();

    _config = _config.copyWith(appBarActions: actions);
    notifyListeners();
  }

  /// Sets whether an action should appear in the overflow menu.

  void setActionOverflow(String actionId, bool showInOverflow) {
    final actions = _config.appBarActions.map((action) {
      if (action.id == actionId) {
        return action.copyWith(showInOverflow: showInOverflow);
      }
      return action;
    }).toList();

    _config = _config.copyWith(appBarActions: actions);
    notifyListeners();
  }

}

/// Global instance of the preferences notifier.

final SolidPreferencesNotifier solidPreferencesNotifier =
    SolidPreferencesNotifier();
