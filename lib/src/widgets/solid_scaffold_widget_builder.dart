/// Solid Scaffold Widget Builder.
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

import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_nav_drawer.dart';
import 'package:solidui/src/widgets/solid_scaffold.dart';
import 'package:solidui/src/widgets/solid_scaffold_build_helper.dart';
import 'package:solidui/src/widgets/solid_scaffold_helpers.dart';
import 'package:solidui/src/widgets/solid_scaffold_layout_builder.dart';
import 'package:solidui/src/widgets/solid_theme_notifier.dart';

/// Widget builder specifically for SolidScaffold.

class SolidScaffoldWidgetBuilder {
  /// Builds scaffold directly from widget parameters.

  static Widget buildFromWidget({
    required BuildContext context,
    required GlobalKey<ScaffoldState> scaffoldKey,
    required SolidScaffold widget,
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
        ),
      ),
      buildDrawer: () {
        if (isWideScreen || widget.menu == null) return null;
        return SolidNavDrawer(
          userInfo: widget.userInfo,
          tabs: SolidScaffoldHelpers.convertToNavTabs(widget.menu),
          selectedIndex: currentSelectedIndex,
          onTabSelected: onMenuSelected,
          onLogout: widget.onLogout,
          showLogout: widget.onLogout != null,
        );
      },
      endDrawer: widget.endDrawer,
      backgroundColor: widget.backgroundColor,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
      bodyContent: bodyContent,
      bottomNavigationBar: isCompatibilityMode
          ? widget.bottomNavigationBar
          : SolidScaffoldLayoutBuilder.buildStatusBar(
              widget.statusBar,
              isKeySaved,
            ),
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
