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

import 'package:gap/gap.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version_widget/version_widget.dart';

import 'package:solidui/src/constants/navigation.dart';
import 'package:solidui/src/services/solid_security_key_service.dart';
import 'package:solidui/src/widgets/solid_about_button.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_nav_bar.dart';
import 'package:solidui/src/widgets/solid_nav_drawer.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_scaffold_models.dart';
import 'package:solidui/src/widgets/solid_status_bar.dart';
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

    // SolidUI-specific parameters.

    this.menu,
    this.child,
    this.appBar,
    this.statusBar,
    this.userInfo,
    this.onLogout,
    this.onShowAlert,
    this.narrowScreenThreshold = NavigationConstants.narrowScreenThreshold,
    this.initialIndex = 0,
    this.onMenuSelected,
    this.selectedIndex,
    this.themeToggle,
    this.aboutConfig,

    // Standard Scaffold compatibility parameters.

    this.body,
    this.scaffoldAppBar,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.persistentFooterButtons,
    this.resizeToAvoidBottomInset,
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
  });

  @override
  State<SolidScaffold> createState() => _SolidScaffoldState();
}

class _SolidScaffoldState extends State<SolidScaffold> {
  late int _selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Security key management.

  SolidSecurityKeyService? _securityKeyService;
  bool _isKeySaved = false;
  bool _isUpdatingSecurityKeyStatus = false;

  // Version management.

  String? _appVersion;
  bool _isVersionLoaded = false;

  // Theme management cache.

  bool? _cachedUsesInternalManagement;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    if (_hasSecurityKeyConfig()) {
      _initializeSecurityKeyService();
    }

    if (_hasVersionConfig()) {
      _initializeVersionLoading();
    }

    // Initialise theme notifier if using internal management.

