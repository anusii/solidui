/// Solid Navigation Models - Generic data models for navigation components.
///
// Time-stamp: <Wednesday 2025-08-06 16:30:00 +1000 Tony Chen>
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

import 'package:solidui/solidui.dart';

/// Configuration for a navigation tab.

class SolidNavTab {
  /// The display title of the tab.

  final String title;

  /// The icon to display for the tab.

  final IconData icon;

  /// Optional custom colour for the icon. If null, uses theme default.

  final Color? color;

  /// The child widget to display when this tab is selected.

  final Widget? child;

  /// Optional tooltip message for the tab (supports Markdown).

  final String? tooltip;

  /// Optional dialogue message to show when tab is selected.

  final String? message;

  /// Optional dialogue title when showing a message.

  final String? dialogTitle;

  /// Optional custom action to execute when tab is selected.

  final void Function(BuildContext)? action;

  const SolidNavTab({
    required this.title,
    required this.icon,
    this.color,
    this.child,
    this.tooltip,
    this.message,
    this.dialogTitle,
    this.action,
  });
}

/// User information configuration for the navigation drawer.

class SolidNavUserInfo {
  /// The user's display name. If null and webId is provided,
  /// the username will be automatically extracted from the WebID.

  final String? userName;

  /// The user's WebID (optional).

  final String? webId;

  /// Whether to show the WebID in the drawer.

  final bool showWebId;

  /// Custom user avatar widget (optional).

  final Widget? avatar;

  /// Custom user avatar icon (used if avatar widget is null).

  final IconData? avatarIcon;

  /// Custom avatar size.

  final double? avatarSize;

  /// Version configuration for displaying version information in the drawer.

  final SolidVersionConfig? versionConfig;

  const SolidNavUserInfo({
    this.userName,
    this.webId,
    this.showWebId = false,
    this.avatar,
    this.avatarIcon,
    this.avatarSize,
    this.versionConfig,
  });

  /// Extracts username from WebID URL.

  static String _extractUsernameFromWebId(String webId) {
    try {
      final uri = Uri.parse(webId);
      final pathSegments = uri.pathSegments;

      // Find the username segment (typically the first non-empty path segment).

      for (final segment in pathSegments) {
        if (segment.isNotEmpty &&
            segment != 'profile' &&
            segment != 'card' &&
            !segment.startsWith('#')) {
          return segment;
        }
      }

      // Fallback: try to extract from the last slash in the full URL
      final lastSlashIndex = webId.lastIndexOf('/');
      if (lastSlashIndex != -1 && lastSlashIndex < webId.length - 1) {
        String candidate = webId.substring(lastSlashIndex + 1);

        // Remove common suffixes
        const suffixes = ['profile', 'card#me', '#me'];
        for (final suffix in suffixes) {
          if (candidate.endsWith(suffix)) {
            candidate = candidate.substring(
              0,
              candidate.length - suffix.length,
            );
            if (candidate.endsWith('/')) {
              candidate = candidate.substring(0, candidate.length - 1);
            }
          }
        }

        if (candidate.isNotEmpty) {
          return candidate;
        }
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  /// Gets the effective display name, extracting from WebID if necessary.

  String get effectiveUserName {
    if (userName != null && userName!.isNotEmpty) {
      return userName!;
    }

    if (webId != null && webId!.isNotEmpty) {
      final extracted = _extractUsernameFromWebId(webId!);
      if (extracted.isNotEmpty) {
        return extracted;
      }
    }

    return 'Not logged in';
  }
}

/// Configuration for an AppBar action button.

class SolidAppBarAction {
  /// Unique identifier for this action. Used for ordering and visibility
  /// settings in Preferences. If not provided, an auto-generated ID will be
  /// used based on the action's position in the list.

  final String? id;

  /// The icon to display.

  final IconData icon;

  /// The tooltip message to show on hover/long press.

  final String? tooltip;

  /// The callback when the button is pressed.

  final VoidCallback onPressed;

  /// Custom colour for the icon. If null, uses theme primary colour.

  final Color? color;

  /// Whether this action should be shown on narrow screens.

  final bool showOnNarrowScreen;

  /// Whether this action should be shown on very narrow screens.

  final bool showOnVeryNarrowScreen;

  /// Initial order index for this action. Lower values appear first (leftmost).
  /// If not specified, the order will be based on the position in the actions
  /// list. This can be overridden by user preferences.

  final int? initialIndex;

  const SolidAppBarAction({
    this.id,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.showOnNarrowScreen = true,
    this.showOnVeryNarrowScreen = true,
    this.initialIndex,
  });
}

/// Configuration for an overflow menu item.

class SolidOverflowMenuItem {
  /// Unique identifier for this menu item.

  final String id;

  /// The icon to display.

  final IconData icon;

  /// The text label to display.

  final String label;

  /// The callback when the item is selected.

  final VoidCallback onSelected;

  /// Whether this item should be shown in the overflow menu.

  final bool showInOverflow;

  const SolidOverflowMenuItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.onSelected,
    this.showInOverflow = true,
  });
}

/// Configuration for version information display.

class SolidVersionConfig {
  /// The version string to display.

