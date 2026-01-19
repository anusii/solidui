/// Solid Scaffold - Simplified unified scaffold component.
///
// Time-stamp: <Thursday 2025-08-21 13:20:34 +1000 Graham Williams>
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
import 'package:solidui/src/services/solid_security_key_notifier.dart';
import 'package:solidui/src/services/solid_security_key_service.dart';
import 'package:solidui/src/utils/solid_notifications.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
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
  /// When provided, handles all subpage state automatically.
  /// Use `controller.navigateToSubpage(widget)` to show a subpage.
  ///
  /// Example:
  /// ```dart
  /// final controller = SolidScaffoldController();
  /// SolidScaffold(
  ///   controller: controller,
  ///   appBar: SolidAppBarConfig(
  ///     actions: [
  ///       SolidAppBarAction(
  ///         icon: Icons.settings,
  ///         onPressed: () => controller.navigateToSubpage(SettingsPage()),
  ///       ),
  ///     ],
  ///   ),
  /// )
  /// ```

  final SolidScaffoldController? controller;

  /// Optional body override for displaying subpages not in the menu.
  /// When provided, this takes precedence over menu-based navigation.
  /// This is useful for navigating to detail pages (e.g. individual notes)
  /// whilst maintaining the SolidScaffold frame (AppBar, navigation drawer).
  ///
  /// When using bodyOverride, provide [onClearBodyOverride] callback to
  /// automatically clear it when user taps a menu item.

  final Widget? bodyOverride;

  /// Callback invoked when bodyOverride should be cleared.
  /// Automatically called when a menu item is tapped whilst bodyOverride is
  /// set. Use this to clear your subpage state: `setState(() => _subpage =
  /// null)`

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

  /// Option to force the navigation rail to be hidden and display a
  /// hamburger menu button instead.

  final bool hideNavRail;

  /// Whether to show the AppBar Layout Preferences button.

  final bool showAppBarLayoutPreferences;

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
    this.hideNavRail = false,
    this.showAppBarLayoutPreferences = false,
  });

  @override
  State<SolidScaffold> createState() => SolidScaffoldState();
}

