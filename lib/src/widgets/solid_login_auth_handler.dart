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

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart'
    show checkLoggedIn, solidAuthenticate, initialStructureTest;

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

    final wasAlreadyLoggedIn = await checkLoggedIn();

    if (!context.mounted) return false;

    // Only show the browser login instructions if user is not already logged
    // in.

    if (!wasAlreadyLoggedIn) {
      // Use a longer duration for this snackbar since it's replacing the login
      // animation.

      const loginDuration = Duration(seconds: 30);
      showSnackbar(
        'Please complete the login process in your browser...',
        duration: loginDuration,
      );

      // Show the animation after the snackbar.

      await Future.delayed(const Duration(milliseconds: 500));
      showBusyAnimation();
    }

    // Perform the actual authentication by contacting the server.

    if (!context.mounted) return false;

    List<dynamic>? authResult;
    try {
      authResult = await solidAuthenticate(podServer, context);
    } catch (e) {
      // Authentication error - likely server unavailable or network issue
      debugPrint('SolidLoginAuthHandler: Authentication error: $e');

      if (!context.mounted) return false;

      // Close the animation dialog
      if (!wasAlreadyLoggedIn) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show error dialog with server availability check
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Connection Failed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Unable to connect to the Solid server.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Server: $podServer'),
              const SizedBox(height: 12),
              const Text('Possible causes:'),
              const SizedBox(height: 4),
              const Text('• Server is temporarily unavailable'),
              const Text('• Network connection issue'),
              const Text('• Invalid server URL'),
              const SizedBox(height: 12),
              Text(
                'Error: ${e.toString()}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Navigate back to login screen
      if (!context.mounted) return false;
      await pushReplacement(context, originalLoginWidget);
      return false;
    }

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

      // Navigate to main app immediately after successful authentication
      // This provides instant user feedback and better UX
      if (!context.mounted) return false;

      await pushReplacement(context, childWidget);

      // Check initial structure in background (non-blocking)
      // If setup is needed, user can access it from the app later
      unawaited(
        _checkInitialStructureInBackground(
          defaultFolders,
          defaultFiles,
          originalLoginWidget,
          childWidget,
        ),
      );

      return true;
    } else {
      // Authentication failed.

      if (!context.mounted) return false;

      // Close the animation dialog before navigating back to login.

      if (!wasAlreadyLoggedIn) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Navigate back to the login screen after authentication failed.

      await pushReplacement(context, originalLoginWidget);

      return false;
    }
  }

  /// Checks initial POD structure in the background without blocking navigation.
  ///
  /// This allows the user to access the app immediately while structure
  /// verification happens asynchronously. If setup is needed, it can be
  /// triggered later from within the app.
  static Future<void> _checkInitialStructureInBackground(
    List<String> defaultFolders,
    Map<dynamic, dynamic> defaultFiles,
    dynamic originalLoginWidget,
    Widget childWidget,
  ) async {
    try {
      debugPrint(
          'SolidLoginAuthHandler: Checking initial structure in background...');

      final resCheckList = await initialStructureTest(
        defaultFolders,
        defaultFiles,
      );

      final allExists = resCheckList.first as bool;

      if (allExists) {
        debugPrint(
            'SolidLoginAuthHandler: Initial structure verified successfully');
      } else {
        debugPrint(
            'SolidLoginAuthHandler: Initial structure incomplete - user may need to run setup');
        // In the future, we could show a notification or prompt here
        // For now, we just log it and let the user discover setup options in the app
      }
    } catch (e) {
      debugPrint(
          'SolidLoginAuthHandler: Background structure check failed: $e');
      // Non-critical error - user can still use the app
    }
  }
}
