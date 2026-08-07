/// AppBar overflow menu handling for Solid Scaffold.
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

import 'package:solidpod/solidpod.dart' show getWebId, isUserLoggedIn;

import 'package:solidui/src/handlers/solid_auth_handler.dart';
import 'package:solidui/src/widgets/solid_about_button.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_invite_others.dart';
import 'package:solidui/src/widgets/solid_invite_others_models.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_notification_centre.dart';
import 'package:solidui/src/widgets/solid_preferences_models.dart';
import 'package:solidui/src/widgets/solid_preferences_notifier.dart';
import 'package:solidui/src/widgets/solid_scaffold_appbar_actions.dart';
import 'package:solidui/src/widgets/solid_scaffold_helpers.dart';
import 'package:solidui/src/widgets/solid_theme_models.dart';

/// Handles overflow menu logic for AppBar.

class SolidAppBarOverflowHandler {
  /// Handles overflow menu on narrow screens.

  static void handleOverflowMenu(
    List<Widget> actions,
    SolidAppBarConfig config,
    double layoutWidth,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
    VoidCallback? themeToggleCallback,
    SolidAboutConfig aboutConfig,
    BuildContext context, {
    bool showLogout = true,
    bool showLogin = true,
    void Function(BuildContext)? onLogout,
    void Function(BuildContext)? onLogin,
    SolidInviteOthersConfig? inviteConfig,
    bool profileEnabled = false,
    bool enableOverflowMenu = true,
  }) {
    // When the overflow feature is disabled at scaffold level, never render
    // the three-dot menu; every visible button stays in the AppBar.

    if (!enableOverflowMenu) return;

    final isVeryNarrowScreen = layoutWidth < config.veryNarrowScreenThreshold;

    // Only show overflow menu on very narrow screens.
    // On wider screens, all buttons are displayed directly in AppBar.

    if (!isVeryNarrowScreen) return;

    // When profiles are enabled, the avatar popup hosts Logout/Login
    // and the About dialog hosts Share, so the overflow menu must
    // not duplicate those entries.

    final effectiveShowLogout = showLogout && !profileEnabled;
    final effectiveInviteConfig = profileEnabled ? null : inviteConfig;

    // Skip rendering the overflow button when no visible action is actually
    // routed into the overflow menu. This keeps the AppBar tidy when the
    // user (or the application defaults) leaves the menu empty.

    if (!_hasItemsInOverflow(themeToggle, aboutConfig, effectiveShowLogout)) {
      return;
    }

    final overflowIds = config.defaultOverflowActionIds;

    actions.add(
      _buildOverflowMenu(
        config,
        themeToggle,
        currentThemeMode,
        themeToggleCallback,
        aboutConfig,
        shouldShowThemeToggleInOverflow(
          themeToggle,
          forceOverflow: true,
          defaultOverflowActionIds: overflowIds,
        ),
        shouldShowAboutInOverflow(
          aboutConfig,
          forceOverflow: true,
          defaultOverflowActionIds: overflowIds,
        ),
        context,
        hasLogoutInOverflow: shouldShowLogoutInOverflow(
          effectiveShowLogout,
          forceOverflow: true,
        ),
        hasInviteOthersInOverflow: shouldShowInviteOthersInOverflow(
          effectiveInviteConfig,
          forceOverflow: true,
          defaultOverflowActionIds: overflowIds,
        ),
        inviteConfig: effectiveInviteConfig,
        onLogout: onLogout,
        onLogin: onLogin,
      ),
    );
  }

  /// Returns true when at least one visible AppBar action is configured to
  /// appear inside the overflow menu. Used to suppress the three-dot button
  /// when the menu would otherwise render empty.

  static bool _hasItemsInOverflow(
    SolidThemeToggleConfig? themeToggle,
    SolidAboutConfig aboutConfig,
    bool hasLogout,
  ) {
    final actions = solidPreferencesNotifier.appBarActions;
    for (final action in actions) {
      if (!action.isVisible || !action.showInOverflow) continue;

      // Filter out buttons whose underlying feature is disabled even though
      // the preference still lists them.

      if (action.id == SolidAppBarActionIds.themeToggle &&
          (themeToggle == null || !themeToggle.enabled)) {
        continue;
      }
      if (action.id == SolidAppBarActionIds.about && !aboutConfig.enabled) {
        continue;
      }
      if (action.id == SolidAppBarActionIds.logout && !hasLogout) {
        continue;
      }
      return true;
    }
    return false;
  }

