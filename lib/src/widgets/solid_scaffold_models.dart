/// Solid Scaffold Models - Simplified scaffold component data models.
///
// Time-stamp: <Monday 2025-08-18 14:30:00 +1000 Tony Chen>
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

import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_status_bar_models.dart';
import 'package:solidui/src/widgets/solid_theme_models.dart';

/// Simplified menu item configuration.

class SolidMenuItem {
  /// Menu title.

  final String title;

  /// Menu icon.

  final IconData icon;

  /// Optional icon colour.

  final Color? color;

  /// Optional child widget (displayed when menu is selected).

  final Widget? child;

  /// Optional tooltip.

  final String? tooltip;

  /// Optional message dialogue content.

  final String? message;

  /// Optional dialogue title.

  final String? dialogTitle;

  /// Optional tap callback.

  final void Function(BuildContext)? onTap;

  const SolidMenuItem({
    required this.title,
    required this.icon,
    this.color,
    this.child,
    this.tooltip,
    this.message,
    this.dialogTitle,
    this.onTap,
  });
}

/// Configuration class to hold all SolidScaffold parameters.
/// This helps reduce the main widget class size and improves maintainability.

class SolidScaffoldInternalConfig {
  /// List of menu items for SolidUI navigation.
  /// If null, SolidScaffold behaves like a standard Scaffold.

  final List<SolidMenuItem>? menu;

  /// Main content area for SolidUI layout.
  /// If null, will use the `body` parameter (Scaffold compatibility).

  final Widget? child;

  /// Standard Scaffold body parameter for compatibility.
  /// Used when `child` is null.

  final Widget? body;

  /// Standard Scaffold appBar for compatibility.
  /// Used when SolidUI `appBar` config is null.

  final PreferredSizeWidget? scaffoldAppBar;

  /// Standard Scaffold drawer for compatibility.

  final Widget? drawer;

  /// Standard Scaffold endDrawer for compatibility.

  final Widget? endDrawer;

  /// Standard Scaffold bottomNavigationBar for compatibility.

  final Widget? bottomNavigationBar;

  /// Standard Scaffold bottomSheet for compatibility.

  final Widget? bottomSheet;

  /// Standard Scaffold persistentFooterButtons for compatibility.

  final List<Widget>? persistentFooterButtons;

  /// Standard Scaffold resizeToAvoidBottomInset for compatibility.

  final bool? resizeToAvoidBottomInset;

  /// Optional AppBar configuration.

  final dynamic appBar;

  /// Optional status bar configuration.

  final SolidStatusBarConfig? statusBar;

  /// Optional user information configuration.

  final SolidNavUserInfo? userInfo;

  /// Optional logout callback.

  final void Function(BuildContext)? onLogout;

  /// Optional alert dialogue callback.

  final void Function(BuildContext, String, String?)? onShowAlert;

  /// Narrow screen threshold.

  final double narrowScreenThreshold;

  /// Background colour.

  final Color? backgroundColor;

  /// Floating action button.

  final Widget? floatingActionButton;

  /// Location of the floating action button.

  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Animator for the floating action button.

  final FloatingActionButtonAnimator? floatingActionButtonAnimator;

  /// Callback when drawer is opened or closed.

  final DrawerCallback? onDrawerChanged;

  /// Callback when end drawer is opened or closed.

  final DrawerCallback? onEndDrawerChanged;

  /// Whether this scaffold is being displayed at the top of the widget hierarchy.

  final bool primary;

  /// Determines the way that drag start behaviour is handled for drawer.

  final DragStartBehavior drawerDragStartBehavior;

  /// Whether the body should extend to the bottom of the scaffold.

  final bool extendBody;

  /// Whether the body should extend behind the app bar.

  final bool extendBodyBehindAppBar;

  /// Colour to use for the scrim that obscures primary content while drawer is open.

  final Color? drawerScrimColor;

  /// Width of the area within which a horizontal swipe will open the drawer.

  final double? drawerEdgeDragWidth;

  /// Whether the drawer can be opened with a drag gesture.

  final bool drawerEnableOpenDragGesture;

  /// Whether the end drawer can be opened with a drag gesture.

  final bool endDrawerEnableOpenDragGesture;

  /// Restoration ID to save and restore the state of the scaffold.

  final String? restorationId;

  /// Initial selected menu index.

  final int initialIndex;

  /// Optional menu selection callback (for external state management).

  final void Function(int)? onMenuSelected;

  /// Optional current selected index (for external state management).

  final int? selectedIndex;

  /// Optional theme toggle configuration.

  final SolidThemeToggleConfig? themeToggle;

  /// Optional About dialogue configuration.

  final SolidAboutConfig? aboutConfig;

  const SolidScaffoldInternalConfig({
    this.menu,
    this.child,
    this.body,
    this.scaffoldAppBar,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.persistentFooterButtons,
    this.resizeToAvoidBottomInset,
    this.appBar,
    this.statusBar,
    this.userInfo,
    this.onLogout,
    this.onShowAlert,
    this.narrowScreenThreshold = 800,
    this.backgroundColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.onDrawerChanged,
    this.onEndDrawerChanged,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
    this.initialIndex = 0,
    this.onMenuSelected,
    this.selectedIndex,
    this.themeToggle,
    this.aboutConfig,
  });
}