    if (_getUsesInternalManagement()) {
      _initializeThemeNotifier();
    }
  }

  /// Initialises the theme notifier for internal theme management.

  void _initializeThemeNotifier() {
    if (!solidThemeNotifier.isInitialized) {
      solidThemeNotifier.initialize();
    }
    solidThemeNotifier.addListener(_onThemeChanged);
  }

  /// Handles theme changes from the notifier.

  void _onThemeChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild when theme changes.
      });
    }
  }

  @override
  void dispose() {
    _securityKeyService?.removeListener(_onSecurityKeyChanged);
    if (_getUsesInternalManagement()) {
      solidThemeNotifier.removeListener(_onThemeChanged);
    }
    super.dispose();
  }

  /// Checks if security key configuration is present.

  bool _hasSecurityKeyConfig() {
    return widget.statusBar?.securityKeyStatus != null;
  }

  /// Initializes the security key service and sets up listeners.

  void _initializeSecurityKeyService() {
    _securityKeyService = SolidSecurityKeyService();
    _securityKeyService!.addListener(_onSecurityKeyChanged);
    _loadSecurityKeyStatus();
  }

  /// Handles security key status changes.

  void _onSecurityKeyChanged() {
    if (_isUpdatingSecurityKeyStatus) return;
    _updateSecurityKeyStatusFromService();
  }

  /// Updates security key status from service.

  Future<void> _updateSecurityKeyStatusFromService() async {
    if (_isUpdatingSecurityKeyStatus || _securityKeyService == null) return;

    _isUpdatingSecurityKeyStatus = true;
    try {
      final isKeySaved = await _securityKeyService!.isKeySaved();
      if (mounted) {
        setState(() {
          _isKeySaved = isKeySaved;
        });

        // Notify callback if provided.

        final onKeyStatusChanged =
            widget.statusBar?.securityKeyStatus?.onKeyStatusChanged;
        if (onKeyStatusChanged != null) {
          onKeyStatusChanged(isKeySaved);
        }
      }
    } catch (e) {
      debugPrint('Error updating security key status: $e');
    } finally {
      _isUpdatingSecurityKeyStatus = false;
    }
  }

  /// Loads the current security key status.

  Future<void> _loadSecurityKeyStatus() async {
    if (_isUpdatingSecurityKeyStatus || _securityKeyService == null) return;

    _isUpdatingSecurityKeyStatus = true;
    try {
      bool hasValidKey = false;
      final hasKeyInMemory = await _securityKeyService!.isKeySaved();

      if (hasKeyInMemory) {
        hasValidKey = true;
      }

      if (mounted) {
        setState(() {
          _isKeySaved = hasValidKey;
        });
      }

      await _securityKeyService!.fetchKeySavedStatus((bool hasKey) {
        if (mounted && hasKey != _isKeySaved) {
          setState(() {
            _isKeySaved = hasKey;
          });

          // Notify callback if provided.

          final onKeyStatusChanged =
              widget.statusBar?.securityKeyStatus?.onKeyStatusChanged;
          if (onKeyStatusChanged != null) {
            onKeyStatusChanged(hasKey);
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading security key status: $e');
      if (mounted) {
        setState(() {
          _isKeySaved = false;
        });
      }
    } finally {
      _isUpdatingSecurityKeyStatus = false;
    }
  }

  // Version management methods

  /// Safely get SolidAppBarConfig if appBar is of that type, null otherwise.

  SolidAppBarConfig? _getSolidAppBarConfig() {
    return widget.appBar is SolidAppBarConfig
        ? widget.appBar as SolidAppBarConfig
        : null;
  }

  // Check if version configuration is available and requires auto-loading.

  bool _hasVersionConfig() {
    final config = _getSolidAppBarConfig();
    return config?.versionConfig != null;
  }

  // Initialise the version loading from pubspec.yaml.

  void _initializeVersionLoading() {
    _loadAppVersion();
  }

  // Load the application version from pubspec.yaml.

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;

      if (mounted) {
        setState(() {
          _appVersion = version;
          _isVersionLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading app version: $e');
      if (mounted) {
        setState(() {
          _appVersion = '';
          _isVersionLoaded = true;
        });
      }
    }
  }

  /// Gets the version to display.

  String _getVersionToDisplay() {
    final config = _getSolidAppBarConfig();
    final versionConfig = config?.versionConfig;
    if (versionConfig?.version != null) {
      return versionConfig!.version!;
    }

    if (_isVersionLoaded && _appVersion != null) {
      return _appVersion!;
    }

    return '0.0.0+0';
  }

  /// Determines whether to show the version widget.

  bool _shouldShowVersion() {
    final config = _getSolidAppBarConfig();
    final versionConfig = config?.versionConfig;
    if (versionConfig?.version != null) {
      return true; // Show immediately if version is provided
    }

    return _isVersionLoaded; // Only show after auto-load is complete
  }

  /// Handles menu selection.

  void _onMenuSelected(int index) {
    // If external callback exists, use external state management.

    if (widget.onMenuSelected != null) {
      widget.onMenuSelected!(index);
    } else {
      // Otherwise use internal state management.

      setState(() {
        _selectedIndex = index;
      });
    }

    // Execute menu item action.

    if (widget.menu != null && index < widget.menu!.length) {
      final menuItem = widget.menu![index];
      if (menuItem.onTap != null) {
        menuItem.onTap!(context);
      }
    }
  }

  /// Determines if the screen is wide.

  bool _isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > widget.narrowScreenThreshold;
  }

  /// Gets whether theme toggle uses internal management (cached for performance).

  bool _getUsesInternalManagement() {
    return _cachedUsesInternalManagement ??=
        widget.themeToggle?.usesInternalManagement ?? false;
  }

  /// Converts SolidMenuItem to SolidNavTab.

  List<SolidNavTab> _convertToNavTabs() {
    if (widget.menu == null) {
      return [];
    }

    return widget.menu!
        .map(
          (item) => SolidNavTab(
            title: item.title,
            icon: item.icon,
            color: item.color,
            child: item.child,
            tooltip: item.tooltip,
            message: item.message,
            dialogTitle: item.dialogTitle,
            action: item.onTap,
          ),
        )
        .toList();
  }

  /// Gets the current theme mode (internal or external).
  ///
  /// For internal management: returns the current mode from SolidThemeNotifier.
  /// For external management: returns the explicitly provided currentThemeMode.

  ThemeMode _getCurrentThemeMode() {
    if (_getUsesInternalManagement()) {
      return solidThemeNotifier.themeMode;
    }
    return widget.themeToggle?.currentThemeMode ?? ThemeMode.system;
  }

  /// Gets the theme toggle callback (internal or external).
  ///
  /// For internal management: returns a callback that uses SolidThemeNotifier.
  /// For external management: returns the explicitly provided onToggleTheme callback.

  VoidCallback? _getThemeToggleCallback() {
    if (_getUsesInternalManagement()) {
      return () async {
        await solidThemeNotifier.toggleTheme();
      };
    }
    return widget.themeToggle?.onToggleTheme;
  }

  /// Builds the AppBar.

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (widget.appBar == null) return null;

    // Ensure we're working with a SolidAppBarConfig.

    if (widget.appBar is! SolidAppBarConfig) return null;

    final config = widget.appBar as SolidAppBarConfig;
    final isWideScreen = _isWideScreen(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    // Build action buttons.

    List<Widget> actions = [];

    // Add version widget if configured and screen is not too narrow.

    if (config.versionConfig != null &&
        screenWidth >= config.veryNarrowScreenThreshold &&
        _shouldShowVersion()) {
      final versionToDisplay = _getVersionToDisplay();
      actions.add(
        MarkdownTooltip(
          message: config.versionConfig!.tooltip ??
              'Version: $versionToDisplay\n\n'
                  'Tap to view changelog if available.',
          child: Theme(
            data: theme.copyWith(
              textTheme: theme.textTheme.copyWith(
                bodyMedium: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                bodySmall: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              colorScheme: theme.colorScheme.copyWith(
                error: theme.colorScheme.error.withValues(alpha: 0.6),
              ),
            ),
            child: VersionWidget(
              version: versionToDisplay,
              changelogUrl: config.versionConfig!.changelogUrl,
              showDate: config.versionConfig!.showDate,
            ),
          ),
        ),
      );
      actions.add(const Gap(8));
    }

    for (final action in config.actions) {
      // Determine whether to show button based on screen width.

      bool shouldShow = true;
      if (!action.showOnVeryNarrowScreen &&
          screenWidth < config.veryNarrowScreenThreshold) {
        shouldShow = false;
      } else if (!action.showOnNarrowScreen &&
          screenWidth < config.narrowScreenThreshold) {
        shouldShow = false;
      }

      if (shouldShow) {
        Widget iconButton = IconButton(
          icon: Icon(action.icon),
          onPressed: action.onPressed,
          color: action.color,
        );

        // Wrap with MarkdownTooltip if tooltip is provided.

        if (action.tooltip != null) {
          iconButton = MarkdownTooltip(
            message: action.tooltip!,
            child: iconButton,
          );
        }

        actions.add(iconButton);
      }
    }

    // Add theme toggle if configured.

    if (widget.themeToggle != null && widget.themeToggle!.enabled) {
      final themeConfig = widget.themeToggle!;
      final currentThemeMode = _getCurrentThemeMode();
      final themeToggleCallback = _getThemeToggleCallback();

      // Determine whether to show theme toggle based on screen width.

      bool shouldShowThemeToggle = true;
      if (!themeConfig.showOnVeryNarrowScreen &&
          screenWidth < config.veryNarrowScreenThreshold) {
        shouldShowThemeToggle = false;
      } else if (!themeConfig.showOnNarrowScreen &&
          screenWidth < config.narrowScreenThreshold) {
        shouldShowThemeToggle = false;
      }

      if (shouldShowThemeToggle &&
          themeConfig.showInAppBarActions &&
          screenWidth >= config.veryNarrowScreenThreshold) {
        Widget themeButton = IconButton(
          icon: Icon(themeConfig.getCurrentIcon(currentThemeMode)),
          onPressed: themeToggleCallback,
        );

        // Wrap with MarkdownTooltip.

        themeButton = MarkdownTooltip(
          message: themeConfig.getCurrentTooltip(currentThemeMode),
          child: themeButton,
        );

        actions.add(themeButton);
      }
    }

    // Add overflow menu only if screen is very narrow.
    // On wider screens, show overflow items as regular buttons.

    final hasOverflowItems = config.overflowItems.isNotEmpty;
    final hasThemeToggleInOverflow = widget.themeToggle != null &&
        widget.themeToggle!.enabled &&
        (!widget.themeToggle!.showInAppBarActions ||
            screenWidth < config.veryNarrowScreenThreshold);

    final aboutConfig = widget.aboutConfig ?? const SolidAboutConfig();
    final hasAboutInOverflow =
        aboutConfig.enabled && screenWidth < config.veryNarrowScreenThreshold;

    if (screenWidth < config.veryNarrowScreenThreshold &&
        (hasOverflowItems || hasThemeToggleInOverflow || hasAboutInOverflow)) {
      // Build overflow menu items list.

      List<PopupMenuItem<String>> overflowMenuItems = [];

      // Add regular overflow items.

      overflowMenuItems.addAll(
        config.overflowItems.where((item) => item.showInOverflow).map(
              (item) => PopupMenuItem<String>(
                value: item.id,
                child: Row(
                  children: [
                    Icon(item.icon),
                    const SizedBox(width: 8),
                    Text(item.label),
                  ],
                ),
              ),
            ),
      );

      // Add theme toggle to overflow menu if configured.

      if (hasThemeToggleInOverflow) {
        final themeConfig = widget.themeToggle!;
        final currentThemeMode = _getCurrentThemeMode();
        overflowMenuItems.add(
          PopupMenuItem<String>(
            value: 'theme_toggle',
            child: Row(
              children: [
                Icon(themeConfig.getCurrentIcon(currentThemeMode)),
                const SizedBox(width: 8),
                Text(themeConfig.getCurrentOverflowLabel(currentThemeMode)),
              ],
            ),
          ),
        );
      }

      // Add About button to overflow menu if configured.

      if (hasAboutInOverflow) {
        overflowMenuItems.add(
          PopupMenuItem<String>(
            value: 'about',
            child: Row(
              children: [
                Icon(aboutConfig.effectiveIcon),
                const SizedBox(width: 8),
                Text('About'),
              ],
            ),
          ),
        );
      }

      actions.add(
        PopupMenuButton<String>(
          onSelected: (String id) {
            if (id == 'theme_toggle') {
              _getThemeToggleCallback()?.call();
            } else if (id == 'about') {
              if (aboutConfig.onPressed != null) {
                aboutConfig.onPressed!();
              } else {
                // Show default About dialogue
                SolidAbout.show(context, aboutConfig);
              }
            } else {
              final item =
                  config.overflowItems.firstWhere((item) => item.id == id);
              item.onSelected();
            }
          },
          itemBuilder: (BuildContext context) => overflowMenuItems,
        ),
      );
    } else if (screenWidth >= config.veryNarrowScreenThreshold) {
      // On wider screens, show overflow items as regular icon buttons.

      for (final item in config.overflowItems) {
        Widget iconButton = IconButton(
          icon: Icon(item.icon),
          onPressed: item.onSelected,
        );

        // Wrap with MarkdownTooltip.

        iconButton = MarkdownTooltip(
          message: item.label,
          child: iconButton,
        );

        actions.add(iconButton);
      }
    }

    // Store About button to add at the very end.

    Widget? aboutButton;

    // Prepare About button if it should be shown.

    if (aboutConfig.enabled &&
        aboutConfig.shouldShow(
          screenWidth,
          config.narrowScreenThreshold,
          config.veryNarrowScreenThreshold,
        ) &&
        screenWidth >= config.veryNarrowScreenThreshold) {
      aboutButton = SolidAboutButton(
        config: aboutConfig,
      );
    }

    // Add About button at the very end if it was prepared.

    if (aboutButton != null) {
      actions.add(aboutButton);
    }

    return AppBar(
      title: Text(config.title),
      backgroundColor: config.backgroundColor,
      automaticallyImplyLeading: !isWideScreen,

      // Show hamburger menu only on narrow screens.

      actions: actions.isEmpty ? null : actions,
    );
  }

  /// Determine the appropriate AppBar based on the appBar parameter type.

  PreferredSizeWidget? _resolveAppBar(
    BuildContext context,
    bool isCompatibilityMode,
  ) {
    // Handle different appBar parameter types.

    if (widget.appBar is PreferredSizeWidget) {
      // Standard AppBar provided - use directly.

      return widget.appBar as PreferredSizeWidget;
    } else if (widget.appBar is SolidAppBarConfig) {
      // SolidAppBarConfig provided - build using SolidUI.

      return _buildAppBar(context);
    } else if (widget.appBar == null) {
      // No appBar specified.

      if (isCompatibilityMode) {
        // Use scaffoldAppBar in compatibility mode.

        return widget.scaffoldAppBar;
      } else {
        // Build default SolidUI AppBar if we have a menu.

        return widget.menu != null ? _buildAppBar(context) : null;
      }
    }

    // Fallback: treat as compatibility mode.

    return widget.scaffoldAppBar;
  }

  /// Builds the navigation drawer.

  Widget? _buildDrawer() {
    final isWideScreen = _isWideScreen(context);

    // Always show drawer on narrow screens, even without AppBar.
    // But only if we have menu items (not in compatibility mode).

    if (isWideScreen || widget.menu == null) {
      return null;
    }

    return SolidNavDrawer(
      userInfo: widget.userInfo,
      tabs: _convertToNavTabs(),
      selectedIndex: _currentSelectedIndex,
      onTabSelected: _onMenuSelected,
      onLogout: widget.onLogout,
      showLogout: widget.onLogout != null,
    );
  }

  /// Gets the current selected index.

  int get _currentSelectedIndex {
    return widget.selectedIndex ?? _selectedIndex;
  }

  /// Builds the navigation bar.

  Widget _buildNavBar() {
    return SolidNavBar(
      tabs: _convertToNavTabs(),
      selectedIndex: _currentSelectedIndex,
      onTabSelected: _onMenuSelected,
      onShowAlert: widget.onShowAlert,
    );
  }

  /// Builds the main body content.

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = _isWideScreen(context);

    // Get the effective child content.

    Widget? effectiveChild;

    // Get child from selected menu item.

    if (widget.menu != null &&
        _currentSelectedIndex < widget.menu!.length &&
        widget.menu![_currentSelectedIndex].child != null) {
      effectiveChild = widget.menu![_currentSelectedIndex].child;
    } else {
      // Fallback to widget.child or widget.body for compatibility.

      effectiveChild = widget.child ?? widget.body;
    }

    // If no content provided, return empty container.

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
                _buildNavBar(),
                VerticalDivider(width: 1, color: theme.dividerColor),
                Expanded(child: effectiveChild),
              ],
            ),
          ),
        ],
      );
    } else {
      // Narrow screen: show content only (drawer menu handled by Scaffold).

      List<Widget> columnChildren = [];

      // Add divider if AppBar is present.

      if (widget.appBar != null) {
        columnChildren.add(Divider(height: 1, color: theme.dividerColor));
      }

      columnChildren.add(Expanded(child: effectiveChild));

      return Column(children: columnChildren);
    }
  }

  /// Builds the status bar.

  Widget? _buildStatusBar() {
    if (widget.statusBar == null) return null;

    // Create a modified config with updated security key status.

    SolidStatusBarConfig modifiedConfig = widget.statusBar!;

    if (widget.statusBar!.securityKeyStatus != null) {
      final originalStatus = widget.statusBar!.securityKeyStatus!;
      final updatedStatus = SolidSecurityKeyStatus(
        isKeySaved: originalStatus.isKeySaved ?? _isKeySaved,
        onTap: originalStatus.onTap,
        onKeyStatusChanged: originalStatus.onKeyStatusChanged,
        title: originalStatus.title,
        appWidget: originalStatus.appWidget,
        keySavedText: originalStatus.keySavedText,
        keyNotSavedText: originalStatus.keyNotSavedText,
        tooltip: originalStatus.tooltip,
      );

      modifiedConfig = SolidStatusBarConfig(
        serverInfo: widget.statusBar!.serverInfo,
        loginStatus: widget.statusBar!.loginStatus,
        securityKeyStatus: updatedStatus,
        customItems: widget.statusBar!.customItems,
        showOnNarrowScreens: widget.statusBar!.showOnNarrowScreens,
      );
    }

    return SolidStatusBar(config: modifiedConfig);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = _isWideScreen(context);

    // Check if this is compatibility mode (standard Scaffold behavior).

    final bool isCompatibilityMode = widget.menu == null;

    // Determine which floating action button to show.

    Widget? fab = widget.floatingActionButton;

    // If no AppBar and narrow screen, show hamburger FAB (only in SolidUI mode).

    if (!isCompatibilityMode && widget.appBar == null && !isWideScreen) {
      fab = MarkdownTooltip(
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
                _scaffoldKey.currentState?.openDrawer();
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: _resolveAppBar(context, isCompatibilityMode),
      drawer: isCompatibilityMode ? widget.drawer : _buildDrawer(),
      endDrawer: widget.endDrawer,
      backgroundColor: widget.backgroundColor ?? theme.colorScheme.surface,
      floatingActionButton: fab,
      floatingActionButtonLocation:
          (!isCompatibilityMode && widget.appBar == null && !isWideScreen)
              ? const _SolidNavButtonStartTopLocation()
              : (widget.floatingActionButtonLocation ??
                  FloatingActionButtonLocation.endFloat),
      floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
      body: isCompatibilityMode ? widget.body : _buildBody(context),
      bottomNavigationBar:
          isCompatibilityMode ? widget.bottomNavigationBar : _buildStatusBar(),
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

/// Custom FloatingActionButtonLocation for hamburger button in top-left corner.

class _SolidNavButtonStartTopLocation extends FloatingActionButtonLocation {
  const _SolidNavButtonStartTopLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    const double leftPadding = 16.0;
    const double topPadding = 16.0;

    return Offset(leftPadding, topPadding);
  }
}
