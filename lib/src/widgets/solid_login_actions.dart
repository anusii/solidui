/// Action callbacks used by the SolidLogin widget.
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
/// Authors: Graham Williams, Anushka Vidanage, Ashley Tang, Dawei Chen, Tony
/// Chen

library;

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart'
    show
        clearPodStructureInitialised,
        deleteLogIn,
        getWebId,
        initialStructureTest,
        isUserLoggedIn,
        silentLogout;

import 'package:solidui/src/constants/solid_config.dart';
import 'package:solidui/src/utils/solid_pod_helpers.dart'
    show getKeyFromUserIfRequired;
import 'package:solidui/src/widgets/solid_animation_dialog.dart';
import 'package:solidui/src/widgets/solid_login_auth_handler.dart';
import 'package:solidui/src/widgets/solid_login_helper.dart';

/// Signature for the snackbar helper used by login actions.

typedef LoginSnackbar = void Function(
  String message, {
  Duration? duration,
  bool showAction,
});

/// Static action helpers for the SolidLogin widget.
///
/// Extracted from [SolidLogin] to keep the widget focused on composition.
/// The methods here implement the login / continue / try-another-account
/// flows and are called from the [SolidLogin] build method.

class SolidLoginActions {
  /// Performs the login flow.
  ///
  /// When a cached session already exists the server origin is compared with
  /// the server currently entered in the text field:
  ///   - Same server  -> reuse the cached session.
  ///   - Different    -> clear stale credentials and start a fresh browser
  ///                     login against the newly specified server.
  ///   - No cache     -> start the browser login flow as normal.

  static Future<void> performLogin({
    required BuildContext context,
    required TextEditingController webIdController,
    required List<String> defaultFolders,
    required Map<dynamic, dynamic> defaultFiles,
    required dynamic originalLoginWidget,
    required Widget childWidget,
    required ValueGetter<bool> isDialogCanceled,
    required VoidCallback updateDialogCanceledState,
    required LoginSnackbar showSnackbar,
    required bool staySignedIn,
  }) async {
    // When the user has opted out of staying signed in, discard any existing
    // cached session immediately so browser authentication is always
    // required.

    if (!staySignedIn) {
      await deleteLogIn();
    }

    final podServer = webIdController.text.trim().isNotEmpty
        ? webIdController.text.trim()
        : SolidConfig.defaultServerUrl;

    final alreadyLoggedIn = await isUserLoggedIn();

    if (alreadyLoggedIn) {
      final cachedWebId = await getWebId();
      if (cachedWebId != null && cachedWebId.isNotEmpty) {
        try {
          final cachedOrigin = Uri.parse(cachedWebId).origin;
          final requestedOrigin = Uri.parse(podServer).origin;

          if (cachedOrigin != requestedOrigin) {
            await deleteLogIn();
          }
        } on FormatException {
          // If either URL cannot be parsed, fall through and let handleLogin
          // deal with the server as-is.
        }
      }
    }

    if (!context.mounted) return;

    await SolidLoginAuthHandler.handleLogin(
      context: context,
      podServer: podServer,
      defaultFolders: defaultFolders,
      defaultFiles: defaultFiles,
      originalLoginWidget: originalLoginWidget,
      childWidget: childWidget,
      isDialogCanceled: isDialogCanceled,
      updateDialogCanceledState: updateDialogCanceledState,
      showSnackbar: showSnackbar,
      staySignedIn: staySignedIn,
    );
  }

  /// Performs the continue flow.
  ///
  /// When the user taps Continue with an existing cached session, verify the
  /// remote POD directory structure before proceeding. If the remote
  /// directories are missing, clear stale credentials and ask the user to
  /// re-login so the setup wizard can re-initialise the POD.

  static Future<void> performContinue({
    required BuildContext context,
    required Widget childWidget,
    required List<String> defaultFolders,
    required Map<dynamic, dynamic> defaultFiles,
    required VoidCallback updateDialogCanceledState,
    required LoginSnackbar showSnackbar,
    required bool staySignedIn,
  }) async {
    // When the user has opted out of staying signed in, discard any existing
    // cached session immediately so the user proceeds in a logged-out state.

    if (!staySignedIn) {
      await deleteLogIn();
    }

    final isLoggedIn = await isUserLoggedIn();

    if (isLoggedIn && defaultFolders.isNotEmpty) {
      if (!context.mounted) return;

      showAnimationDialog(
        context,
        7,
        '',
        // 20260410 gjw Replaced the original 'Verifying POD structure...'
        // message with nothing. It suddenly started appearing when entering
        // the app via CONTINUE while already logged in. Users probably do not
        // need to know about this.
        false,
        updateDialogCanceledState,
      );

      try {
        final resCheckList = await initialStructureTest(
          defaultFolders,
          defaultFiles,
        );
        final allExists = resCheckList.first as bool;

        if (!context.mounted) return;

        Navigator.of(context, rootNavigator: true).pop();

        if (!allExists) {
          await clearPodStructureInitialised();
          await silentLogout();

          if (!context.mounted) return;

          showSnackbar(
            'Your POD directory structure is incomplete or has been '
            'removed. Please log in again to re-initialise your POD.',
            duration: const Duration(seconds: 5),
          );

          return;
        }
      } on Object catch (e) {
        debugPrint('Continue: POD structure check failed: $e');

        if (!context.mounted) return;

        Navigator.of(context, rootNavigator: true).pop();

        showSnackbar(
          'Unable to verify POD structure. '
          'The server may be inaccessible.',
          duration: const Duration(seconds: 5),
        );

        return;
      }
    }

    if (!context.mounted) return;

    // Ensure the security key has been fetched once logged in.

    if (isLoggedIn) {
      await getKeyFromUserIfRequired(context, childWidget);
      if (!context.mounted) return;
    }

    await pushReplacement(context, childWidget);
  }

  /// Signs out silently, clears the POD structure flag, then starts a fresh
  /// login flow so the user can sign in with a different WebID.

  static Future<void> performTryAnotherAccount({
    required BuildContext context,
    required Future<void> Function() performLoginCallback,
  }) async {
    await silentLogout();
    await clearPodStructureInitialised();
    if (!context.mounted) return;

    await performLoginCallback();
  }
}