  /// Determines if the Invite Others entry should appear in the
  /// overflow menu.

  static bool shouldShowInviteOthersInOverflow(
    SolidInviteOthersConfig? inviteConfig, {
    bool forceOverflow = false,
    Set<String> defaultOverflowActionIds = const {},
  }) {
    if (inviteConfig == null || !inviteConfig.enabled) return false;
    final actionConfig = SolidAppBarActionsManager.getActionConfig(
      SolidAppBarActionIds.inviteOthers,
    );
    final isVisible = actionConfig?.isVisible ?? true;
    if (!isVisible) return false;
    final isInOverflow = actionConfig?.showInOverflow ??
        defaultOverflowActionIds.contains(SolidAppBarActionIds.inviteOthers);
    if (forceOverflow) return isInOverflow;
    return isInOverflow;
  }

  /// Determines if logout should be shown in overflow menu.

  static bool shouldShowLogoutInOverflow(
    bool hasLogout, {
    bool forceOverflow = false,
    Set<String> defaultOverflowActionIds = const {},
  }) {
    if (!hasLogout) return false;
    final actionConfig = SolidAppBarActionsManager.getActionConfig(
      SolidAppBarActionIds.logout,
    );
    final isVisible = actionConfig?.isVisible ?? true;
    if (!isVisible) return false;

    final isInOverflow = actionConfig?.showInOverflow ??
        defaultOverflowActionIds.contains(SolidAppBarActionIds.logout);

    if (forceOverflow) return isInOverflow;
    return isInOverflow;
  }

  /// Determines if theme toggle should be shown in overflow menu.

  static bool shouldShowThemeToggleInOverflow(
    SolidThemeToggleConfig? themeToggle, {
    bool forceOverflow = false,
    Set<String> defaultOverflowActionIds = const {},
  }) {
    if (themeToggle == null || !themeToggle.enabled) return false;
    final actionConfig = SolidAppBarActionsManager.getActionConfig(
      SolidAppBarActionIds.themeToggle,
    );
    final isVisible = actionConfig?.isVisible ?? true;
    if (!isVisible) return false;

    final isInOverflow = actionConfig?.showInOverflow ??
        defaultOverflowActionIds.contains(SolidAppBarActionIds.themeToggle);

    if (forceOverflow) return isInOverflow;
    return isInOverflow;
  }

  /// Determines if about should be shown in overflow menu.

  static bool shouldShowAboutInOverflow(
    SolidAboutConfig aboutConfig, {
    bool forceOverflow = false,
    Set<String> defaultOverflowActionIds = const {},
  }) {
    if (!aboutConfig.enabled) return false;
    final actionConfig = SolidAppBarActionsManager.getActionConfig(
      SolidAppBarActionIds.about,
    );
    final isVisible = actionConfig?.isVisible ?? true;
    if (!isVisible) return false;

    final isInOverflow = actionConfig?.showInOverflow ??
        defaultOverflowActionIds.contains(SolidAppBarActionIds.about);

    if (forceOverflow) return isInOverflow;
    return isInOverflow;
  }

  /// Builds the overflow menu.
  /// Uses Builder to ensure context is valid during callbacks.

  static Widget _buildOverflowMenu(
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
    VoidCallback? themeToggleCallback,
    SolidAboutConfig aboutConfig,
    bool hasThemeToggleInOverflow,
    bool hasAboutInOverflow,
    BuildContext parentContext, {
    bool hasLogoutInOverflow = false,
    bool hasInviteOthersInOverflow = false,
    SolidInviteOthersConfig? inviteConfig,
    void Function(BuildContext)? onLogout,
    void Function(BuildContext)? onLogin,
  }) {
    return _DynamicOverflowMenu(
      config: config,
      themeToggle: themeToggle,
      currentThemeMode: currentThemeMode,
      themeToggleCallback: themeToggleCallback,
      aboutConfig: aboutConfig,
      hasThemeToggleInOverflow: hasThemeToggleInOverflow,
      hasAboutInOverflow: hasAboutInOverflow,
      hasLogoutInOverflow: hasLogoutInOverflow,
      hasInviteOthersInOverflow: hasInviteOthersInOverflow,
      inviteConfig: inviteConfig,
      onLogout: onLogout,
      onLogin: onLogin,
    );
  }
}

/// A dynamic overflow menu that checks login status when opened.

