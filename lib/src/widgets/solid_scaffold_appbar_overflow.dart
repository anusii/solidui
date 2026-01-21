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
    double screenWidth,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
    VoidCallback? themeToggleCallback,
    SolidAboutConfig aboutConfig,
    BuildContext context, {
    void Function(BuildContext)? onLogout,
  }) {
    // Use narrowScreenThreshold to determine when to show overflow menu.

    final isNarrowScreen = screenWidth < config.narrowScreenThreshold;

    // Only show overflow menu on narrow screens.
    // On wide screens, all buttons are displayed directly in AppBar.

    if (!isNarrowScreen) return;

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
        ),
        shouldShowAboutInOverflow(
          aboutConfig,
          forceOverflow: true,
        ),
        context,
        hasLogoutInOverflow: shouldShowLogoutInOverflow(
          onLogout != null,
          forceOverflow: true,
        ),
        onLogout: onLogout,
      ),
    );
  }

  /// Determines if logout should be shown in overflow menu.

  static bool shouldShowLogoutInOverflow(
    bool hasLogout, {
    bool forceOverflow = false,
  }) {
    if (!hasLogout) return false;
    final actionConfig =
        SolidAppBarActionsManager.getActionConfig(SolidAppBarActionIds.logout);
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
    final actionConfig =
        SolidAppBarActionsManager.getActionConfig(SolidAppBarActionIds.about);
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
  }) {
    final overflowMenuItems = SolidScaffoldHelpers.buildOverflowMenuItems(
      config,
      themeToggle,
      currentThemeMode,
      aboutConfig,
      hasThemeToggleInOverflow,
      hasAboutInOverflow,
      hasLogoutInOverflow: hasLogoutInOverflow,
    );

    // Use Builder to get a valid context for callbacks, preventing
    // "deactivated widget's ancestor" errors during window resize.

    return Builder(
      builder: (BuildContext context) {
        return PopupMenuButton<String>(
          onSelected: (String id) {
            // Check if context is still mounted before using it.

            if (!context.mounted) return;

            if (id == 'theme_toggle') {
              themeToggleCallback?.call();
            } else if (id == 'about') {
              if (aboutConfig.onPressed != null) {
                aboutConfig.onPressed!();
              } else {
                // Show default About dialogue.

                SolidAbout.show(context, aboutConfig);
              }
            } else if (id == 'logout') {
              onLogout?.call(context);
            } else if (id.startsWith('action_')) {
              // Handle custom actions from config.actions.

              final actionIndex = int.tryParse(id.replaceFirst('action_', ''));
              if (actionIndex != null && actionIndex < config.actions.length) {
                config.actions[actionIndex].onPressed();
              } else {
                // Try to find by id match if index doesn't work.

                final action =
                    config.actions.cast<SolidAppBarAction?>().firstWhere(
                          (a) => a?.id == id,
                          orElse: () => null,
                        );
                action?.onPressed();
              }
            } else {
              // Handle overflow items from config.overflowItems.

              final item = config.overflowItems
                  .cast<SolidOverflowMenuItem?>()
                  .firstWhere(
                    (item) => item?.id == id,
                    orElse: () => null,
                  );
              item?.onSelected();
            }
          },
          itemBuilder: (BuildContext menuContext) => overflowMenuItems,
        );
      },
    );
  }
}
