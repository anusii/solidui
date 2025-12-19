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

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:solidui/src/widgets/solid_preferences_models.dart';

/// SharedPreferences keys for storing preferences.

class _PreferencesKeys {
  static const String lightModeEnabled = 'solidui_light_mode_enabled';
  static const String darkModeEnabled = 'solidui_dark_mode_enabled';
  static const String systemModeEnabled = 'solidui_system_mode_enabled';
  static const String smartToggle = 'solidui_smart_toggle';
  static const String appBarActions = 'solidui_appbar_actions';

  _PreferencesKeys._();
}

/// Notifier for managing preferences state across the application.
/// Preferences are automatically persisted to SharedPreferences.

class SolidPreferencesNotifier extends ChangeNotifier {
  SolidPreferencesConfig _config;
  bool _isInitialized = false;

  /// Creates a new SolidPreferencesNotifier with optional initial configuration.

  SolidPreferencesNotifier([SolidPreferencesConfig? initialConfig])
      : _config = initialConfig ?? const SolidPreferencesConfig();

  /// Whether the notifier has been initialised from SharedPreferences.

  bool get isInitialized => _isInitialized;

  /// The current preferences configuration.

  SolidPreferencesConfig get config => _config;

  /// The current theme mode configuration.

  SolidThemeModeConfig get themeModeConfig => _config.themeModeConfig;

  /// The current AppBar action items.

  List<SolidAppBarActionItem> get appBarActions => _config.appBarActions;

  /// Initialises the notifier by loading preferences from SharedPreferences.

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode configuration.

      final lightModeEnabled =
          prefs.getBool(_PreferencesKeys.lightModeEnabled) ?? true;
      final darkModeEnabled =
          prefs.getBool(_PreferencesKeys.darkModeEnabled) ?? true;
      final systemModeEnabled =
          prefs.getBool(_PreferencesKeys.systemModeEnabled) ?? true;
      final smartToggle = prefs.getBool(_PreferencesKeys.smartToggle) ?? true;

      final themeModeConfig = SolidThemeModeConfig(
        lightModeEnabled: lightModeEnabled,
        darkModeEnabled: darkModeEnabled,
        systemModeEnabled: systemModeEnabled,
        smartToggle: smartToggle,
      );

      // Load AppBar actions if stored.

      List<SolidAppBarActionItem> appBarActions = [];
      final actionsJson = prefs.getString(_PreferencesKeys.appBarActions);
      if (actionsJson != null) {
        try {
          final List<dynamic> actionsList = jsonDecode(actionsJson);
          appBarActions = actionsList
              .map((json) => _appBarActionItemFromJson(json))
              .toList();
        } catch (e) {
          debugPrint('Error parsing stored AppBar actions: $e');
        }
      }

      _config = SolidPreferencesConfig(
        themeModeConfig: themeModeConfig,
        appBarActions: appBarActions,
      );

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing preferences: $e');
      _isInitialized = true;
    }
  }

  /// Updates the entire preferences configuration.

  void setConfig(SolidPreferencesConfig config) {
    if (_config == config) return;
    _config = config;
    _savePreferences();
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
    _saveThemeModeConfig();
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
    final newConfig =
        _config.themeModeConfig.copyWith(darkModeEnabled: enabled);
    if (!newConfig.isValid) return;
    setThemeModeConfig(newConfig);
  }

  /// Sets whether system mode is enabled in the toggle cycle.

  void setSystemModeEnabled(bool enabled) {
    final newConfig =
        _config.themeModeConfig.copyWith(systemModeEnabled: enabled);
    if (!newConfig.isValid) return;
    setThemeModeConfig(newConfig);
  }

  /// Sets whether smart toggle behaviour is enabled.

  void setSmartToggle(bool enabled) {
    final newConfig = _config.themeModeConfig.copyWith(smartToggle: enabled);
    setThemeModeConfig(newConfig);
  }

  /// Updates the AppBar action items.

  void setAppBarActions(List<SolidAppBarActionItem> actions) {
    _config = _config.copyWith(appBarActions: actions);
    _saveAppBarActions();
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
    _saveAppBarActions();
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
    _saveAppBarActions();
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
    _saveAppBarActions();
    notifyListeners();
  }

  /// Saves all preferences to SharedPreferences.

  Future<void> _savePreferences() async {
    await _saveThemeModeConfig();
    await _saveAppBarActions();
  }

  /// Saves theme mode configuration to SharedPreferences.

  Future<void> _saveThemeModeConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        _PreferencesKeys.lightModeEnabled,
        _config.themeModeConfig.lightModeEnabled,
      );
      await prefs.setBool(
        _PreferencesKeys.darkModeEnabled,
        _config.themeModeConfig.darkModeEnabled,
      );
      await prefs.setBool(
        _PreferencesKeys.systemModeEnabled,
        _config.themeModeConfig.systemModeEnabled,
      );
      await prefs.setBool(
        _PreferencesKeys.smartToggle,
        _config.themeModeConfig.smartToggle,
      );
    } catch (e) {
      debugPrint('Error saving theme mode config: $e');
    }
  }

  /// Saves AppBar actions to SharedPreferences.

  Future<void> _saveAppBarActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_config.appBarActions.isEmpty) {
        await prefs.remove(_PreferencesKeys.appBarActions);
      } else {
        final actionsJson = jsonEncode(
          _config.appBarActions.map((a) => _appBarActionItemToJson(a)).toList(),
        );
        await prefs.setString(_PreferencesKeys.appBarActions, actionsJson);
      }
    } catch (e) {
      debugPrint('Error saving AppBar actions: $e');
    }
  }

  /// Converts an AppBarActionItem to JSON.

  Map<String, dynamic> _appBarActionItemToJson(SolidAppBarActionItem item) {
    return {
      'id': item.id,
      'label': item.label,
      'icon': item.icon.codePoint,
      'showInOverflow': item.showInOverflow,
      'isVisible': item.isVisible,
      'order': item.order,
    };
  }

  /// Creates an AppBarActionItem from JSON.

  SolidAppBarActionItem _appBarActionItemFromJson(Map<String, dynamic> json) {
    return SolidAppBarActionItem(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      showInOverflow: json['showInOverflow'] as bool? ?? false,
      isVisible: json['isVisible'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
    );
  }
}

/// Global instance of the preferences notifier.

final SolidPreferencesNotifier solidPreferencesNotifier =
    SolidPreferencesNotifier();
