/// Solid Scaffold Layout Builder.
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

import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:solidui/src/constants/navigation.dart';
import 'package:solidui/src/widgets/solid_dynamic_login_status.dart';
import 'package:solidui/src/widgets/solid_nav_bar.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_status_bar.dart';
import 'package:solidui/src/widgets/solid_status_bar_models.dart';

/// Builder class for creating Scaffold layouts.

class SolidScaffoldLayoutBuilder {
  /// Builds the main body content.

  static Widget buildBody(
    BuildContext context,
    bool isWideScreen,
    List<SolidNavTab> tabs,
    int selectedIndex,
    Widget? effectiveChild,
    Function(int) onTabSelected,
    Function(BuildContext, String, String?)? onShowAlert,
  ) {
    final theme = Theme.of(context);

    if (effectiveChild == null) {
      return const SizedBox.shrink();
    }

    if (isWideScreen) {
      // Wide screen: show navigation bar + content.

      return Column(
        children: [
          Divider(height: 1, color: theme.dividerColor),
          Expanded(
            child: Row(
              children: [
                SolidNavBar(
                  tabs: tabs,
                  selectedIndex: selectedIndex,
                  onTabSelected: onTabSelected,
                  onShowAlert: onShowAlert,
                ),
                VerticalDivider(width: 1, color: theme.dividerColor),
                Expanded(child: effectiveChild),
              ],
            ),
          ),
        ],
      );
    } else {
      // Narrow screen: show content only.

      return Column(
        children: [
          Divider(height: 1, color: theme.dividerColor),
          Expanded(child: effectiveChild),
        ],
      );
    }
  }

  /// Builds the status bar.

  static Widget? buildStatusBar(SolidStatusBarConfig? config, bool isKeySaved) {
    if (config == null) return null;

    // Create a modified config with updated security key status.

    SolidStatusBarConfig modifiedConfig = config;

    if (config.securityKeyStatus != null) {
      final originalStatus = config.securityKeyStatus!;
      final updatedStatus = SolidSecurityKeyStatus(
        isKeySaved: originalStatus.isKeySaved ?? isKeySaved,
        onTap: originalStatus.onTap,
        onKeyStatusChanged: originalStatus.onKeyStatusChanged,
        title: originalStatus.title,
        appWidget: originalStatus.appWidget,
        keySavedText: originalStatus.keySavedText,
        keyNotSavedText: originalStatus.keyNotSavedText,
        tooltip: originalStatus.tooltip,
      );

      modifiedConfig = SolidStatusBarConfig(
        serverInfo: config.serverInfo,
        loginStatus: config.loginStatus,
        securityKeyStatus: updatedStatus,
        customItems: config.customItems,
        showOnNarrowScreens: config.showOnNarrowScreens,
      );
    }

    // Use dynamic login status if login status is configured.

    if (config.loginStatus != null) {
      return SolidDynamicLoginStatus(
        baseConfig: modifiedConfig,
        onTap: config.loginStatus!.onTap,
        loggedInText: config.loginStatus!.loggedInText,
        loggedOutText: config.loginStatus!.loggedOutText,
        loggedInTooltip: config.loginStatus!.loggedInTooltip,
        loggedOutTooltip: config.loginStatus!.loggedOutTooltip,
      );
    }

    return SolidStatusBar(config: modifiedConfig);
  }

  /// Builds hamburger FAB for narrow screens without AppBar.

  static Widget buildHamburgerFAB(
    BuildContext context,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    final theme = Theme.of(context);

    return MarkdownTooltip(
      message: '''
**Navigation Menu**

Tap here to open the navigation drawer and access all available pages and options.

''',
      child: Container(
        width: NavigationConstants.hamburgerButtonSize,
        height: NavigationConstants.hamburgerButtonSize,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(
            NavigationConstants.hamburgerButtonRadius,
          ),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(
              NavigationConstants.hamburgerButtonRadius,
            ),
            onTap: () {
              scaffoldKey.currentState?.openDrawer();
            },
            child: Icon(
              Icons.menu,
              color: theme.colorScheme.onSurface,
              size: NavigationConstants.hamburgerIconSize,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom FloatingActionButtonLocation for hamburger button in top-left corner.

class SolidNavButtonStartTopLocation extends FloatingActionButtonLocation {
  const SolidNavButtonStartTopLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    const double leftPadding = 16.0;
    const double topPadding = 16.0;

    return Offset(leftPadding, topPadding);
  }
}
