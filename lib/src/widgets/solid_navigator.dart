/// Solid Navigator - Simplified unified navigation component.
///
// Time-stamp: <Monday 2025-01-27 14:30:00 +1000 Tony Chen>
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

import 'package:solidui/src/constants/navigation.dart';
import 'package:solidui/src/widgets/solid_nav_bar.dart';
import 'package:solidui/src/widgets/solid_nav_drawer.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_navigator_models.dart';

import 'package:solidui/src/widgets/solid_status_bar.dart';
import 'package:solidui/src/widgets/solid_status_bar_models.dart';

/// Simplified unified navigation component that automatically handles responsive layout switching.
///
/// Shows navigation rail on wide screens and drawer menu on narrow screens.
/// Supports optional AppBar and status bar.
///
/// Usage example:
/// ```dart
/// SolidNavigator(
///   menu: [
///     SolidMenuItem(title: 'Home', icon: Icons.home, content: HomeWidget()),
///     SolidMenuItem(title: 'Settings', icon: Icons.settings, content: SettingsWidget()),
///   ],
///   child: Column(
///     children: [
///       Text('Main content'),
///     ],
///   ),
/// )
/// ```

class SolidNavigator extends StatefulWidget {
  /// List of menu items.

  final List<SolidMenuItem> menu;

  /// Main content area.

  final Widget child;

  /// Optional AppBar configuration.

  final SolidAppBarConfig? appBar;

  /// Optional status bar configuration.

  final SolidStatusBarConfig? statusBar;

  /// Optional user information configuration.

  final SolidNavUserInfo? userInfo;

  /// Optional logout callback.

  final void Function(BuildContext)? onLogout;

  /// Optional alert dialog callback.

  final void Function(BuildContext, String, String?)? onShowAlert;

  /// Narrow screen threshold.

  final double narrowScreenThreshold;

  /// Background colour.

  final Color? backgroundColor;

  /// Floating action button.

  final Widget? floatingActionButton;

  /// Initial selected menu index.

  final int initialIndex;

  /// Optional menu selection callback (for external state management).

  final void Function(int)? onMenuSelected;

  /// Optional current selected index (for external state management).

  final int? selectedIndex;

  const SolidNavigator({
    super.key,
    required this.menu,
    required this.child,
    this.appBar,
    this.statusBar,
    this.userInfo,
    this.onLogout,
    this.onShowAlert,
    this.narrowScreenThreshold = NavigationConstants.narrowScreenThreshold,
    this.backgroundColor,
    this.floatingActionButton,
    this.initialIndex = 0,
    this.onMenuSelected,
    this.selectedIndex,
  });

  @override
  State<SolidNavigator> createState() => _SolidNavigatorState();
}

class _SolidNavigatorState extends State<SolidNavigator> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
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

    final menuItem = widget.menu[index];
    if (menuItem.onTap != null) {
      menuItem.onTap!(context);
    }
  }

  /// Determines if the screen is wide.

  bool _isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > widget.narrowScreenThreshold;
  }

  /// Converts SolidMenuItem to SolidNavTab.

  List<SolidNavTab> _convertToNavTabs() {
    return widget.menu
        .map((item) => SolidNavTab(
              title: item.title,
              icon: item.icon,
              color: item.color,
              content: item.content,
              tooltip: item.tooltip,
              message: item.message,
              dialogTitle: item.dialogTitle,
              action: item.onTap,
            ))
        .toList();
  }

  /// Builds the AppBar.

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (widget.appBar == null) return null;

    final config = widget.appBar!;
    final isWideScreen = _isWideScreen(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Build action buttons.

    List<Widget> actions = [];

    for (final action in config.actions) {
      // Determine whether to show button based on screen width.

      bool shouldShow = true;
      if (action.hideOnVeryNarrowScreen &&
          screenWidth < config.veryNarrowScreenThreshold) {
        shouldShow = false;
      } else if (action.hideOnNarrowScreen &&
          screenWidth < config.narrowScreenThreshold) {
        shouldShow = false;
      }

      if (shouldShow) {
        actions.add(
          IconButton(
            icon: Icon(action.icon),
            onPressed: action.onPressed,
            tooltip: action.tooltip,
            color: action.color,
          ),
        );
      }
    }

    // Add overflow menu.

    if (config.overflowItems.isNotEmpty) {
      actions.add(
        PopupMenuButton<String>(
          onSelected: (String id) {
            final item =
                config.overflowItems.firstWhere((item) => item.id == id);
            item.onSelected();
          },
          itemBuilder: (BuildContext context) {
            return config.overflowItems
                .where((item) => item.showInOverflow)
                .map((item) => PopupMenuItem<String>(
                      value: item.id,
                      child: Row(
                        children: [
                          Icon(item.icon),
                          const SizedBox(width: 8),
                          Text(item.label),
                        ],
                      ),
                    ))
                .toList();
          },
        ),
      );
    }

    return AppBar(
      title: Text(config.title),
      backgroundColor: config.backgroundColor,
      automaticallyImplyLeading: !isWideScreen,
      // Show hamburger menu only on narrow screens.
      actions: actions.isEmpty ? null : actions,
    );
  }

  /// Builds the navigation drawer.

  Widget? _buildDrawer() {
    final isWideScreen = _isWideScreen(context);
    if (isWideScreen) return null;

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
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      );
    } else {
      // Narrow screen: show content only (drawer menu handled by Scaffold).

      return Column(
        children: [
          Divider(height: 1, color: theme.dividerColor),
          Expanded(child: widget.child),
        ],
      );
    }
  }

  /// Builds the status bar.

  Widget? _buildStatusBar() {
    if (widget.statusBar == null) return null;
    return SolidStatusBar(config: widget.statusBar!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(),
      backgroundColor: widget.backgroundColor ?? theme.colorScheme.surface,
      floatingActionButton: widget.floatingActionButton,
      body: _buildBody(context),
      bottomNavigationBar: _buildStatusBar(),
    );
  }
}
