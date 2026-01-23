/// Solid Scaffold Widget Builder.
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

import 'package:solidui/src/handlers/solid_auth_handler.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_nav_drawer.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_scaffold.dart';
import 'package:solidui/src/widgets/solid_scaffold_build_helper.dart';
import 'package:solidui/src/widgets/solid_scaffold_helpers.dart';
import 'package:solidui/src/widgets/solid_scaffold_layout_builder.dart';
import 'package:solidui/src/widgets/solid_theme_notifier.dart';

/// Widget builder specifically for SolidScaffold.

class SolidScaffoldWidgetBuilder {
  /// Returns the effective logout callback.
  /// If [showLogout] is true and [onLogout] is null, returns the built-in
  /// [SolidAuthHandler.instance.handleLogout]. Otherwise returns [onLogout].

  static void Function(BuildContext)? _getEffectiveLogout(
    SolidScaffold widget,
  ) {
    if (!widget.showLogout) return null;
    return widget.onLogout ??
        (context) => SolidAuthHandler.instance.handleLogout(context);
  }

  /// Returns the effective login callback.
  /// If [onLogin] is null, returns the built-in
  /// [SolidAuthHandler.instance.handleLogin].

  static void Function(BuildContext) _getEffectiveLogin(
    SolidScaffold widget,
  ) {
    return widget.onLogin ??
        (context) => SolidAuthHandler.instance.handleLogin(context);
  }

  /// Builds a default SolidNavUserInfo from available scaffold configuration.

  static SolidNavUserInfo? _buildDefaultUserInfo(
    SolidScaffold widget,
    String? currentWebId,
  ) {
    SolidVersionConfig? versionConfig;
    if (widget.appBar is SolidAppBarConfig) {
      versionConfig = (widget.appBar as SolidAppBarConfig).versionConfig;
    }

    if (currentWebId == null && versionConfig == null) {
      return null;
    }

    return SolidNavUserInfo(
      webId: currentWebId,
      showWebId: currentWebId != null && currentWebId.isNotEmpty,
      avatarIcon: Icons.account_circle,
      versionConfig: versionConfig,
    );
  }

  /// Builds scaffold directly from widget parameters.

  static Widget buildFromWidget({
    required BuildContext context,
    required GlobalKey<ScaffoldState> scaffoldKey,
    required SolidScaffold widget,
    required bool isWideScreen,
    required bool isCompatibilityMode,
    required Widget? bodyContent,
    required bool isKeySaved,
    required int? currentSelectedIndex,
    required void Function(int) onMenuSelected,
    required bool Function() getUsesInternalManagement,
    required bool Function() shouldShowVersion,
    required String Function() getVersionToDisplay,
    String? currentWebId,
  }) {
    // Get the effective login/logout callbacks (built-in or custom).

    final effectiveLogout = _getEffectiveLogout(widget);
    final effectiveLogin = _getEffectiveLogin(widget);

    return SolidScaffoldBuildHelper.buildScaffold(
      context: context,
      scaffoldKey: scaffoldKey,
      isWideScreen: isWideScreen,
      isCompatibilityMode: isCompatibilityMode,
      floatingActionButton: widget.floatingActionButton,
      resolveAppBar: (context, isCompatibilityMode) =>
          SolidScaffoldHelpers.resolveAppBar(
        context,
        widget.appBar,
        widget.scaffoldAppBar,
        isCompatibilityMode,
        widget.menu,
        (context) => SolidScaffoldHelpers.buildAppBarFromConfig(
          context,
          widget.appBar,
          widget.themeToggle,
          SolidScaffoldHelpers.getCurrentThemeMode(
            getUsesInternalManagement(),
            solidThemeNotifier,
            widget.themeToggle,
          ),
          SolidScaffoldHelpers.getThemeToggleCallback(
            getUsesInternalManagement(),
            solidThemeNotifier,
            widget.themeToggle,
          ),
          widget.aboutConfig ?? const SolidAboutConfig(),
          widget.narrowScreenThreshold,
          shouldShowVersion,
          getVersionToDisplay,
          hideNavRail: widget.hideNavRail,
          onLogout: effectiveLogout,
          onLogin: effectiveLogin,
        ),
      ),
      buildDrawer: () {
        if (isWideScreen || widget.menu == null) return null;

        final effectiveUserInfo =
            widget.userInfo ?? _buildDefaultUserInfo(widget, currentWebId);

        return SolidNavDrawer(
          userInfo: effectiveUserInfo,
          tabs: SolidScaffoldHelpers.convertToNavTabs(widget.menu),
          selectedIndex: currentSelectedIndex,
          onTabSelected: onMenuSelected,
          onLogout: effectiveLogout,
          showLogout: effectiveLogout != null,
        );
      },
      endDrawer: widget.endDrawer,
      backgroundColor: widget.backgroundColor,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
      bodyContent: bodyContent,
      bottomNavigationBar: isCompatibilityMode
          ? widget.bottomNavigationBar
          : (widget.hideNavRail
              ? null
              : SolidScaffoldLayoutBuilder.buildStatusBar(
                  widget.statusBar,
                  isKeySaved,
                )),
      bottomSheet: widget.bottomSheet,
      persistentFooterButtons: widget.persistentFooterButtons,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      onDrawerChanged: widget.onDrawerChanged,
      onEndDrawerChanged: widget.onEndDrawerChanged,
      primary: widget.primary,
      drawerDragStartBehavior: widget.drawerDragStartBehavior,
      extendBody: widget.extendBody,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      drawerScrimColor: widget.drawerScrimColor,
      drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,
      restorationId: widget.restorationId,
    );
  }
}
