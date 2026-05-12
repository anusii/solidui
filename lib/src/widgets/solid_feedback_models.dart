/// Models for the Feedback feature in Solid applications.
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

/// Configuration for the Feedback entry shown inside the About dialogue.
///
/// This is intentionally a thin placeholder so applications can opt in to
/// a feedback flow without solidui imposing a particular implementation.
/// Supplying a [SolidFeedbackConfig] with [enabled] set to `true` and an
/// [onPressed] callback (or a [url]) lights up the Feedback button in the
/// About dialogue. When no configuration is provided, solidui still
/// renders the button — but greyed out — so the visual layout of the
/// About dialogue is consistent and a clear hook is left for future work.

class SolidFeedbackConfig {
  /// Whether the Feedback button is enabled. When `false`, the button is
  /// rendered greyed out as a placeholder.

  final bool enabled;

  /// Optional custom icon. Defaults to [Icons.feedback_outlined].

  final IconData? icon;

  /// Optional label override. Defaults to `Feedback`.

  final String? label;

  /// Optional tooltip shown on hover.

  final String? tooltip;

  /// Optional URL that is opened when the user taps the button. When
  /// supplied (and [onPressed] is null), solidui launches the URL using
  /// the default URL launcher.

  final String? url;

  /// Optional callback invoked when the user taps the button. When
  /// supplied, this takes precedence over [url] so applications can plug
  /// in their own feedback flow (for example, an in-app form or an
  /// external bug-tracker integration).

  final VoidCallback? onPressed;

  const SolidFeedbackConfig({
    this.enabled = true,
    this.icon,
    this.label,
    this.tooltip,
    this.url,
    this.onPressed,
  });

  /// Returns the icon used for the Feedback button.

  IconData get effectiveIcon => icon ?? Icons.feedback_outlined;

  /// Returns the label used for the Feedback button.

  String get effectiveLabel => label ?? 'Feedback';

  /// Returns the tooltip text for the Feedback button.

  String get effectiveTooltip {
    if (tooltip != null) return tooltip!;
    if (!enabled) {
      return '''

      **Feedback**

      Feedback is not yet wired up for this application.
      A future release will let you share feedback from here.

      ''';
    }
    return '''

    **Feedback**

    Tap here to send feedback to the application authors.

    ''';
  }

  /// Whether the button should be interactive in the UI.

  bool get isInteractive => enabled && (onPressed != null || url != null);
}
