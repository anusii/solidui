/// Solid Scaffold Build Helper.
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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:solidui/src/widgets/solid_scaffold_layout_builder.dart';

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
}
