/// Solid Scaffold - Simplified unified scaffold component.
///
// Time-stamp: <Thursday 2025-08-21 13:20:34 +1000 Graham Williams>
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

import 'package:solidui/src/constants/navigation.dart';
import 'package:solidui/src/services/solid_security_key_service.dart';
import 'package:solidui/src/utils/solid_notifications.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_scaffold_helpers.dart';
import 'package:solidui/src/widgets/solid_scaffold_init_helpers.dart';
import 'package:solidui/src/widgets/solid_scaffold_layout_builder.dart';
import 'package:solidui/src/widgets/solid_scaffold_models.dart';
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
  const SolidScaffold({
    super.key,
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
  });
  @override
  State<SolidScaffold> createState() => SolidScaffoldState();
}

class SolidScaffoldState extends State<SolidScaffold> {
  late int _selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SolidSecurityKeyService? _securityKeyService;
  bool _isKeySaved = false;
  bool _isUpdatingSecurityKeyStatus = false;
  String? _appVersion;
  bool _isVersionLoaded = false;
  bool? _cachedUsesInternalManagement;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _securityKeyService = SolidScaffoldInitHelpers.initializeSecurityKeyService(
      widget.statusBar?.securityKeyStatus != null,
      _onSecurityKeyChanged,
      () => _loadSecurityKeyStatus(),
    );
    if (SolidScaffoldInitHelpers.hasVersionConfig(widget.appBar)) {
      _loadAppVersion();
    }
    SolidScaffoldInitHelpers.initializeThemeNotifier(
      _getUsesInternalManagement(),
      _onThemeChanged,
    );

    // Load security key status asynchronously after initialisation.

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSecurityKeyStatus();
    });
  }

  @override
  void dispose() {
    _securityKeyService?.removeListener(_onSecurityKeyChanged);
    if (_getUsesInternalManagement()) {
      solidThemeNotifier.removeListener(_onThemeChanged);
    }
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  void _onSecurityKeyChanged() {
    if (_isUpdatingSecurityKeyStatus) return;
    _updateSecurityKeyStatusFromService();
  }

  Future<void> _updateSecurityKeyStatusFromService() async {
    if (_isUpdatingSecurityKeyStatus) return;
    _isUpdatingSecurityKeyStatus = true;
    try {
      final isKeySaved =
          await SolidScaffoldInitHelpers.updateSecurityKeyStatusFromService(
        _securityKeyService,
        widget.statusBar?.securityKeyStatus?.onKeyStatusChanged,
      );
      if (mounted) setState(() => _isKeySaved = isKeySaved);
    } finally {
      _isUpdatingSecurityKeyStatus = false;
    }
  }

  Future<void> _loadSecurityKeyStatus() async {
    if (_isUpdatingSecurityKeyStatus) return;
    _isUpdatingSecurityKeyStatus = true;
    try {
      final hasKeyInMemory =
          await SolidScaffoldInitHelpers.loadSecurityKeyStatus(
        _securityKeyService,
        (hasKey) {
          if (mounted && hasKey != _isKeySaved) {
            setState(() => _isKeySaved = hasKey);
            widget.statusBar?.securityKeyStatus?.onKeyStatusChanged
                ?.call(hasKey);
          }
        },
      );
      if (mounted) setState(() => _isKeySaved = hasKeyInMemory);
    } catch (e) {
      if (mounted) setState(() => _isKeySaved = false);
    } finally {
      _isUpdatingSecurityKeyStatus = false;
    }
  }

  /// Manually refresh the security key status.

  Future<void> refreshSecurityKeyStatus() async {
    if (_securityKeyService == null) return;

    try {
      final hasKey =
          await _securityKeyService!.refreshAndNotify((bool keyStatus) {
        if (mounted && keyStatus != _isKeySaved) {
          setState(() => _isKeySaved = keyStatus);
          widget.statusBar?.securityKeyStatus?.onKeyStatusChanged
              ?.call(keyStatus);
        }
      });

      if (mounted && hasKey != _isKeySaved) {
        setState(() => _isKeySaved = hasKey);
        widget.statusBar?.securityKeyStatus?.onKeyStatusChanged?.call(hasKey);
      }
    } catch (e) {
      debugPrint('Error refreshing security key status: $e');
    }
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
    if (widget.onMenuSelected != null) {
      widget.onMenuSelected!(index);
    } else {
      setState(() => _selectedIndex = index);
    }
    if (widget.menu != null && index < widget.menu!.length) {
      widget.menu![index].onTap?.call(context);
    }
  }

  bool _isWideScreen(BuildContext context) => SolidScaffoldHelpers.isWideScreen(
        context,
        widget.narrowScreenThreshold,
      );
  bool _getUsesInternalManagement() => _cachedUsesInternalManagement ??=
      SolidScaffoldHelpers.getUsesInternalManagement(widget.themeToggle);
  int get _currentSelectedIndex => widget.selectedIndex ?? _selectedIndex;
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
            ),
            _onMenuSelected,
            widget.onShowAlert,
          );
    return NotificationListener<SecurityKeyStatusChangedNotification>(
      onNotification: (notification) {
        _loadSecurityKeyStatus();
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
      ),
    );
  }
}
