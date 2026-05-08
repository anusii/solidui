/// Models for the Invite Others feature in Solid applications.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
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

/// Configuration for the Invite Others feature.

class SolidInviteOthersConfig {
  /// Whether the Invite Others button is enabled.

  final bool enabled;

  /// Custom icon for the Invite Others button. Defaults to [Icons.share].

  final IconData? icon;

  /// Display name of the application used in the default invitation
  /// message. If null, the package name is read from `PackageInfo`.

  final String? applicationName;

  /// Public URL where the application is hosted (for example, a
  /// togaware deployment, the App Store, or Google Play). This is the
  /// URL that is shared with the recipient.

  final String? appUrl;

  /// A short description of what the application does. This is used
  /// to build the second sentence of the default invitation when no
  /// custom [messageTemplate] is provided.

  final String? appDescription;

  /// A custom invitation message template. The following placeholders
  /// are substituted before the message is shared:
  ///
  /// - `{appName}` — the application name (see [applicationName]).
  /// - `{appUrl}` — the public app URL (see [appUrl]).
  /// - `{appDescription}` — the short description (see [appDescription]).

  final String? messageTemplate;

  /// Optional subject line used by share targets that distinguish a
  /// subject from the body (for example, email clients).

  final String? subject;

  /// Tooltip shown over the AppBar icon button.

  final String? tooltip;

  /// Whether to show the button on narrow screens.

  final bool showOnNarrowScreen;

  /// Whether to show the button on very narrow screens.

  final bool showOnVeryNarrowScreen;

  /// Initial ordering priority. Lower numbers appear earlier in the
  /// AppBar action list.

  final int priority;

  /// Optional override for the on-press behaviour. If supplied, the
  /// callback is invoked instead of the default invite dialog.

  final VoidCallback? onPressed;

  const SolidInviteOthersConfig({
    this.enabled = true,
    this.icon,
    this.applicationName,
    this.appUrl,
    this.appDescription,
    this.messageTemplate,
    this.subject,
    this.tooltip,
    this.showOnNarrowScreen = true,
    this.showOnVeryNarrowScreen = true,
    this.priority = 600,
    this.onPressed,
  });

  /// Default invitation template used when [messageTemplate] is null.

  static const String defaultMessageTemplate = '''
You might like to try the {appName} app, available online here:
{appUrl}

Signing into {appName} will set up your data vault so that you can {appDescription}.''';

  /// Returns the icon to display for the Invite Others button.

  IconData get effectiveIcon => icon ?? Icons.share;

  /// Returns the tooltip text for the Invite Others button.

  String get effectiveTooltip {
    if (tooltip != null) return tooltip!;

    return '''

    **Invite Others**

    Tap here to invite someone else to try ${applicationName ?? 'this app'}.
    You can copy the invitation link to the clipboard, or share it
    using any messaging app installed on your device.

    ''';
  }

  /// Returns whether to show the button based on screen width.

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

  /// Builds the invitation message for the given application name and
  /// URL by substituting placeholders into the [messageTemplate] (or
  /// the [defaultMessageTemplate] if one is not supplied).
  ///
  /// Both [resolvedAppName] and [resolvedAppUrl] should be the
  /// effective values discovered at runtime — typically the
  /// application's name from `PackageInfo` and the configured
  /// [appUrl] respectively. If [appUrl] is not configured the URL
  /// placeholder is replaced by an empty string so the user can
  /// still share a partial message.

  String buildMessage({
    required String resolvedAppName,
    required String resolvedAppUrl,
    String? resolvedAppDescription,
  }) {
    final template = messageTemplate ?? defaultMessageTemplate;
    final description = resolvedAppDescription ??
        appDescription ??
        'see and share data with you using your own data vault';
    return template
        .replaceAll('{appName}', resolvedAppName)
        .replaceAll('{appUrl}', resolvedAppUrl)
        .replaceAll('{appDescription}', description);
  }
}
