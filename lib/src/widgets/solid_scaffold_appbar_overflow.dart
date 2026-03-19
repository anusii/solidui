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
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_preferences_models.dart';
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
    void Function(BuildContext)? onLogout,
    void Function(BuildContext)? onLogin,
  }) {
    final isVeryNarrowScreen = layoutWidth < config.veryNarrowScreenThreshold;

    // Only show overflow menu on very narrow screens.
    // On wider screens, all buttons are displayed directly in AppBar.

    if (!isVeryNarrowScreen) return;

    actions.add(
      _buildOverflowMenu(
        config,
        themeToggle,
        currentThemeMode,
        themeToggleCallback,
        aboutConfig,
        shouldShowThemeToggleInOverflow(themeToggle, forceOverflow: true),
        shouldShowAboutInOverflow(aboutConfig, forceOverflow: true),
        context,
        hasLogoutInOverflow: shouldShowLogoutInOverflow(
          showLogout,
          forceOverflow: true,
        ),
        onLogout: onLogout,
        onLogin: onLogin,
      ),
    );
  }

  /// Determines if logout should be shown in overflow menu.

  static bool shouldShowLogoutInOverflow(
    bool hasLogout, {
    bool forceOverflow = false,
  }) {
    if (!hasLogout) return false;
    final actionConfig = SolidAppBarActionsManager.getActionConfig(
      SolidAppBarActionIds.logout,
    );
    final isVisible = actionConfig?.isVisible ?? true;
    if (!isVisible) return false;

    final isInOverflow = actionConfig?.showInOverflow ?? false;

    // On narrow screens, only show in overflow if showInOverflow = true.
    // Buttons marked as "add to appbar" (showInOverflow = false) stay in AppBar.

    if (forceOverflow) return isInOverflow;
    return isInOverflow;
  }

  /// Determines if theme toggle should be shown in overflow menu.

  static bool shouldShowThemeToggleInOverflow(
    SolidThemeToggleConfig? themeToggle, {
    bool forceOverflow = false,
  }) {
    if (themeToggle == null || !themeToggle.enabled) return false;
    final actionConfig = SolidAppBarActionsManager.getActionConfig(
      SolidAppBarActionIds.themeToggle,
    );
    final isVisible = actionConfig?.isVisible ?? true;
    if (!isVisible) return false;

    final isInOverflow = actionConfig?.showInOverflow ?? false;

    // On narrow screens, only show in overflow if showInOverflow = true.
    // Buttons marked as "add to appbar" (showInOverflow = false) stay in AppBar.

    if (forceOverflow) return isInOverflow;
    return isInOverflow;
  }

  /// Determines if about should be shown in overflow menu.

  static bool shouldShowAboutInOverflow(
    SolidAboutConfig aboutConfig, {
    bool forceOverflow = false,
  }) {
    if (!aboutConfig.enabled) return false;
    final actionConfig = SolidAppBarActionsManager.getActionConfig(
      SolidAppBarActionIds.about,
    );
    final isVisible = actionConfig?.isVisible ?? true;
    if (!isVisible) return false;

    final isInOverflow = actionConfig?.showInOverflow ?? false;

    // On narrow screens, only show in overflow if showInOverflow = true.
    // Buttons marked as "add to appbar" (showInOverflow = false) stay in AppBar.

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
    } else if (id == 'logout') {
      // User tapped logout whilst logged in.

      if (widget.onLogout != null) {
        widget.onLogout!(context);
      } else {
        SolidAuthHandler.instance.handleLogout(context);
      }
    } else if (id == 'login') {
      // User tapped login whilst logged out.

      if (widget.onLogin != null) {
        widget.onLogin!(context);
      } else {
        SolidAuthHandler.instance.handleLogin(context);
      }
    } else if (id.startsWith('action_')) {
      final actionIndex = int.tryParse(id.replaceFirst('action_', ''));
      if (actionIndex != null && actionIndex < widget.config.actions.length) {
        widget.config.actions[actionIndex].onPressed();
      } else {
        final action = widget.config.actions
            .cast<SolidAppBarAction?>()
            .firstWhere((a) => a?.id == id, orElse: () => null);
        action?.onPressed();
      }
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
        );
      },
    );
  }
}
