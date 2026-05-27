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

import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart'
    show
        SolidAuthCancelledException,
        clearPodStructureInitialised,
        deleteLogIn,
        getWebId,
        initialStructureTest,
        isUserLoggedIn,
        markPodStructureInitialised,
        solidAuthenticate;

import 'package:solidui/src/constants/initial_setup.dart'
    show initialStructureSnackbarMsg, initialUpdateSnackbarMsg;
import 'package:solidui/src/screens/initial_setup_screen.dart';
import 'package:solidui/src/services/solid_login_status_notifier.dart';
import 'package:solidui/src/utils/solid_pod_helpers.dart'
    show getKeyFromUserIfRequired, isPodUpdateMode;
import 'package:solidui/src/widgets/solid_animation_dialog.dart';
import 'package:solidui/src/widgets/solid_login_helper.dart';

/// A handler class for Solid Pod authentication logic.

class SolidLoginAuthHandler {
  /// SharedPreferences key for scheduling session clearance on next startup.

  static const clearSessionKey = 'solidui_clear_session_on_startup';

  /// SharedPreferences key for persisting the "Stay signed in" preference.

  static const staySignedInKey = 'solidui_stay_signed_in';

  /// SharedPreferences key for persisting the last successfully used WebID
  /// (or server URL). This is used to prefill the re-login dialog after the
  /// user has been logged out — accidentally or otherwise — so they do not
  /// have to retype it.

  static const lastWebIdKey = 'solidui_last_webid';

  /// Returns the last WebID/server URL that the user successfully
  /// authenticated with, or null when no value has been persisted yet.

  static Future<String?> getLastWebId() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(lastWebIdKey);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  /// Persists [value] as the last WebID/server URL. Empty or whitespace-only
  /// values are ignored so we never overwrite a good entry with a blank one.

