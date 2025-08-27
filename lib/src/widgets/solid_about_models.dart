/// Models for About dialogue functionality in Solid applications.
///
// Time-stamp: <Thursday 2025-08-21 15:20:34 +1000 Tony Chen>
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
  });

  /// Returns the icon to display for the About button.

  IconData get effectiveIcon => icon ?? Icons.info_outline;

  /// Returns the tooltip text for the About button.

  String get effectiveTooltip {
    if (tooltip != null) return tooltip!;

    return '''
**About ${applicationName ?? 'Application'}**

ℹ️ View application information

Tap to view details about this application including version, copyright, and
licensing information.
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
