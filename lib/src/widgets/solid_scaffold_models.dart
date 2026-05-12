/// Solid Scaffold Models - Simplified scaffold component data models.
///
// Time-stamp: <Monday 2025-08-18 14:30:00 +1000 Tony Chen>
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

import 'package:solidui/src/constants/navigation.dart';
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

  /// Optional body override for displaying subpages not in the menu.
  /// When provided, this takes precedence over menu-based navigation.

  final Widget? bodyOverride;

  /// Callback invoked when bodyOverride should be cleared.

  final VoidCallback? onClearBodyOverride;

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

  /// Optional login callback.

  final void Function(BuildContext)? onLogin;

  /// Whether to show login button when logged out.

  final bool showLogin;

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

  /// Optional settings widget.

  final Widget? settingsWidget;

  /// Option to force the navigation rail to be hidden and display a
  /// hamburger menu button instead.

  final bool hideNavRail;

  const SolidScaffoldInternalConfig({
    this.menu,
    this.child,
    this.body,
    this.bodyOverride,
    this.onClearBodyOverride,
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
    this.onLogin,
    this.showLogin = true,
    this.onShowAlert,
    this.narrowScreenThreshold = NavigationConstants.narrowScreenThreshold,
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
    this.settingsWidget,
    this.hideNavRail = false,
  });
}
