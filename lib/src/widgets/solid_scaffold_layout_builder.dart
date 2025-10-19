/// Solid Scaffold Layout Builder.
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
        isKeySaved: isKeySaved,
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
        onLogin: config.onLogin,
        securityKeyStatus: updatedStatus,
        customItems: config.customItems,
        showOnNarrowScreens: config.showOnNarrowScreens,
        narrowScreenThreshold: config.narrowScreenThreshold,
        backgroundColor: config.backgroundColor,
        narrowLayoutHeight: config.narrowLayoutHeight,
        mediumLayoutHeight: config.mediumLayoutHeight,
        wideLayoutHeight: config.wideLayoutHeight,
        padding: config.padding,
        itemSpacing: config.itemSpacing,
      );
    }

    // Use dynamic login status if login status is configured.

    if (config.loginStatus != null) {
      return SolidDynamicLoginStatus(
        baseConfig: modifiedConfig,
        onTap: config.loginStatus!.onTap,
        onLogin: config.onLogin,
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

    return const Offset(leftPadding, topPadding);
  }
}
