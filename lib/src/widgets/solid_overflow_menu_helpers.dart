/// Overflow menu helper functions for Solid Scaffold.
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

import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_preferences_models.dart';
import 'package:solidui/src/widgets/solid_preferences_notifier.dart';
import 'package:solidui/src/widgets/solid_theme_models.dart';
import 'package:solidui/src/widgets/solid_theme_toggle_helpers.dart';

/// Helper class for overflow menu operations.

class SolidOverflowMenuHelpers {
  /// Builds overflow menu items dynamically based on preferences configuration.

  static List<PopupMenuItem<String>> buildOverflowMenuItems(
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
    SolidAboutConfig aboutConfig,
    bool hasThemeToggleInOverflow,
    bool hasAboutInOverflow, {
    bool hasLogoutInOverflow = false,
    bool isLoggedIn = true,
  }) {
    List<PopupMenuItem<String>> items = [];
    final allActions = List<SolidAppBarActionItem>.from(
      solidPreferencesNotifier.appBarActions,
    )..sort((a, b) => a.order.compareTo(b.order));

    for (final actionItem in allActions) {
      if (!actionItem.isVisible || !actionItem.showInOverflow) continue;

      if (actionItem.id == SolidAppBarActionIds.themeToggle) {
        _addThemeToggle(
          items,
          hasThemeToggleInOverflow,
          themeToggle,
          currentThemeMode,
        );
      } else if (actionItem.id == SolidAppBarActionIds.logout) {
        _addAuthMenuItem(items, hasLogoutInOverflow, isLoggedIn);
      } else if (actionItem.id == SolidAppBarActionIds.about) {
        _addAbout(items, hasAboutInOverflow, aboutConfig);
      } else if (actionItem.id == SolidAppBarActionIds.notifications) {
        _addNotifications(items, actionItem);
      } else if (actionItem.id.startsWith('action_')) {
        _addCustomAction(items, actionItem, config);
      } else {
        _addCustomOverflow(items, actionItem, config);
      }
    }
    return items;
  }

  static void _addThemeToggle(
    List<PopupMenuItem<String>> items,
    bool hasThemeToggleInOverflow,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
  ) {
    if (!hasThemeToggleInOverflow || themeToggle == null) return;
    final themeModeConfig = solidPreferencesNotifier.themeModeConfig;
    String labelText;
    switch (currentThemeMode) {
      case ThemeMode.light:
        labelText = 'Switch to Dark Mode';
      case ThemeMode.dark:
        labelText = 'Switch to Light Mode';
      case ThemeMode.system:
        final brightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        labelText = brightness == Brightness.light
            ? 'Switch to Dark Mode'
            : 'Switch to Light Mode';
    }
    final nextMode = SolidThemeToggleHelpers.getNextThemeMode(
      currentThemeMode,
      themeModeConfig,
    );
    Widget icon = nextMode == ThemeMode.system
        ? SolidThemeToggleHelpers.buildSystemModeIcon(iconSize: 20.0)
        : Icon(themeToggle.getNextIcon(currentThemeMode, themeModeConfig));
    items.add(
      PopupMenuItem<String>(
        value: 'theme_toggle',
        child: Row(children: [icon, const SizedBox(width: 8), Text(labelText)]),
      ),
    );
  }

  /// Adds authentication menu item (login or logout) based on current state.

  static void _addAuthMenuItem(
    List<PopupMenuItem<String>> items,
    bool show,
    bool isLoggedIn,
  ) {
    if (!show) return;

    final icon = isLoggedIn ? Icons.logout : Icons.login;
    final label = isLoggedIn ? 'Logout' : 'Login';
    final value = isLoggedIn ? 'logout' : 'login';

    items.add(
      PopupMenuItem<String>(
        value: value,
        child: Row(
          children: [Icon(icon), const SizedBox(width: 8), Text(label)],
        ),
      ),
    );
  }

  static void _addAbout(
    List<PopupMenuItem<String>> items,
    bool show,
    SolidAboutConfig aboutConfig,
  ) {
    if (!show) return;
    items.add(
      PopupMenuItem<String>(
        value: 'about',
        child: Row(
          children: [
            Icon(aboutConfig.effectiveIcon),
            const SizedBox(width: 8),
            const Text('About'),
          ],
        ),
      ),
    );
  }

  static void _addNotifications(
    List<PopupMenuItem<String>> items,
    SolidAppBarActionItem actionItem,
  ) {
    items.add(
      PopupMenuItem<String>(
        value: SolidAppBarActionIds.notifications,
        child: Row(
          children: [
            Icon(actionItem.icon),
            const SizedBox(width: 8),
            Text(actionItem.label),
          ],
        ),
      ),
    );
  }

  static void _addCustomAction(
    List<PopupMenuItem<String>> items,
    SolidAppBarActionItem actionItem,
    SolidAppBarConfig config,
  ) {
    final actionIndex = int.tryParse(actionItem.id.replaceFirst('action_', ''));
    SolidAppBarAction? action;
    if (actionIndex != null && actionIndex < config.actions.length) {
      action = config.actions[actionIndex];
    } else {
      action = config.actions.cast<SolidAppBarAction?>().firstWhere(
            (a) => a?.id == actionItem.id,
            orElse: () => null,
          );
    }
    if (action != null) {
      items.add(
        PopupMenuItem<String>(
          value: actionItem.id,
          child: Row(
            children: [
              Icon(action.icon),
              const SizedBox(width: 8),
              Text(actionItem.label),
            ],
          ),
        ),
      );
    }
  }

  static void _addCustomOverflow(
    List<PopupMenuItem<String>> items,
    SolidAppBarActionItem actionItem,
    SolidAppBarConfig config,
  ) {
    final item = config.overflowItems.cast<SolidOverflowMenuItem?>().firstWhere(
          (item) => item?.id == actionItem.id,
          orElse: () => null,
        );
    if (item != null) {
      items.add(
        PopupMenuItem<String>(
          value: actionItem.id,
          child: Row(
            children: [
              Icon(item.icon),
              const SizedBox(width: 8),
              Text(actionItem.label),
            ],
          ),
        ),
      );
    }
  }

  /// Builds overflow icon buttons for wider screens.

  static List<Widget> buildOverflowIconButtons(SolidAppBarConfig config) {
    return config.overflowItems.map((item) {
      return MarkdownTooltip(
        message: item.label,
        child: IconButton(icon: Icon(item.icon), onPressed: item.onSelected),
      );
    }).toList();
  }
}