class SolidScaffoldState extends State<SolidScaffold> {
  late int _selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SolidSecurityKeyService? _securityKeyService;
  SolidScaffoldSecurityKeyHelper? _securityKeyHelper;
  bool _isKeySaved = false;
  String? _appVersion;
  bool _isVersionLoaded = false;
  bool? _cachedUsesInternalManagement;
  String? _currentWebId;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _initSecurityKey();
    if (SolidScaffoldInitHelpers.hasVersionConfig(widget.appBar)) {
      _loadAppVersion();
    }
    _initializeNotifiers();
    _setupListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.statusBar?.securityKeyStatus != null) {
        securityKeyNotifier.refreshStatus();
      }
    });
    _loadCurrentWebId();
  }

  void _initSecurityKey() {
    _securityKeyService = SolidScaffoldInitHelpers.initializeSecurityKeyService(
      widget.statusBar?.securityKeyStatus != null,
      _onSecurityKeyChanged,
      () => _securityKeyHelper?.loadStatus(
        widget.statusBar?.securityKeyStatus?.onKeyStatusChanged,
      ),
    );
    _securityKeyHelper = SolidScaffoldSecurityKeyHelper(
      securityKeyService: _securityKeyService,
      onStatusChanged: (status) => setState(() => _isKeySaved = status),
      isMounted: () => mounted,
    );
  }

  void _setupListeners() {
    if (widget.statusBar?.securityKeyStatus != null) {
      securityKeyNotifier.addListener(_onSecurityKeyNotifierChanged);
      _isKeySaved = securityKeyNotifier.isKeySaved;
    }
    solidPreferencesNotifier.addListener(_onPreferencesChanged);
    widget.controller?.addListener(_onControllerChanged);
  }

  Future<void> _initializeNotifiers() async {
    await SolidScaffoldInitHelpers.initializeThemeNotifier(
      _getUsesInternalManagement(),
      _onThemeChanged,
    );
    if (mounted) setState(() {});
  }

  Future<void> _loadCurrentWebId() async {
    final webId = await SolidScaffoldWebIdHelper.loadCurrentWebId(
      isMounted: () => mounted,
      currentWebId: _currentWebId,
    );
    if (mounted && webId != _currentWebId) {
      setState(() => _currentWebId = webId);
    }
  }

  @override
  void dispose() {
    _securityKeyService?.removeListener(_onSecurityKeyChanged);
    if (_getUsesInternalManagement()) {
      solidThemeNotifier.removeListener(_onThemeChanged);
    }
    if (widget.statusBar?.securityKeyStatus != null) {
      securityKeyNotifier.removeListener(_onSecurityKeyNotifierChanged);
    }
    solidPreferencesNotifier.removeListener(_onPreferencesChanged);
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onPreferencesChanged() {
    if (mounted) setState(() {});
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  void _onSecurityKeyNotifierChanged() {
    if (!mounted) return;
    final newStatus = securityKeyNotifier.isKeySaved;
    if (_isKeySaved != newStatus) {
      setState(() => _isKeySaved = newStatus);
      widget.statusBar?.securityKeyStatus?.onKeyStatusChanged?.call(newStatus);
    }
  }

  void _onSecurityKeyChanged() {
    _securityKeyHelper?.updateStatusFromService(
      widget.statusBar?.securityKeyStatus?.onKeyStatusChanged,
    );
  }

  Future<void> refreshSecurityKeyStatus() async {
    await _securityKeyHelper?.refresh(
      _isKeySaved,
      widget.statusBar?.securityKeyStatus?.onKeyStatusChanged,
    );
  }

  String _getVersionToDisplay() =>
      SolidScaffoldHelpers.getVersionToDisplay(_isVersionLoaded, _appVersion);

  bool _shouldShowVersion() =>
      SolidScaffoldHelpers.shouldShowVersion(_isVersionLoaded);

  Future<void> _loadAppVersion() async {
    final version = await SolidScaffoldInitHelpers.loadAppVersion(true);
    if (mounted) {
      setState(() {
        _appVersion = version;
        _isVersionLoaded = true;
      });
    }
  }

  void _onMenuSelected(int index) {
    // Clear controller's subpage if using controller.

    if (widget.controller != null && widget.controller!.hasSubpage) {
      widget.controller!.clearSubpage();
    }

    // Clear bodyOverride automatically if set.

    if (widget.bodyOverride != null && widget.onClearBodyOverride != null) {
      widget.onClearBodyOverride!();
    }

    if (widget.onMenuSelected != null) {
      widget.onMenuSelected!(index);
    } else {
      setState(() => _selectedIndex = index);
    }
    if (widget.menu != null && index < widget.menu!.length) {
      widget.menu![index].onTap?.call(context);
    }
  }

  bool _isWideScreen(BuildContext context) =>
      !widget.hideNavRail &&
      SolidScaffoldHelpers.isWideScreen(context, widget.narrowScreenThreshold);

  bool _getUsesInternalManagement() => _cachedUsesInternalManagement ??=
      SolidScaffoldHelpers.getUsesInternalManagement(widget.themeToggle);

  /// Returns the currently selected menu index.

  int? get _currentSelectedIndex {
    final subpage = widget.controller?.rawSubpage;
    if (subpage != null && widget.menu != null) {
      final matchingIndex =
          SolidScaffoldHelpers.findMatchingMenuIndex(subpage, widget.menu);
      if (matchingIndex != null) return matchingIndex;

      // Subpage exists but doesn't match any menu item - no highlight.

      return null;
    }

    return widget.selectedIndex ?? _selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = _isWideScreen(context);
    final isCompatibilityMode = widget.menu == null;
    final bodyContent = isCompatibilityMode
        ? widget.body
        : SolidScaffoldLayoutBuilder.buildBody(
            context,
            isWideScreen,
            SolidScaffoldHelpers.convertToNavTabs(widget.menu),
            _currentSelectedIndex,
            SolidScaffoldHelpers.getEffectiveChild(
              widget.menu,
              _currentSelectedIndex,
              widget.child,
              widget.body,
              widget.bodyOverride ?? widget.controller?.currentSubpage,
            ),
            _onMenuSelected,
            widget.onShowAlert,
          );
    return NotificationListener<SecurityKeyStatusChangedNotification>(
      onNotification: (notification) {
        // Trigger a refresh on the global notifier
        // This will automatically update all listeners including this scaffold.

        Future.delayed(const Duration(milliseconds: 300), () {
          securityKeyNotifier.refreshStatus();

          // Also refresh webId status when security key changes.

          _loadCurrentWebId();
        });
        return true;
      },
      child: SolidScaffoldWidgetBuilder.buildFromWidget(
        context: context,
        scaffoldKey: _scaffoldKey,
        widget: widget,
        isWideScreen: isWideScreen,
        isCompatibilityMode: isCompatibilityMode,
        bodyContent: bodyContent,
        isKeySaved: _isKeySaved,
        currentSelectedIndex: _currentSelectedIndex,
        onMenuSelected: _onMenuSelected,
        getUsesInternalManagement: _getUsesInternalManagement,
        shouldShowVersion: _shouldShowVersion,
        getVersionToDisplay: _getVersionToDisplay,
        currentWebId: _currentWebId,
      ),
    );
  }
}
