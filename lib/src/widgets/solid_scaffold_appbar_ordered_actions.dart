/// AppBar ordered actions builder for Solid Scaffold.
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

import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:solidui/src/widgets/solid_about_button.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_dynamic_auth_button.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_notification_button.dart';
import 'package:solidui/src/widgets/solid_preferences_models.dart';
import 'package:solidui/src/widgets/solid_scaffold_appbar_actions.dart';
import 'package:solidui/src/widgets/solid_scaffold_appbar_visibility.dart';
import 'package:solidui/src/widgets/solid_scaffold_helpers.dart';
import 'package:solidui/src/widgets/solid_theme_models.dart';

/// Builds ordered action buttons for AppBar.

class SolidAppBarOrderedActionsBuilder {
  /// Builds ordered action buttons based on preferences configuration.
  /// On wide screens: shows all visible buttons (ignores showInOverflow).
  /// On narrow screens: shows buttons marked as "add to appbar"
  /// (showInOverflow = false), others go to overflow menu.

  static List<Widget> build({
    required SolidAppBarConfig config,
    required double layoutWidth,
    required SolidThemeToggleConfig? themeToggle,
    required ThemeMode currentThemeMode,
    required VoidCallback? themeToggleCallback,
    required SolidAboutConfig aboutConfig,
    required BuildContext context,
    bool showLogout = true,
    bool showLogin = true,
    bool showNotifications = false,
    void Function(BuildContext)? onLogout,
    void Function(BuildContext)? onLogin,
  }) {
    final List<_OrderedAction> orderedActions = [];
    final isVeryNarrowScreen = layoutWidth < config.veryNarrowScreenThreshold;

    _addNotificationButton(
      orderedActions,
      showNotifications,
      isVeryNarrowScreen,
    );
    _addThemeToggle(
      orderedActions,
      themeToggle,
      config,
      layoutWidth,
      isVeryNarrowScreen,
      currentThemeMode,
      themeToggleCallback,
    );
    _addCustomActions(orderedActions, config, layoutWidth, isVeryNarrowScreen);
    _addOverflowItems(orderedActions, config, isVeryNarrowScreen);
    _addAuthButton(
      orderedActions,
      showLogout,
      showLogin,
      onLogout,
      onLogin,
      isVeryNarrowScreen,
      context,
    );
    _addAboutButton(
      orderedActions,
      aboutConfig,
      config,
      layoutWidth,
      isVeryNarrowScreen,
    );

    orderedActions.sort((a, b) => a.order.compareTo(b.order));
    return orderedActions.map((a) => a.widget).toList();
  }

  static void _addThemeToggle(
    List<_OrderedAction> orderedActions,
    SolidThemeToggleConfig? themeToggle,
    SolidAppBarConfig config,
    double layoutWidth,
    bool isVeryNarrowScreen,
    ThemeMode currentThemeMode,
    VoidCallback? themeToggleCallback,
  ) {
    if (themeToggle == null || !themeToggle.enabled) return;

    final actionConfig = SolidAppBarActionsManager.getActionConfig(
      SolidAppBarActionIds.themeToggle,
    );
    final isVisible = actionConfig?.isVisible ?? true;
    final isInOverflow = actionConfig?.showInOverflow ?? false;
    final order = actionConfig?.order ?? 0;

    final shouldShow = isVisible &&
        (!isVeryNarrowScreen || !isInOverflow) &&
        SolidAppBarVisibilityHelper.shouldShowThemeToggle(
          themeToggle,
          config,
          layoutWidth,
        );

    if (shouldShow) {
      orderedActions.add(
        _OrderedAction(
          order: order,
          widget: SolidScaffoldHelpers.buildThemeToggleButton(
            themeToggle,
            currentThemeMode,
            themeToggleCallback,
          ),
        ),
      );
    }
  }

  static void _addNotificationButton(
    List<_OrderedAction> orderedActions,
    bool showNotifications,
    bool isVeryNarrowScreen,
  ) {
    if (!showNotifications) return;

    final actionConfig = SolidAppBarActionsManager.getActionConfig(
      SolidAppBarActionIds.notifications,
    );
    final isVisible = actionConfig?.isVisible ?? true;
    final isInOverflow = actionConfig?.showInOverflow ?? false;
    final order = actionConfig?.order ?? 800;

    if (isVisible && (!isVeryNarrowScreen || !isInOverflow)) {
      orderedActions.add(
        _OrderedAction(
          order: order,
          widget: const SolidNotificationButton(
            key: ValueKey('solid_notifications'),
          ),
        ),
      );
    }
  }

