/// Generic `Login Required` dialogue.
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

import 'package:solidui/src/utils/solid_pod_helpers.dart' show loginIfRequired;

/// A reusable `Login Required` confirmation dialogue.
///
/// Apps frequently need to interrupt an action (e.g. saving a note,
/// caching a security key, fetching a private resource) when the user
/// turns out not to be logged in. Instead of each app rolling its own
/// modal, [SolidLoginRequiredDialog] provides a consistent, themed
/// prompt that offers the user a choice between cancelling the action
/// or starting the login flow.
///
/// Two entry points are provided:
///
/// * [show] — render the dialogue and return the user's choice without
///   running the login flow. Useful when the caller wants full control
///   over what happens next (for instance, to push a different login
///   screen).
/// * [showAndHandle] — render the dialogue and, when the user accepts,
///   invoke [loginIfRequired] so the login sub-flow is layered on top
///   of the calling screen. This keeps the original screen alive in
///   the navigator stack, allowing the caller's in-memory state (such
///   as an in-progress form) to survive the login round trip.
///
/// The look-and-feel matches the existing security key cache
/// [`Login Required`] dialogue, so users see a familiar prompt across
/// the entire Solid app suite.

class SolidLoginRequiredDialog {
  /// Default dialogue title.

  static const String defaultTitle = 'Login Required';

  /// Default body text shown when no message is supplied. The wording
  /// is intentionally generic so it remains accurate regardless of the
  /// action that triggered the prompt.

  static const String defaultMessage =
      'Please log in to your POD first to continue.';

  /// Renders the dialogue and returns whether the user chose to log in.
  ///
  /// The dialogue is non-dismissible (the user must tap one of the
  /// buttons) so the caller can rely on a deterministic outcome.
  ///
  /// Returns `true` when the user taps `Log In`, and `false` for the
  /// `Cancel` button (or any other dismissal path).

  static Future<bool> show(
    BuildContext context, {
    String title = defaultTitle,
    String message = defaultMessage,
    String cancelLabel = 'Cancel',
    String loginLabel = 'Log In',
  }) async {
    final theme = Theme.of(context);

    final shouldLogin = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              cancelLabel,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(loginLabel, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );

    return shouldLogin ?? false;
  }

  /// Renders the dialogue and, when the user accepts, runs the
  /// state-preserving login sub-flow via [loginIfRequired].
  ///
  /// Because [loginIfRequired] pushes the login screen on top of the
  /// current route (rather than replacing it), the widget that invoked
  /// this dialogue stays alive in the navigator stack. Any state held
  /// by that widget — for example, the in-progress contents of a note
  /// editor — therefore survives the login round trip. Callers can
  /// inspect the returned boolean to decide whether to retry the
  /// original action automatically.
  ///
  /// Returns `true` when the user is logged in by the time the flow
  /// completes, and `false` otherwise (including the case where the
  /// user cancelled the dialogue).

  static Future<bool> showAndHandle(
    BuildContext context, {
    String title = defaultTitle,
    String message = defaultMessage,
    String cancelLabel = 'Cancel',
    String loginLabel = 'Log In',
  }) async {
    final shouldLogin = await show(
      context,
      title: title,
      message: message,
      cancelLabel: cancelLabel,
      loginLabel: loginLabel,
    );
    if (!shouldLogin || !context.mounted) return false;

    return loginIfRequired(context);
  }
}
