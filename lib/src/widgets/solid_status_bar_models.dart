/// Solid Status Bar Models.
///
// Time-stamp: <Monday 2025-08-11 15:30:00 +1000 Tony Chen>
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

/// Configuration for a status bar item that displays interactive text.

class SolidStatusBarItem {
  /// The display text for the status bar item.

  final String text;

  /// Optional tooltip message to show on hover/long press.

  final String? tooltip;

  /// Callback when the status bar item is tapped.

  final VoidCallback? onTap;

  /// Text style for the status bar item.

  final TextStyle? style;

  /// Whether this item should be highlighted (e.g., for error states).

  final bool isHighlighted;

  /// The highlight colour to use when isHighlighted is true.

  final Color? highlightColor;

  const SolidStatusBarItem({
    required this.text,
    this.tooltip,
    this.onTap,
    this.style,
    this.isHighlighted = false,
    this.highlightColor,
  });
}

/// Configuration for server information in the status bar.

class SolidServerInfo {
  /// The server URI to display and link to.

  final String serverUri;

  /// Optional custom display text (if null, uses serverUri).

  final String? displayText;

  /// Tooltip message for the server info.

  final String? tooltip;

  /// Whether the server link is clickable.

  final bool isClickable;

  const SolidServerInfo({
    required this.serverUri,
    this.displayText,
    this.tooltip,
    this.isClickable = true,
  });

  /// Gets the tooltip for server info.

  String get tooltipText {
    if (tooltip != null) return tooltip!;

    if (isClickable) {
      return 'Server: $serverUri\n\nClick to open server in browser.\n\n'
          'Manages your personal data POD where your data is stored securely.';
    } else {
      return 'Server: $serverUri.\n\nYour personal data POD server.';
    }
  }
}

/// Configuration for login status in the status bar.

class SolidLoginStatus {
  /// The current WebID (null if not logged in).

  final String? webId;

  /// Callback when login/logout is tapped.

  final VoidCallback onTap;

  /// Custom text for logged in state (if null, uses default).

  final String? loggedInText;

  /// Custom text for logged out state (if null, uses default).

  final String? loggedOutText;

  /// Tooltip message for logged in state.

  final String? loggedInTooltip;

  /// Tooltip message for logged out state.

  final String? loggedOutTooltip;

  const SolidLoginStatus({
    this.webId,
    required this.onTap,
    this.loggedInText,
    this.loggedOutText,
    this.loggedInTooltip,
    this.loggedOutTooltip,
  });

  /// Whether the user is currently logged in.

  bool get isLoggedIn => webId != null && webId!.isNotEmpty;

  /// Get the display text based on login status.

  String get displayText {
    if (isLoggedIn) {
      return loggedInText ?? 'Logged In';
    } else {
      return loggedOutText ?? 'Not Logged In';
    }
  }

  /// Get the tooltip based on login status.

  String get tooltipText =>
      isLoggedIn ? loggedInTooltipContent : loggedOutTooltipContent;

  /// Gets the logged-in tooltip.

  String get loggedInTooltipContent {
    if (loggedInTooltip != null) return loggedInTooltip!;

    return 'Currently Logged In (WebID: $webId). Click to log out.\n\n'
        'Your data is secure and stored in your personal POD.';
  }

  /// Gets the logged-out tooltip.

  String get loggedOutTooltipContent {
    if (loggedOutTooltip != null) return loggedOutTooltip!;

    return 'Login Required.\n\nCurrent status: Not logged in. '
        'Click to log in to your pod.\n\n'
        'Access your personal data by connecting to your Solid POD.';
  }
}

/// Configuration for security key status in the status bar.

class SolidSecurityKeyStatus {
  /// Whether the security key is saved.

  final bool? isKeySaved;

  /// Optional callback when security key management is tapped.
  /// If null, SolidScaffold will handle security key management automatically.

  final VoidCallback? onTap;

  /// Optional callback for key status changes.
  /// Called when the security key status changes.

  final Function(bool)? onKeyStatusChanged;

  /// Custom title for the security key manager dialogue.

  final String? title;

  /// Optional custom app widget to display in the security key manager.
  /// If null, a default widget will be used.

  final Widget? appWidget;

  /// Custom text for key saved state (if null, uses default).

  final String? keySavedText;

  /// Custom text for key not saved state (if null, uses default).

  final String? keyNotSavedText;

  /// Tooltip message for the security key status.

  final String? tooltip;

  const SolidSecurityKeyStatus({
    this.isKeySaved,
    this.onTap,
    this.onKeyStatusChanged,
    this.title,
    this.appWidget,
    this.keySavedText,
    this.keyNotSavedText,
    this.tooltip,
  });

  /// Get the display text based on key status.

  String get displayText {
    if (isKeySaved == true) {
      return keySavedText ?? 'Security Key: Saved';
    } else {
      return keyNotSavedText ?? 'Security Key: Not Saved';
    }
  }

  /// Gets the tooltip for the security key status.

  String get tooltipText {
    if (tooltip != null) return tooltip!;

    return '''

**Security Key Manager**: Tap here to manage your security key settings.

View your current security key status, save a new security key, or remove 
an existing security key. Your security key is essential for encrypting 
and protecting your data.

''';
  }
}

/// Configuration for additional custom status bar items.

class SolidCustomStatusBarItem {
  /// Unique identifier for this status bar item.

  final String id;

  /// The widget to display in the status bar.

  final Widget widget;

  /// Priority for ordering (higher numbers appear later).

  final int priority;

  const SolidCustomStatusBarItem({
    required this.id,
    required this.widget,
    this.priority = 0,
  });
}

/// Comprehensive configuration for the Solid status bar.

class SolidStatusBarConfig {
  /// Server information configuration.

  final SolidServerInfo? serverInfo;

  /// Login status configuration.

  final SolidLoginStatus? loginStatus;

  /// Security key status configuration.

  final SolidSecurityKeyStatus? securityKeyStatus;

  /// List of additional custom status bar items.

  final List<SolidCustomStatusBarItem> customItems;

  /// Whether to show the status bar on narrow screens.

  final bool showOnNarrowScreens;

  /// Custom narrow screen threshold (if null, uses NavigationConstants).

  final double? narrowScreenThreshold;

  /// Background colour for the status bar.

  final Color? backgroundColor;

  /// Height for narrow layout.

  final double narrowLayoutHeight;

  /// Height for medium layout.

  final double mediumLayoutHeight;

  /// Height for wide layout.

  final double wideLayoutHeight;

  /// Padding for the status bar content.

  final EdgeInsets padding;

  /// Spacing between status bar items.

  final double itemSpacing;

  const SolidStatusBarConfig({
    this.serverInfo,
    this.loginStatus,
    this.securityKeyStatus,
    this.customItems = const [],
    this.showOnNarrowScreens = false,
    this.narrowScreenThreshold,
    this.backgroundColor,
    this.narrowLayoutHeight = 100.0,
    this.mediumLayoutHeight = 80.0,
    this.wideLayoutHeight = 60.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.itemSpacing = 16.0,
  });
}

/// Layout mode for the status bar based on screen width.

enum SolidStatusBarLayout {
  narrow,
  medium,
  wide,
}