  static void _addCustomActions(
    List<_OrderedAction> orderedActions,
    SolidAppBarConfig config,
    double layoutWidth,
    bool isVeryNarrowScreen,
  ) {
    for (int i = 0; i < config.actions.length; i++) {
      final action = config.actions[i];
      final actionId = action.id ?? 'action_$i';
      final actionConfig = SolidAppBarActionsManager.getActionConfig(actionId);
      final isVisible = actionConfig?.isVisible ?? true;
      final isInOverflow = actionConfig?.showInOverflow ?? false;
      final order = actionConfig?.order ?? (100 + i);

      final shouldShow = isVisible &&
          (!isVeryNarrowScreen || !isInOverflow) &&
          SolidAppBarVisibilityHelper.shouldShowAction(
            action,
            config,
            layoutWidth,
          );

      if (shouldShow) {
        Widget iconButton = IconButton(
          icon: Icon(action.icon, size: 22),
          onPressed: action.onPressed,
          color: action.color,
          splashRadius: 20,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        );

        if (action.tooltip != null) {
          iconButton = MarkdownTooltip(
            message: action.tooltip!,
            child: iconButton,
          );
        }

        orderedActions.add(_OrderedAction(order: order, widget: iconButton));
      }
    }
  }

  static void _addOverflowItems(
    List<_OrderedAction> orderedActions,
    SolidAppBarConfig config,
    bool isVeryNarrowScreen,
  ) {
    for (int i = 0; i < config.overflowItems.length; i++) {
      final item = config.overflowItems[i];
      final actionConfig = SolidAppBarActionsManager.getActionConfig(item.id);
      final isVisible = actionConfig?.isVisible ?? true;
      final isInOverflow = actionConfig?.showInOverflow ?? true;
      final order = actionConfig?.order ?? (200 + i);

      if (isVisible && (!isVeryNarrowScreen || !isInOverflow)) {
        Widget iconButton = IconButton(
          icon: Icon(item.icon, size: 22),
          onPressed: item.onSelected,
          splashRadius: 20,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        );

        iconButton = MarkdownTooltip(message: item.label, child: iconButton);
        orderedActions.add(_OrderedAction(order: order, widget: iconButton));
      }
    }
  }

  /// Adds a dynamic login/logout button that automatically switches
  /// between login and logout states based on authentication status.
  /// When [showLogout] is false, only the login button is shown when logged out.

  static void _addAuthButton(
    List<_OrderedAction> orderedActions,
    bool showLogout,
    bool showLogin,
    void Function(BuildContext)? onLogout,
    void Function(BuildContext)? onLogin,
    bool isVeryNarrowScreen,
    BuildContext context,
  ) {
    final actionConfig = SolidAppBarActionsManager.getActionConfig(
      SolidAppBarActionIds.logout,
    );
    final isVisible = actionConfig?.isVisible ?? true;
    final isInOverflow = actionConfig?.showInOverflow ?? false;
    final order = actionConfig?.order ?? 400;

    if (isVisible && (!isVeryNarrowScreen || !isInOverflow)) {
      orderedActions.add(
        _OrderedAction(
          order: order,
          widget: SolidDynamicAuthButton(
            showLogout: showLogout,
            showLogin: showLogin,
            onLogout: onLogout,
            onLogin: onLogin,
          ),
        ),
      );
    }
  }

  static void _addAboutButton(
    List<_OrderedAction> orderedActions,
    SolidAboutConfig aboutConfig,
    SolidAppBarConfig config,
    double layoutWidth,
    bool isVeryNarrowScreen,
  ) {
    if (!aboutConfig.enabled ||
        !aboutConfig.shouldShow(
          layoutWidth,
          config.narrowScreenThreshold,
          config.veryNarrowScreenThreshold,
        )) {
      return;
    }

    final actionConfig = SolidAppBarActionsManager.getActionConfig(
      SolidAppBarActionIds.about,
    );
    final isVisible = actionConfig?.isVisible ?? true;
    final isInOverflow = actionConfig?.showInOverflow ?? false;
    final order = actionConfig?.order ?? 999999;

    if (isVisible && (!isVeryNarrowScreen || !isInOverflow)) {
      orderedActions.add(
        _OrderedAction(
          order: order,
          widget: SolidAboutButton(config: aboutConfig),
        ),
      );
    }
  }
}

/// Helper class for building ordered action widgets.

class _OrderedAction {
  final int order;
  final Widget widget;
  _OrderedAction({required this.order, required this.widget});
}
