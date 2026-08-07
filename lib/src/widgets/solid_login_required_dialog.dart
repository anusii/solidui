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

import 'package:solidui/src/handlers/solid_auth_handler.dart';

/// A reusable `Login Required` confirmation dialogue.
///
/// Some Solid apps need to interrupt an action when the
/// user turns out not to be logged in. [SolidLoginRequiredDialog] provides a
/// single, consistently themed prompt that offers the user a choice between
/// cancelling the action or going to the app's Solid login page.
///
/// Two entry points are provided:
///
/// * [show] — render the dialogue and return the user's choice without
///   running the login flow. Useful when the caller needs full control
///   over what happens next.
/// * [showAndHandle] — render the dialogue and, when the user accepts,
///   navigate to the app's Solid login page via [SolidAuthHandler]. This
///   reproduces the same login experience the app uses on launch, so the
///   user lands on a familiar screen rather than a WebID input pop-up.
///
/// The look-and-feel intentionally matches the existing security key
/// cache `Login Required` dialogue, so users see a familiar prompt
/// across the entire Solid app suite.

class SolidLoginRequiredDialog {
  /// Default dialogue title.

  static const String defaultTitle = 'Login Required';

  /// Default body text shown when no message is supplied. The wording
  /// is intentionally generic so it remains accurate regardless of the
  /// action that triggered the prompt.

  static const String defaultMessage =
      'Please log in to your POD first to continue.';

  /// Standard message used by the security key cache flow. Exposed as
  /// a constant so the status bar, nav drawer and security key manager
  /// can share identical wording without duplicating the string.

  static const String securityKeyMessage =
      'Please log in to your POD first before caching the security key.';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  /// Renders the dialogue and, when the user accepts, navigates to the
  /// app's Solid login page via [SolidAuthHandler.handleLogin].
  ///
  /// This is the right entry point for the common case where the user
  /// should re-enter the standard login flow (the same one used on app
  /// start-up) rather than being shown a one-off WebID input pop-up.
  ///
  /// Set [popRouteBeforeLogin] to `true` when the caller is itself a
  /// modal route — for example the security key manager dialogue —
  /// that must be dismissed before the login page is pushed onto the
  /// navigator. The dismissal happens after the user has confirmed
  /// their choice, so cancelling the prompt leaves the calling modal
  /// untouched.
  ///
  /// Returns `true` when the user chose to log in (and navigation to
  /// the login page was initiated), or `false` otherwise — including
  /// the case where the user cancelled the dialogue.

  static Future<bool> showAndHandle(
    BuildContext context, {
    String title = defaultTitle,
    String message = defaultMessage,
    String cancelLabel = 'Cancel',
    String loginLabel = 'Log In',
    bool popRouteBeforeLogin = false,
  }) async {
    final shouldLogin = await show(
      context,
      title: title,
      message: message,
      cancelLabel: cancelLabel,
      loginLabel: loginLabel,
    );
    if (!shouldLogin || !context.mounted) return false;

    // Dismiss the calling modal (e.g. the security key manager) so the
    // login page becomes the topmost route rather than sitting beneath
    // a stale dialog.

    if (popRouteBeforeLogin) {
      Navigator.of(context).pop();
      if (!context.mounted) return false;
    }

    await SolidAuthHandler.instance.handleLogin(context);
    return true;
  }
}
