/// Models for About dialogue functionality in Solid applications.
///
// Time-stamp: <Friday 2025-09-19 10:37:54 +1000 Graham Williams>
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

/// Configuration for About dialog functionality in the Solid scaffold.

class SolidAboutConfig {
  /// Whether the About button is enabled.

  final bool enabled;

  /// Custom icon for the About button (defaults to info icon).

  final IconData? icon;

  /// Application name displayed in the About dialogue.

  final String? applicationName;

  /// Application version displayed in the About dialogue.

  final String? applicationVersion;

  /// Application icon displayed in the About dialogue.

  final Widget? applicationIcon;

  /// Application legal notice (usually copyright information).

  final String? applicationLegalese;

  /// Main text content for the About dialogue (supports Markdown).
  /// If provided, this will be rendered as MarkdownBody with word wrapping.

  final String? text;

  /// Custom About dialogue content. If provided, this replaces the default
  /// dialogue.

  final Widget? customContent;

  /// Additional children widgets to be shown in the About dialogue.
  /// Note: If 'text' is provided, it takes precedence over 'children'.

  final List<Widget>? children;

  /// Whether to show the About button on narrow screens.

  final bool showOnNarrowScreen;

  /// Whether to show the About button on very narrow screens.

  final bool showOnVeryNarrowScreen;

  /// Priority for ordering in AppBar actions (higher numbers appear later).

  final int priority;

  /// Tooltip text for the About button.

  final String? tooltip;

  /// Callback when About button is pressed. If null, shows default About
  /// dialogue.

  final VoidCallback? onPressed;

  /// Whether to show Layout Preferences button in the About dialogue.
  /// Defaults to true, allowing users to configure AppBar button layout.

  final bool showLayoutPreferences;

  const SolidAboutConfig({
    this.enabled = true,
    this.icon,
    this.applicationName,
    this.applicationVersion,
    this.applicationIcon,
    this.applicationLegalese,
    this.text,
    this.customContent,
    this.children,
    this.showOnNarrowScreen = true,
    this.showOnVeryNarrowScreen = true,
    this.priority = 999,
    this.tooltip,
    this.onPressed,
    this.showLayoutPreferences = true,
  });

  /// Returns the icon to display for the About button.

  IconData get effectiveIcon => icon ?? Icons.info_outline;

  /// Returns the tooltip text for the About button.

  String get effectiveTooltip {
    if (tooltip != null) return tooltip!;

    return '''

    **About ${applicationName ?? 'Application'}**

    Tap here to view details about this application including version,
    copyright, and licensing information.

    ''';
  }

  /// Returns whether to show the About button based on screen width.

  bool shouldShow(
    double screenWidth,
    double narrowThreshold,
    double veryNarrowThreshold,
  ) {
    if (screenWidth < veryNarrowThreshold && !showOnVeryNarrowScreen) {
      return false;
    }
    if (screenWidth < narrowThreshold && !showOnNarrowScreen) {
      return false;
    }
    return enabled;
  }
}
