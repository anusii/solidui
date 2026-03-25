/// Solid Scaffold Build Helper.
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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:solidui/src/handlers/solid_auth_handler.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_nav_drawer.dart';
import 'package:solidui/src/widgets/solid_scaffold_helpers.dart';
import 'package:solidui/src/widgets/solid_scaffold_layout_builder.dart';
import 'package:solidui/src/widgets/solid_scaffold_models.dart';
import 'package:solidui/src/widgets/solid_status_bar_models.dart';
import 'package:solidui/src/widgets/solid_theme_notifier.dart';

/// Helper for building the main Scaffold in SolidScaffold.

class SolidScaffoldBuildHelper {
  /// Builds the main Scaffold widget.

  static Widget buildScaffold({
    required BuildContext context,
    required GlobalKey<ScaffoldState> scaffoldKey,
    required bool isWideScreen,
    required bool isCompatibilityMode,
    required Widget? floatingActionButton,
    required PreferredSizeWidget? Function(BuildContext, bool) resolveAppBar,
    required Widget? Function() buildDrawer,
    required Widget? endDrawer,
    required Color? backgroundColor,
    required FloatingActionButtonLocation? floatingActionButtonLocation,
    required FloatingActionButtonAnimator? floatingActionButtonAnimator,
    required Widget? bodyContent,
    required Widget? bottomNavigationBar,
    required Widget? bottomSheet,
    required List<Widget>? persistentFooterButtons,
    required bool? resizeToAvoidBottomInset,
    required DrawerCallback? onDrawerChanged,
    required DrawerCallback? onEndDrawerChanged,
    required bool primary,
    required DragStartBehavior drawerDragStartBehavior,
    required bool extendBody,
    required bool extendBodyBehindAppBar,
    required Color? drawerScrimColor,
    required double? drawerEdgeDragWidth,
    required bool drawerEnableOpenDragGesture,
    required bool endDrawerEnableOpenDragGesture,
    required String? restorationId,
  }) {
    final theme = Theme.of(context);

    Widget? fab = floatingActionButton;
    if (!isCompatibilityMode &&
        resolveAppBar(context, isCompatibilityMode) == null &&
        !isWideScreen) {
      fab = SolidScaffoldLayoutBuilder.buildHamburgerFAB(context, scaffoldKey);
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: resolveAppBar(context, isCompatibilityMode),
      drawer: isCompatibilityMode ? null : buildDrawer(),
      endDrawer: endDrawer,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      floatingActionButton: fab,
      floatingActionButtonLocation: (!isCompatibilityMode &&
              resolveAppBar(context, isCompatibilityMode) == null &&
              !isWideScreen)
          ? const SolidNavButtonStartTopLocation()
          : (floatingActionButtonLocation ??
              FloatingActionButtonLocation.endFloat),
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      body: bodyContent,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      persistentFooterButtons: persistentFooterButtons,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      onDrawerChanged: onDrawerChanged,
      onEndDrawerChanged: onEndDrawerChanged,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      drawerScrimColor: drawerScrimColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
    );
  }

  /// Builds a configured scaffold with all necessary components.

  static Widget buildConfiguredScaffold({
    required BuildContext context,
    required BoxConstraints constraints,
    required GlobalKey<ScaffoldState> scaffoldKey,
    required SolidScaffoldInternalConfig config,
    required bool isWideScreen,
    required bool isCompatibilityMode,
    required Widget? bodyContent,
    required bool isKeySaved,
    required int currentSelectedIndex,
    required void Function(int) onMenuSelected,
    required bool Function() getUsesInternalManagement,
    required bool Function() shouldShowVersion,
    required String Function() getVersionToDisplay,
  }) {
    return buildScaffold(
      context: context,
      scaffoldKey: scaffoldKey,
      isWideScreen: isWideScreen,
      isCompatibilityMode: isCompatibilityMode,
      floatingActionButton: config.floatingActionButton,
      resolveAppBar: (context, isCompatibilityMode) =>
          SolidScaffoldHelpers.resolveAppBar(
        context,
        config.appBar,
        config.scaffoldAppBar,
        isCompatibilityMode,
        config.menu,
        (context) => SolidScaffoldHelpers.buildAppBarFromConfig(
          context,
          config.appBar,
          config.themeToggle,
          SolidScaffoldHelpers.getCurrentThemeMode(
            getUsesInternalManagement(),
            solidThemeNotifier,
            config.themeToggle,
          ),
          SolidScaffoldHelpers.getThemeToggleCallback(
            getUsesInternalManagement(),
            solidThemeNotifier,
            config.themeToggle,
          ),
          config.aboutConfig ?? const SolidAboutConfig(),
          config.narrowScreenThreshold,
          shouldShowVersion,
          getVersionToDisplay,
          hideNavRail: config.hideNavRail,
          showLogout: config.onLogout != null,
          onLogout: config.onLogout,
          constraints: constraints,
        ),
      ),
      buildDrawer: () {
        if (isWideScreen || config.menu == null) return null;

        SolidSecurityKeyStatus? drawerSecurityKeyStatus;
        final original = config.statusBar?.securityKeyStatus;
        if (original != null) {
          drawerSecurityKeyStatus = SolidSecurityKeyStatus(
            isKeySaved: isKeySaved,
            onTap: original.onTap,
            onKeyStatusChanged: original.onKeyStatusChanged,
            title: original.title,
            appWidget: original.appWidget,
            keySavedText: original.keySavedText,
            keyNotSavedText: original.keyNotSavedText,
            tooltip: original.tooltip,
          );
        }

        return SolidNavDrawer(
          userInfo: config.userInfo,
          tabs: SolidScaffoldHelpers.convertToNavTabs(config.menu),
          selectedIndex: currentSelectedIndex,
          onTabSelected: onMenuSelected,
          onLogout: config.onLogout,
          showLogout: config.onLogout != null,
          onUserNameTap: (drawerContext) =>
              SolidAuthHandler.instance.handleAuthAction(drawerContext),
          securityKeyStatus: drawerSecurityKeyStatus,
        );
      },
      endDrawer: config.endDrawer,
      backgroundColor: config.backgroundColor,
      floatingActionButtonLocation: config.floatingActionButtonLocation,
      floatingActionButtonAnimator: config.floatingActionButtonAnimator,
      bodyContent: bodyContent,
      bottomNavigationBar: isCompatibilityMode
          ? config.bottomNavigationBar
          : (config.hideNavRail
              ? null
              : SolidScaffoldLayoutBuilder.buildStatusBar(
                  config.statusBar,
                  isKeySaved,
                )),
      bottomSheet: config.bottomSheet,
      persistentFooterButtons: config.persistentFooterButtons,
      resizeToAvoidBottomInset: config.resizeToAvoidBottomInset,
      onDrawerChanged: config.onDrawerChanged,
      onEndDrawerChanged: config.onEndDrawerChanged,
      primary: config.primary,
      drawerDragStartBehavior: config.drawerDragStartBehavior,
      extendBody: config.extendBody,
      extendBodyBehindAppBar: config.extendBodyBehindAppBar,
      drawerScrimColor: config.drawerScrimColor,
      drawerEdgeDragWidth: config.drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: config.drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: config.endDrawerEnableOpenDragGesture,
      restorationId: config.restorationId,
    );
  }
}
