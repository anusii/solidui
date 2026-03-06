/// Authentication handler for Solid login.
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

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart'
    show
        initialStructureTest,
        isUserLoggedIn,
        isPodStructureInitialised,
        markPodStructureInitialised,
        solidAuthenticate;

import 'package:solidui/src/screens/initial_setup_screen.dart';
import 'package:solidui/src/widgets/solid_animation_dialog.dart';
import 'package:solidui/src/widgets/solid_login_helper.dart';

/// A handler class for Solid Pod authentication logic.

class SolidLoginAuthHandler {
  /// Handles the login process including authentication and navigation.
  ///
  /// Returns true if login was successful, false otherwise.

  static Future<bool> handleLogin({
    required BuildContext context,
    required String podServer,
    required List<String> defaultFolders,
    required Map<dynamic, dynamic> defaultFiles,
    required dynamic originalLoginWidget,
    required Widget childWidget,
    required bool isDialogCanceled,
    required VoidCallback updateDialogCanceledState,
    required Function(String message, {Duration? duration, bool showAction})
        showSnackbar,
  }) async {
    // Method to show busy animation requiring BuildContext.

    void showBusyAnimation() => showAnimationDialog(
          context,
          7,
          'Logging in...',
          false,
          updateDialogCanceledState,
        );

    if (isDialogCanceled) return false;

    // Check if user is already logged in before attempting authentication.

    final wasAlreadyLoggedIn = await isUserLoggedIn();

    if (!context.mounted) return false;

    // Show the animation immediately. Delay the browser login prompt so it only
    // appears after the server responds. If authentication fails quickly,
    // cancel the timer to avoid showing a misleading browser instruction.

    if (!wasAlreadyLoggedIn) {
      showBusyAnimation();
    }

    Timer? browserMessageTimer;
    if (!wasAlreadyLoggedIn) {
      browserMessageTimer = Timer(const Duration(milliseconds: 200), () {
        if (context.mounted) {
          showSnackbar(
            'Please complete the login process in your browser...',
            duration: const Duration(seconds: 5),
          );
        }
      });
    }

    // Perform the actual authentication by contacting the server.
    // Pass the already-computed login status so solidAuthenticate() does NOT
    // repeat the same isUserLoggedIn() check (secure storage read + token
    // expiry check) that we just performed above.

    if (!context.mounted) {
      browserMessageTimer?.cancel();

      return false;
    }

    List<dynamic>? authResult;
    try {
      authResult = await solidAuthenticate(
        podServer,
        context,
        wasAlreadyLoggedIn: wasAlreadyLoggedIn,
      );
    } on Object catch (e) {
      // Authentication failed due to a network or server error (e.g. DNS
      // lookup failure, socket exception, HTTP 502, or any other
      // connectivity issue).

      browserMessageTimer?.cancel();
      debugPrint('solidAuthenticate() exception: $e');

      if (!context.mounted) return false;

      // Dismiss any active animation dialog or snackbar before showing the
      // error message.

      if (!wasAlreadyLoggedIn) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      showSnackbar(
        'Unable to authenticate with $podServer. '
        'The server may be inaccessible or down.',
        duration: const Duration(seconds: 5),
      );

      await pushReplacement(context, originalLoginWidget);

      return false;
    }

    browserMessageTimer?.cancel();

    // If authentication succeeded and the user was already logged in,
    // it means they are using a cached session.

    final isCachedSession =
        wasAlreadyLoggedIn && authResult != null && authResult.isNotEmpty;

    // Check that the authentication succeeded.

    if (authResult != null && authResult.isNotEmpty) {
      if (!context.mounted) return false;

      // Close the animation dialog before proceeding.

      if (!wasAlreadyLoggedIn) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Dismiss the login process snackbar.

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // If using a cached session, show snackbar informing about it.

      if (isCachedSession) {
        showSnackbar(
          'Logged in with your previously saved session.',
          duration: const Duration(seconds: 5),
          showAction: false,
        );

        // Short delay to allow snackbar to be visible.

        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Returning users whose POD structure has already been verified can
      // proceed directly.

      final alreadyInitialised = await isPodStructureInitialised();

      if (alreadyInitialised) {
        if (!context.mounted) return false;
        await pushReplacement(context, childWidget);
      } else {
        // First run or structure not yet verified — perform the check.

        final resCheckList = await initialStructureTest(
          defaultFolders,
          defaultFiles,
        );
        final allExists = resCheckList.first as bool;

        if (!context.mounted) return false;

        if (!allExists) {
          await pushReplacement(
            context,
            InitialSetupScreen(
              resCheckList: resCheckList,
              originalLogin: originalLoginWidget,
              child: childWidget,
            ),
          );
        } else {
          await markPodStructureInitialised();
          if (!context.mounted) return false;
          await pushReplacement(context, childWidget);
        }
      }

      return true;
    } else {
      // Authentication failed. solidAuthenticate() catches all exceptions
      // internally and returns null, so server errors (e.g. HTTP 502, DNS
      // lookup failure) surface here rather than in the catch block above.

      if (!context.mounted) return false;

      // Close the animation dialog before navigating back to login.

      if (!wasAlreadyLoggedIn) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      showSnackbar(
        'Unable to authenticate with $podServer. '
        'The server may be inaccessible or down.',
        duration: const Duration(seconds: 5),
      );

      // Navigate back to the login screen after authentication failed.

      await pushReplacement(context, originalLoginWidget);

      return false;
    }
  }
}
