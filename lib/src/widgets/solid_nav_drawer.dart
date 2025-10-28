/// Solid Navigation Drawer.
///
// Time-stamp: <Friday 2025-10-17 10:33:35 +1100 Graham Williams>
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

import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version_widget/version_widget.dart';

import 'package:solidui/src/constants/navigation.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';

/// A solid navigation drawer component.
///
/// This widget provides a collapsible navigation drawer that displays
/// when the screen is narrow, replacing the navigation rail.

class SolidNavDrawer extends StatefulWidget {
  /// User information to display in the drawer header.

  final SolidNavUserInfo? userInfo;

  /// List of navigation tabs to display.

  final List<SolidNavTab> tabs;

  /// Currently selected tab index.

  final int selectedIndex;

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
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        children: <Widget>[
          // User info header (if provided).
          if (widget.userInfo != null) _buildUserInfoHeader(context, theme),

          // Navigation items.
          Container(
            padding: const EdgeInsets.all(NavigationConstants.navDrawerPadding),
            child: Column(
              children: [
                // Main navigation tabs.
                ...widget.tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tab = entry.value;

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
                        fontWeight: index == widget.selectedIndex
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: index == widget.selectedIndex
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    selected: index == widget.selectedIndex,
                    selectedTileColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    onTap: () {
                      widget.onTabSelected(index);
                      Navigator.of(context).pop(); // Close drawer.
                    },
                  );
                }),

                // Additional menu items (if provided).
                if (widget.additionalMenuItems != null)
                  ...widget.additionalMenuItems!,

                // Divider and logout option.
                if (widget.showLogout && widget.onLogout != null) ...[
                  Divider(
                    height: NavigationConstants.navDividerHeight,
                    color: theme.dividerColor,
                  ),
                  ListTile(
                    leading: Icon(
                      widget.logoutIcon ?? Icons.logout,
                      color: _canLogout()
                          ? theme.colorScheme.error
                          : theme.disabledColor,
                    ),
                    title: Text(
                      widget.logoutText ?? 'Logout',
                      style: TextStyle(
                        color: _canLogout()
                            ? theme.colorScheme.error
                            : theme.disabledColor,
                      ),
                    ),
                    onTap: _canLogout()
                        ? () {
                            Navigator.of(context).pop(); // Close drawer first.
                            widget.onLogout!(context);
                          }
                        : null,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoHeader(BuildContext context, ThemeData theme) {
    final user = widget.userInfo!;
    final bool willShowVersion = user.versionConfig != null;
    final double bottomPadding = willShowVersion
        ? 8.0 // Add spacing below version
        : NavigationConstants.userHeaderBottomPadding;

    return Container(
      padding: EdgeInsets.only(
        top: NavigationConstants.userHeaderTopPadding +
            MediaQuery.of(context).padding.top,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
      child: Column(
        children: [
          // User avatar.
          user.avatar ??
              Icon(
                user.avatarIcon ?? Icons.account_circle,
                size: user.avatarSize ?? NavigationConstants.userAvatarSize,
                color: theme.colorScheme.onPrimaryContainer,
              ),

          const Gap(NavigationConstants.userInfoSpacing),

          // User name.
          Text(
            user.effectiveUserName,
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontSize: NavigationConstants.userNameFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),

          // WebID (if enabled and available).
          if (user.showWebId &&
              user.webId != null &&
              user.webId!.isNotEmpty) ...[
            const Gap(NavigationConstants.webIdSpacing),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: NavigationConstants.webIdHorizontalPadding,
              ),
              child: InkWell(
                onTap: () => _launchProfileUrl(user.webId!),
                child: Text(
                  _getSimplifiedUrl(user.webId!),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                    fontSize: NavigationConstants.webIdFontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],

          if (user.versionConfig != null) ...[
            const Gap(NavigationConstants.webIdSpacing),
            if (_isVersionLoaded &&
                _appVersion != null &&
                _appVersion!.isNotEmpty)
              _buildVersionInfo(context, theme, user.versionConfig!)
            else
              // The offset of drawer menu entry background block.

              const SizedBox(height: 23.0),
          ],
        ],
      ),
    );
  }

  /// Builds the version information widget.

  Widget _buildVersionInfo(
    BuildContext context,
    ThemeData theme,
    SolidVersionConfig versionConfig,
  ) {
    final versionString =
        (versionConfig.version != null && versionConfig.version!.isNotEmpty)
            ? versionConfig.version!
            : _getVersionToDisplay();

    return VersionWidget(
      version: versionString,
      changelogUrl: versionConfig.changelogUrl,
      showDate: versionConfig.showDate,
    );
  }

  /// Determines if logout functionality is available.

  bool _canLogout() {
    // Logout is available if onLogout callback is provided and showLogout is
    // true.

    return widget.showLogout && widget.onLogout != null;
  }

  /// Simplifies the WebID URL for display purposes.
  /// Returns only the domain name for display.

  String _getSimplifiedUrl(String webId) {
    try {
      final uri = Uri.parse(webId);

      // Return only the host (domain).

      return uri.host;
    } catch (e) {
      // Fallback parsing for malformed URLs.

      try {
        // Remove common prefixes.

        String cleaned = webId;

        // Remove protocol.

        if (cleaned.startsWith('https://')) {
          cleaned = cleaned.substring(8);
        } else if (cleaned.startsWith('http://')) {
          cleaned = cleaned.substring(7);
        }

        // Extract only the domain (remove path).

        final slashIndex = cleaned.indexOf('/');
        if (slashIndex > 0) {
          cleaned = cleaned.substring(0, slashIndex);
        }

        return cleaned;
      } catch (e2) {
        // Final fallback: return original webID.

        return webId;
      }
    }
  }

  /// Gets the complete profile card URL from a WebID.

  String _getProfileCardUrl(String webId) {
    try {
      final uri = Uri.parse(webId);

      // Get the scheme, host, and path segments.

      final scheme = uri.scheme;
      final host = uri.host;
      final pathSegments = uri.pathSegments;

      // Typical webID format: /username/profile/card#me
      // We want to construct: https: //host/username/profile/card#

      if (pathSegments.isNotEmpty) {
        final username = pathSegments.first;
        return '$scheme:' '//$host/$username/profile/card#';
      } else {
        // Fallback: return the original webId.

        return webId;
      }
    } catch (e) {
      // Fallback: return original webID.

      return webId;
    }
  }

  /// Launches the profile card URL in a browser.

  Future<void> _launchProfileUrl(String webId) async {
    try {
      final profileUrl = _getProfileCardUrl(webId);
      final uri = Uri.parse(profileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Cannot launch URL: $profileUrl');
      }
    } catch (e) {
      debugPrint('Error launching profile URL: $e');
    }
  }
}