  final String? version;

  /// The URL to the changelog.

  final String? changelogUrl;

  /// Whether to show the date alongside the version.

  final bool showDate;

  /// The tooltip message for the version widget.

  final String? tooltip;

  /// Custom text style for the version widget. The default text style
  /// uses color to represent the currency of the app, where blue is
  /// most recent version, and red is more recent version available.

  final TextStyle? userTextStyle;

  /// Creates version configuration.

  const SolidVersionConfig({
    this.version,
    this.changelogUrl,
    this.showDate = true,
    this.tooltip,
    this.userTextStyle,
  });
}

/// Configuration for theme toggle functionality.

class SolidNavThemeConfig {
  /// Whether the theme toggle is enabled.

  final bool enabled;

  /// The tooltip message for light mode.

  final String lightModeTooltip;

  /// The tooltip message for dark mode.

  final String darkModeTooltip;

  /// Custom callback for theme toggle. If null, uses default behaviour.

  final Future<void> Function()? onToggle;

  const SolidNavThemeConfig({
    this.enabled = true,
    this.lightModeTooltip = 'Switch to light theme',
    this.darkModeTooltip = 'Switch to dark theme',
    this.onToggle,
  });
}

/// Comprehensive configuration for creating an AppBar.

class SolidAppBarConfig {
  /// The title to display in the AppBar.

  final String title;

  /// Background colour for the AppBar. If null, uses theme default.

  final Color? backgroundColor;

  /// List of action buttons to display.

  final List<SolidAppBarAction> actions;

  /// List of overflow menu items for narrow screens.

  final List<SolidOverflowMenuItem> overflowItems;

  /// Version configuration. If null, version widget is not shown.

  final SolidVersionConfig? versionConfig;

  /// Theme toggle configuration. If null, theme toggle is not shown.

  final SolidNavThemeConfig? themeConfig;

  /// Width threshold for narrow screens.

  final double narrowScreenThreshold;

  /// Width threshold for very narrow screens.

  final double veryNarrowScreenThreshold;

  const SolidAppBarConfig({
    required this.title,
    this.backgroundColor,
    this.actions = const [],
    this.overflowItems = const [],
    this.versionConfig,
    this.themeConfig,
    this.narrowScreenThreshold = NavigationConstants.narrowScreenThreshold,
    this.veryNarrowScreenThreshold =
        NavigationConstants.veryNarrowScreenThreshold,
  });
}

/// Configuration for navigation drawer user information.

class SolidNavUserConfig {
  /// The user's display name.

  final String userName;

  /// The user's WebID or identifier (optional).

  final String? userId;

  /// Whether to show the user ID in the drawer.

  final bool showUserId;

  /// Custom user avatar widget (optional).

  final Widget? avatar;

  /// Custom user avatar icon (used if avatar widget is null).

  final IconData? avatarIcon;

  /// Custom avatar size.

  final double? avatarSize;

  /// Background colour for the user header.

  final Color? headerBackgroundColor;

  /// Text colour for the user header.

  final Color? headerTextColor;

  const SolidNavUserConfig({
    required this.userName,
    this.userId,
    this.showUserId = false,
    this.avatar,
    this.avatarIcon,
    this.avatarSize,
    this.headerBackgroundColor,
    this.headerTextColor,
  });
}

/// Configuration for logout functionality.

class SolidLogoutConfig {
  /// Whether to show logout option.

  final bool enabled;

  /// Custom logout icon.

  final IconData icon;

  /// Custom logout text.

  final String text;

  /// The logout callback.

  final void Function(BuildContext) onLogout;

  /// Custom colour for logout elements.

  final Color? color;

  const SolidLogoutConfig({
    this.enabled = true,
    this.icon = Icons.logout,
    this.text = 'Logout',
    required this.onLogout,
    this.color,
  });
}