  static Future<void> setLastWebId(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastWebIdKey, trimmed);
  }

  /// Clears the cached login session if a previous session opted out of
  /// "Stay signed in". Call this early during login page initialisation.

  static Future<void> clearSessionIfRequired() async {
    final prefs = await SharedPreferences.getInstance();
    final shouldClear = prefs.getBool(clearSessionKey) ?? false;
    if (shouldClear) {
      await deleteLogIn();
      solidLoginStatusNotifier.markLoggedOut();
      await prefs.remove(clearSessionKey);
    }
  }

  /// Returns the persisted "Stay signed in" preference, defaulting to true.

  static Future<bool> getStaySignedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(staySignedInKey) ?? true;
  }

  /// Persists the "Stay signed in" preference.

  static Future<void> setStaySignedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(staySignedInKey, value);
  }

  /// Returns the capitalised current app name from the platform package info,
  /// or the generic fallback when unavailable. Used to produce user-facing
  /// messages such as the setup snackbar. Also replaces a trailing pod with
  /// Pod.

  static Future<String> _currentAppName() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final name = packageInfo.appName;
      if (name.isEmpty) return 'the App';
      return name[0].toUpperCase() +
          name.substring(1).replaceAll(RegExp(r'pod$'), 'Pod');
    } on Object {
      return 'the App';
    }
  }

  /// Displays the setup-wizard or update-wizard snackbar depending on the
  /// state of the POD represented by [resCheckList]. Kept as a helper so
  /// every code path that navigates to [InitialSetupScreen] shows a
  /// snackbar with the correct wording.

  static Future<bool> _announceSetupWizard({
    required BuildContext context,
    required List<dynamic> resCheckList,
    required Function(String message, {Duration? duration, bool showAction})
        showSnackbar,
  }) async {
    final isUpdate = await isPodUpdateMode(resCheckList);
    final appName = await _currentAppName();
    if (!context.mounted) return isUpdate;

    showSnackbar(
      isUpdate
          ? initialUpdateSnackbarMsg(appName)
          : initialStructureSnackbarMsg(appName),
      duration: const Duration(seconds: 5),
    );
    return isUpdate;
  }

  /// Notifies the user that their POD is not initialised, verifies the remote
  /// directory structure, and navigates to the appropriate screen (setup wizard
  /// or child widget).

  static Future<bool> _proceedWithPodSetup({
    required BuildContext context,
    required List<String> defaultFolders,
    required Map<dynamic, dynamic> defaultFiles,
    required dynamic originalLoginWidget,
    required Widget childWidget,
    required Function(String message, {Duration? duration, bool showAction})
        showSnackbar,
    bool staySignedIn = true,
  }) async {
    final resCheckList = await initialStructureTest(
      defaultFolders,
      defaultFiles,
    );
    final allExists = resCheckList.first as bool;

    if (!context.mounted) return false;

    if (!allExists) {
      // Announce setup vs update before navigating, so the user sees the
      // correct wording in the bottom snackbar as the wizard opens.

      final isUpdate = await _announceSetupWizard(
        context: context,
        resCheckList: resCheckList,
        showSnackbar: showSnackbar,
      );

      if (!context.mounted) return false;

      await clearPodStructureInitialised();

      // Schedule session clearance for next startup when the user has
      // opted out of staying signed in. We must not call deleteLogIn()
      // here because InitialSetupScreen still needs valid auth data.

      if (!staySignedIn) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(clearSessionKey, true);
      }

      if (!context.mounted) return false;

      await pushReplacement(
        context,
        InitialSetupScreen(
          resCheckList: resCheckList,
          originalLogin: originalLoginWidget,
          isUpdate: isUpdate,
          child: childWidget,
        ),
      );
    } else {
      await markPodStructureInitialised();

      // Schedule session clearance for next startup when the user has
      // opted out of staying signed in. deleteLogIn() must come after
      // markPodStructureInitialised() which requires valid auth data.

      if (!staySignedIn) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(clearSessionKey, true);
      }

      if (!context.mounted) return false;
      await getKeyFromUserIfRequired(context, childWidget);
      if (!context.mounted) return true;
      await pushReplacement(context, childWidget);
    }

    return true;
  }

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
    required ValueGetter<bool> isDialogCanceled,
    required VoidCallback updateDialogCanceledState,
    required Function(String message, {Duration? duration, bool showAction})
        showSnackbar,
    bool staySignedIn = true,
  }) async {
    // Method to show busy animation requiring BuildContext.

    void showBusyAnimation() => showAnimationDialog(
          context,
          7,
          'Logging in...',
          false,
          updateDialogCanceledState,
        );

    if (isDialogCanceled()) return false;

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

    if (!context.mounted) {
      browserMessageTimer?.cancel();

      return false;
    }

    List<dynamic>? authResult;
    try {
      authResult = await solidAuthenticate(podServer, context);
    } on SolidAuthCancelledException {
      browserMessageTimer?.cancel();

      if (!context.mounted) return false;

      if (!isDialogCanceled() && !wasAlreadyLoggedIn) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      return false;
    } on Object catch (e) {
      // Check whether auth data was persisted before the failure (i.e. POD
      // not initialised) vs a genuine server/network error.

      browserMessageTimer?.cancel();
      debugPrint('solidAuthenticate() exception: $e');

      // If the user already cancelled the login animation dialog while
      // solidAuthenticate() was in flight, abort the login flow without
      // touching the navigator.

      if (isDialogCanceled()) return false;

      final isNowLoggedIn = await isUserLoggedIn();

      if (!context.mounted) return false;
      if (isDialogCanceled()) return false;

      // Dismiss any active animation dialog or snackbar before showing the
      // error message.

      if (!wasAlreadyLoggedIn) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (isNowLoggedIn) {
        return _proceedWithPodSetup(
          context: context,
          defaultFolders: defaultFolders,
          defaultFiles: defaultFiles,
          originalLoginWidget: originalLoginWidget,
          childWidget: childWidget,
          showSnackbar: showSnackbar,
          staySignedIn: staySignedIn,
        );
      } else {
        showSnackbar(
          'Unable to authenticate with $podServer. '
          'The server may be inaccessible or down.',
          duration: const Duration(seconds: 5),
        );

        await pushReplacement(context, originalLoginWidget);

        return false;
      }
    }

    browserMessageTimer?.cancel();

    // If the user already cancelled the login animation dialog while
    // solidAuthenticate() was in flight, abort the login flow without
    // touching the navigator. Any auth data that was persisted server-side
    // (e.g. because the user clicked "Yes" in the browser confirm-WebID
    // page after pressing Cancel in the app) will be picked up on the
    // next login attempt via the cached-session path.

    if (isDialogCanceled()) return false;

    // If authentication succeeded and the user was already logged in,
    // it means they are using a cached session.

    final isCachedSession =
        wasAlreadyLoggedIn && authResult != null && authResult.isNotEmpty;

    // Check that the authentication succeeded.

    if (authResult != null && authResult.isNotEmpty) {
      // Persist the WebID/server URL so the re-login dialog can prefill it
      // next time. Prefer the canonical WebID returned by the server when
      // available; fall back to the user's input otherwise.

      final canonicalWebId = await getWebId();
      await setLastWebId(
        (canonicalWebId != null && canonicalWebId.isNotEmpty)
            ? canonicalWebId
            : podServer,
      );

      // Tell any listeners (e.g. the dynamic status bar) that the login
      // state has just changed so they can refresh themselves.

      await solidLoginStatusNotifier.refreshStatus();

      if (!context.mounted) return false;
      if (isDialogCanceled()) return false;

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

      // Always verify the remote POD directory structure regardless of the
      // local initialisation flag. The remote folders may have been deleted
      // independently (e.g. via the server admin UI), so relying solely on
      // the cached flag would let the user enter a broken environment.

      final resCheckList = await initialStructureTest(
        defaultFolders,
        defaultFiles,
      );
      final allExists = resCheckList.first as bool;

      if (!context.mounted) return false;

      if (!allExists) {
        // Remote structure is incomplete — clear the stale local flag and
        // launch the setup wizard so the user can re-initialise.

        // Announce setup vs update before navigating so the user sees the
        // correct wording in the bottom snackbar as the wizard opens.

        final isUpdate = await _announceSetupWizard(
          context: context,
          resCheckList: resCheckList,
          showSnackbar: showSnackbar,
        );

        if (!context.mounted) return false;

        await clearPodStructureInitialised();

        // Schedule session clearance for next startup when the user has
        // opted out of staying signed in. We must not call deleteLogIn()
        // here because InitialSetupScreen still needs valid auth data.

        if (!staySignedIn) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(clearSessionKey, true);
        }

        if (!context.mounted) return false;

        await pushReplacement(
          context,
          InitialSetupScreen(
            resCheckList: resCheckList,
            originalLogin: originalLoginWidget,
            isUpdate: isUpdate,
            child: childWidget,
          ),
        );
      } else {
        await markPodStructureInitialised();

        // Schedule session clearance for next startup when the user has
        // opted out of staying signed in. deleteLogIn() must come after
        // markPodStructureInitialised() which requires valid auth data.

        if (!staySignedIn) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(clearSessionKey, true);
        }

        if (!context.mounted) return false;
        await getKeyFromUserIfRequired(context, childWidget);
        if (!context.mounted) return true;
        await pushReplacement(context, childWidget);
      }

      return true;
    } else {
      // solidAuthenticate() returned null. This can happen when:
      //   (a) Auth succeeded but the subsequent profile fetch failed because
      //       the POD is not yet initialised.
      //   (b) The server is genuinely unreachable (HTTP 502, DNS failure, etc.)
      //   (c) The user cancelled the browser login.
      //
      // Distinguish (a) from (b)/(c) by checking whether auth data was
      // persisted before the failure.

      final isNowLoggedIn = await isUserLoggedIn();

      if (!context.mounted) return false;
      if (isDialogCanceled()) return false;

      if (!wasAlreadyLoggedIn) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (isNowLoggedIn) {
        return _proceedWithPodSetup(
          context: context,
          defaultFolders: defaultFolders,
          defaultFiles: defaultFiles,
          originalLoginWidget: originalLoginWidget,
          childWidget: childWidget,
          showSnackbar: showSnackbar,
          staySignedIn: staySignedIn,
        );
      } else {
        // Authentication truly failed – server may be down or the user
        // cancelled the browser login.

        showSnackbar(
          'Unable to authenticate with $podServer. '
          'The server may be inaccessible or down.',
          duration: const Duration(seconds: 5),
        );

        await pushReplacement(context, originalLoginWidget);

        return false;
      }
    }
  }
}
