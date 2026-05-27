/// Solid Status Bar Models.
///
// Time-stamp: <Wednesday 2026-03-25 08:57:39 +1100 Graham Williams>
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

import 'package:solidui/src/utils/web_id_parser.dart';

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

  /// Optional custom display text (if null, automatically formats serverUri).

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

  /// Creates a SolidServerInfo from a WebID with automatic formatting.

  factory SolidServerInfo.fromWebId(
    String webId, {
    String? tooltip,
    bool isClickable = true,
  }) {
    final serverUri = _extractServerFromWebId(webId);
    final displayText = WebIdParts.formatForDisplay(webId);

    return SolidServerInfo(
      serverUri: serverUri,
      displayText: displayText,
      tooltip: tooltip,
      isClickable: isClickable,
    );
  }

  /// Extracts the server URL from a WebID.

  static String _extractServerFromWebId(String webId) {
    final parts = WebIdParts.tryParse(webId);
    if (parts != null) {
      return parts.serverUri;
    }

    // Legacy fallback for malformed input: split on `/` and reconstruct the
    // origin manually so the caller still receives something URL-like.

    final chunks = webId.split('/');
    if (chunks.length >= 3) {
      return '${chunks[0]}//${chunks[2]}';
    }
    return webId;
  }

  /// Gets the effective display text, with automatic formatting if not
  /// provided.

  String get effectiveDisplayText {
    if (displayText != null) return displayText!;

    // Auto-format serverUri if it looks like a WebID.

    return WebIdParts.formatForDisplay(serverUri);
  }

  /// Gets the tooltip for server info.

  String get tooltipText {
    if (tooltip != null) return tooltip!;

    if (isClickable) {
      return '''

      **Pod**

      $serverUri - this is your selected Solid Server. You can tap here to open
      the server in your browser.  The Solid Server hosts your Data Vault and
      manages your personal online datastore (Pod) where your app data is stored
      securely and often encrypted (depending on your app).

      ''';
    } else {
      return '''

      **Pod**

      $serverUri - this is your selected Solid Server. The Solid Server hosts
      your Data Vault and manages your personal online datastore (Pod) where
      your app data is stored securely and often encrypted (depending on your
      app).

      ''';
    }
  }
}

/// Configuration for login status in the status bar.

class SolidLoginStatus {
  /// The current WebID (null if not logged in).

  final String? webId;

  /// Callback when login/logout is tapped.

  final VoidCallback? onTap;

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
    this.onTap,
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

    return '''

    **Login Status**

    You are currently logged in to your Pod on your Solid
    Server and so your data is privately accessible from your Pod.  Tap here to
    log out from the Solid Server $webId.

    ''';
  }

  /// Gets the logged-out tooltip.

  String get loggedOutTooltipContent {
    if (loggedOutTooltip != null) return loggedOutTooltip!;

    return '''

    **Login Status**

    You are currently **not** logged in.  To read and write
    your private data from your Pod on your Solid Server you need to be logged
    in. Tap here to log in.

    ''';
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
      return keySavedText ?? 'Security Key Cached Locally';
    } else {
      return keyNotSavedText ?? 'Security Key Not Cached';
    }
  }

  /// Gets the tooltip for the security key status.

  String get tooltipText {
    if (tooltip != null) return tooltip!;

    return '''

**Security Key Manager**

Tap here to manage your security key settings, view your current security key
status, save a new security key, or remove an existing security key. Your
security key is essential for encrypting and protecting your data.

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

  /// Custom login handler for when user is not logged in.

  final VoidCallback? onLogin;

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
    this.onLogin,
    this.securityKeyStatus,
    this.customItems = const [],
    this.showOnNarrowScreens = false,
    this.narrowScreenThreshold,
    this.backgroundColor,
    this.narrowLayoutHeight = 80.0,
    this.mediumLayoutHeight = 56.0,
    this.wideLayoutHeight = 40.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.itemSpacing = 16.0,
  });
}

/// Layout mode for the status bar based on screen width.

enum SolidStatusBarLayout { narrow, medium, wide }