class _DynamicOverflowMenu extends StatefulWidget {
  final SolidAppBarConfig config;
  final SolidThemeToggleConfig? themeToggle;
  final ThemeMode currentThemeMode;
  final VoidCallback? themeToggleCallback;
  final SolidAboutConfig aboutConfig;
  final bool hasThemeToggleInOverflow;
  final bool hasAboutInOverflow;
  final bool hasLogoutInOverflow;
  final bool hasInviteOthersInOverflow;
  final SolidInviteOthersConfig? inviteConfig;
  final void Function(BuildContext)? onLogout;
  final void Function(BuildContext)? onLogin;

  const _DynamicOverflowMenu({
    required this.config,
    required this.themeToggle,
    required this.currentThemeMode,
    required this.themeToggleCallback,
    required this.aboutConfig,
    required this.hasThemeToggleInOverflow,
    required this.hasAboutInOverflow,
    required this.hasLogoutInOverflow,
    required this.hasInviteOthersInOverflow,
    required this.inviteConfig,
    required this.onLogout,
    required this.onLogin,
  });

  @override
  State<_DynamicOverflowMenu> createState() => _DynamicOverflowMenuState();
}

class _DynamicOverflowMenuState extends State<_DynamicOverflowMenu> {
  bool _isLoggedIn = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// Checks the current login status.

  Future<void> _checkLoginStatus() async {
    try {
      final webId = await getWebId();
      if (webId == null || webId.isEmpty) {
        if (mounted) {
          setState(() => _isLoggedIn = false);
        }
        return;
      }

      final isLoggedIn = await isUserLoggedIn();
      if (mounted) {
        setState(() => _isLoggedIn = isLoggedIn);
      }
    } catch (e) {
      debugPrint('Error checking login status in overflow menu: $e');
      if (mounted) {
        setState(() => _isLoggedIn = false);
      }
    }
  }

  /// Finds a custom action by explicit id or auto-generated index id.

  SolidAppBarAction? _findCustomAction(String id) {
    for (int i = 0; i < widget.config.actions.length; i++) {
      final action = widget.config.actions[i];
      final effectiveId = action.id ?? 'action_$i';
      if (effectiveId == id) return action;
    }
    return null;
  }

  /// Handles menu selection.

  void _handleSelection(String id, BuildContext context) {
    if (!context.mounted) return;

    if (id == 'theme_toggle') {
      widget.themeToggleCallback?.call();
    } else if (id == 'about') {
      if (widget.aboutConfig.onPressed != null) {
        widget.aboutConfig.onPressed!();
      } else {
        SolidAbout.show(context, widget.aboutConfig);
      }
    } else if (id == SolidAppBarActionIds.inviteOthers) {
      final invite = widget.inviteConfig;
      if (invite != null) {
        InviteOthersDialog.show(context, config: invite);
      }
    } else if (id == 'logout') {
      // User tapped logout whilst logged in.

      if (widget.onLogout != null) {
        widget.onLogout!(context);
      } else {
        SolidAuthHandler.instance.handleLogout(context);
      }
    } else if (id == SolidAppBarActionIds.notifications) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SolidNotificationCentre()),
      );
    } else if (id == 'login') {
      // User tapped login whilst logged out.

      if (widget.onLogin != null) {
        widget.onLogin!(context);
      } else {
        SolidAuthHandler.instance.handleLogin(context);
      }
    } else if (_findCustomAction(id) != null) {
      _findCustomAction(id)!.onPressed();
    } else {
      final item = widget.config.overflowItems
          .cast<SolidOverflowMenuItem?>()
          .firstWhere((item) => item?.id == id, orElse: () => null);
      item?.onSelected();
    }

    // Refresh login status after action.

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkLoginStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String id) => _handleSelection(id, context),
      itemBuilder: (BuildContext menuContext) {
        // Refresh login status when menu is about to be shown.

        _checkLoginStatus();

        return SolidScaffoldHelpers.buildOverflowMenuItems(
          widget.config,
          widget.themeToggle,
          widget.currentThemeMode,
          widget.aboutConfig,
          widget.hasThemeToggleInOverflow,
          widget.hasAboutInOverflow,
          hasLogoutInOverflow: widget.hasLogoutInOverflow,
          isLoggedIn: _isLoggedIn,
          hasInviteOthersInOverflow: widget.hasInviteOthersInOverflow,
          inviteConfig: widget.inviteConfig,
        );
      },
    );
  }
}
