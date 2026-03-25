/// Solid Navigation Drawer.
///
// Time-stamp: <Thursday 2026-03-26 09:22:09 +1100 Graham Williams>
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

import 'package:package_info_plus/package_info_plus.dart';
import 'package:solidpod/solidpod.dart' show isUserLoggedIn;

import 'package:solidui/src/constants/navigation.dart';
import 'package:solidui/src/handlers/solid_auth_handler.dart';
import 'package:solidui/src/utils/solid_notifications.dart';
import 'package:solidui/src/widgets/solid_nav_drawer_header.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_security_key_cache_dialogs.dart';
import 'package:solidui/src/widgets/solid_security_key_manager.dart';
import 'package:solidui/src/widgets/solid_status_bar_models.dart';

/// A solid navigation drawer component.

class SolidNavDrawer extends StatefulWidget {
  /// User information to display in the drawer header.

  final SolidNavUserInfo? userInfo;

  /// List of navigation tabs to display.

  final List<SolidNavTab> tabs;

  /// Currently selected tab index.

  final int? selectedIndex;

  /// Callback when a tab is selected.

  final void Function(int) onTabSelected;

  /// Optional logout callback.

  final void Function(BuildContext)? onLogout;

  /// Optional custom logout icon.

  final IconData? logoutIcon;

  /// Optional custom logout text.

  final String? logoutText;

  /// Whether to show the logout option.

  final bool showLogout;

  /// Callback when the user name area is tapped (for login/logout).

  final void Function(BuildContext)? onUserNameTap;

  /// Security key status to display above the logout option.

  final SolidSecurityKeyStatus? securityKeyStatus;

  /// Optional additional menu items to display after the main tabs.

  final List<Widget>? additionalMenuItems;

  /// Optional custom drawer shape.

  final ShapeBorder? drawerShape;

  const SolidNavDrawer({
    super.key,
    this.userInfo,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onLogout,
    this.logoutIcon,
    this.logoutText,
    this.showLogout = true,
    this.onUserNameTap,
    this.securityKeyStatus,
    this.additionalMenuItems,
    this.drawerShape,
  });

  @override
  State<SolidNavDrawer> createState() => _SolidNavDrawerState();
}

class _SolidNavDrawerState extends State<SolidNavDrawer> {
  String? _appVersion;
  bool _isVersionLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.userInfo?.versionConfig != null) {
      _loadAppVersion();
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
          _isVersionLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading app version: $e');
      if (mounted) {
        setState(() {
          _appVersion = null;
          _isVersionLoaded = true;
        });
      }
    }
  }

  String _getVersionToDisplay() {
    if (_isVersionLoaded && _appVersion != null && _appVersion!.isNotEmpty) {
      return _appVersion!;
    }
    return '0.0.0+0';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      shape: widget.drawerShape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
          ),
      child: ListView(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        children: <Widget>[
          if (widget.userInfo != null)
            SolidNavDrawerHeader.build(
              context: context,
              theme: theme,
              user: widget.userInfo!,
              isVersionLoaded: _isVersionLoaded,
              appVersion: _appVersion,
              getVersionToDisplay: _getVersionToDisplay,
              onUserNameTap: widget.onUserNameTap != null
                  ? () {
                      Navigator.of(context).pop();
                      widget.onUserNameTap!(context);
                    }
                  : null,
            ),
          Container(
            padding: const EdgeInsets.all(NavigationConstants.navDrawerPadding),
            child: Column(
              children: [
                ...widget.tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tab = entry.value;
                  return _buildNavTile(context, theme, index, tab);
                }),
                if (widget.additionalMenuItems != null)
                  ...widget.additionalMenuItems!,
                if (widget.securityKeyStatus != null ||
                    widget.onUserNameTap != null)
                  ..._buildBottomSection(context, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context,
    ThemeData theme,
    int index,
    SolidNavTab tab,
  ) {
    return ListTile(
      leading: Icon(
        tab.icon,
        color: index == widget.selectedIndex
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      title: Text(
        tab.title,
        style: TextStyle(
          fontWeight:
              index == widget.selectedIndex ? FontWeight.w600 : FontWeight.w400,
          color: index == widget.selectedIndex
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ),
      selected: index == widget.selectedIndex,
      selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      onTap: () {
        widget.onTabSelected(index);
        Navigator.of(context).pop();
      },
    );
  }

  bool get _isLoggedIn =>
      widget.userInfo?.webId != null && widget.userInfo!.webId!.isNotEmpty;

  List<Widget> _buildBottomSection(BuildContext context, ThemeData theme) {
    return [
      Divider(
        height: NavigationConstants.navDividerHeight,
        color: theme.dividerColor,
      ),
      if (widget.securityKeyStatus != null)
        _buildSecurityKeyTile(context, theme),
      if (widget.onUserNameTap != null) _buildLoginStatusTile(context, theme),
    ];
  }

  Widget _buildSecurityKeyTile(BuildContext context, ThemeData theme) {
    final status = widget.securityKeyStatus!;
    final isKeySaved = status.isKeySaved == true;

    return ListTile(
      title: Text(
        status.displayText,
        style: TextStyle(
          color: isKeySaved ? null : theme.colorScheme.primary,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        if (status.onTap != null) {
          status.onTap!();
        } else {
          _showSecurityKeyManager(context, status);
        }
      },
    );
  }

  Widget _buildLoginStatusTile(BuildContext context, ThemeData theme) {
    final statusText = _isLoggedIn ? 'Logged In' : 'Not Logged In';

    return ListTile(
      title: Text(
        statusText,
        style: TextStyle(
          color: _isLoggedIn ? null : theme.colorScheme.primary,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        widget.onUserNameTap!(context);
      },
    );
  }

  Future<void> _showSecurityKeyManager(
    BuildContext context,
    SolidSecurityKeyStatus config,
  ) async {
    final isLoggedIn = await isUserLoggedIn();
    if (!context.mounted) return;

    if (!isLoggedIn) {
      final shouldLogin =
          await SecurityKeyCacheDialogs.showLoginRequiredDialog(context);
      if (shouldLogin && context.mounted) {
        await SolidAuthHandler.instance.handleLogin(context);
      }
      return;
    }

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext dialogContext) => SolidSecurityKeyManager(
        config: SolidSecurityKeyManagerConfig(
          appWidget: config.appWidget ?? const SizedBox(),
          title: config.title ?? 'Security Key Management',
        ),
        onKeyStatusChanged: (bool hasKey) {
          config.onKeyStatusChanged?.call(hasKey);
          try {
            SecurityKeyStatusChangedNotification(
              isKeySaved: hasKey,
            ).dispatch(dialogContext);
          } catch (e) {
            debugPrint('Could not refresh security key status: $e');
          }
        },
      ),
    );
  }
}
