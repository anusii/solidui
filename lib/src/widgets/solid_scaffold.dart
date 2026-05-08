/// Solid Scaffold - Simplified unified scaffold component.
///
// Time-stamp: <Friday 2026-05-01 11:47:09 +1000 Graham Williams>
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
import 'package:solidui/src/handlers/solid_auth_handler.dart';
import 'package:solidui/src/services/solid_profile_service.dart';
import 'package:solidui/src/services/solid_security_key_notifier.dart';
import 'package:solidui/src/services/solid_security_key_service.dart';
import 'package:solidui/src/utils/solid_notifications.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_feedback_models.dart';
import 'package:solidui/src/widgets/solid_invite_others_models.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_preferences_notifier.dart';
import 'package:solidui/src/widgets/solid_scaffold_controller.dart';
import 'package:solidui/src/widgets/solid_scaffold_helpers.dart';
import 'package:solidui/src/widgets/solid_scaffold_init_helpers.dart';
import 'package:solidui/src/widgets/solid_scaffold_layout_builder.dart';
import 'package:solidui/src/widgets/solid_scaffold_models.dart';
import 'package:solidui/src/widgets/solid_scaffold_state_helpers.dart';
import 'package:solidui/src/widgets/solid_scaffold_widget_builder.dart';
import 'package:solidui/src/widgets/solid_status_bar_models.dart';
import 'package:solidui/src/widgets/solid_theme_models.dart';
import 'package:solidui/src/widgets/solid_theme_notifier.dart';

part 'solid_scaffold_state.dart';

/// Simplified unified scaffold component that automatically handles responsive
/// layout switching.

class SolidScaffold extends StatefulWidget {
  /// List of menu items for SolidUI navigation.
  /// If null, SolidScaffold behaves like a standard Scaffold.

  final List<SolidMenuItem>? menu;

  /// Main content area for SolidUI layout.
  /// If null, will use the `body` parameter (Scaffold compatibility).

  final Widget? child;

  /// Standard Scaffold body parameter for compatibility.
  /// Used when `child` is null.

  final Widget? body;

  /// Optional controller for simplified subpage navigation management.

  final SolidScaffoldController? controller;

  /// Optional body override for displaying subpages not in the menu.

  final Widget? bodyOverride;

  /// Callback invoked when bodyOverride should be cleared.

  final VoidCallback? onClearBodyOverride;

  /// Standard Scaffold appBar for compatibility.

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

  /// Optional custom logout callback.
  /// If null and [showLogout] is true, the built-in
  /// [SolidAuthHandler.instance.handleLogout] will be used.

  final void Function(BuildContext)? onLogout;

  /// Optional custom login callback.
  /// If null, the built-in [SolidAuthHandler.instance.handleLogin] will be
  /// used. Provide this to navigate to your app's specific login page.

  final void Function(BuildContext)? onLogin;

  /// Whether to show the logout button.
  /// Defaults to true. When true and [onLogout] is null, the built-in
  /// [SolidAuthHandler.instance.handleLogout] will be used automatically.

  final bool showLogout;

  /// Whether to show the login button in the app bar when logged out.
  /// Defaults to true. Set to false when the app uses a dedicated login
  /// screen (e.g. [SolidLogin]) and the app bar login button is unwanted.

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

  /// Optional Invite Others configuration. When provided, the
  /// "Invite Others" (Share) entry is surfaced from the About dialog.
  /// When [enableProfile] is `false`, the legacy behaviour is kept:
  /// an invite button is also added to the AppBar action list and the
  /// user can move it into the overflow menu via Layout Preferences.

  final SolidInviteOthersConfig? inviteConfig;

  /// Optional Feedback configuration surfaced from the About dialog.
  /// When `null`, the About dialog still shows a Feedback placeholder
  /// (greyed out) so the layout is consistent and applications retain
  /// a clear integration point for a future feedback flow.

  final SolidFeedbackConfig? feedbackConfig;

  /// Option to force the navigation rail to be hidden.

  final bool hideNavRail;

  /// Whether to enable the POD-backed profile feature (avatar + display name).
  /// When true, the profile avatar and display name are shown in both the
  /// AppBar (right side) and the navigation drawer header. The avatar
  /// hosts a popup menu with Settings (which opens the profile editor)
  /// and Logout/Login, so the standalone AppBar Logout/Share buttons are
  /// suppressed in this mode. When false, the Logout button is rendered
  /// as the second-to-last AppBar action — immediately to the left of
  /// the About button. Profile data is automatically loaded from the
  /// POD on first build. Defaults to true.

  final bool enableProfile;

  /// Whether to enable the AppBar overflow menu (the three-dot menu).
  ///
  /// When true (the default), buttons can be moved into an overflow menu via
  /// AppBar Preferences and, on very narrow screens, buttons marked as
  /// "move to overflow" collapse into a three-dot popup menu. The overflow
  /// button itself is only rendered if at least one visible button is set to
  /// appear in the menu.
  ///
  /// When false, the overflow feature is fully disabled: the AppBar
  /// Preferences dialogue hides the per-button "move to overflow" toggle,
  /// the three-dot popup menu is never shown, and every visible button is
  /// rendered directly in the AppBar regardless of window width.

  final bool enableOverflowMenu;

  const SolidScaffold({
    super.key,
    this.menu,
    this.child,
    this.body,
    this.controller,
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
    this.showLogout = true,
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
    this.inviteConfig,
    this.feedbackConfig,
    this.hideNavRail = false,
    this.enableProfile = true,
    this.enableOverflowMenu = true,
  });

  @override
  State<SolidScaffold> createState() => SolidScaffoldState();
}
