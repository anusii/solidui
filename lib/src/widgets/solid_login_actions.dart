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
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'package:solidpod/solidpod.dart'
    show
        cancelSolidAuthenticate,
        clearPodStructureInitialised,
        deleteLogIn,
        getWebId,
        initialStructureTest,
        isUserLoggedIn,
        silentLogout;
import 'package:universal_io/io.dart' show Platform;

import 'package:solidui/src/constants/solid_config.dart';
import 'package:solidui/src/services/solid_login_status_notifier.dart';
import 'package:solidui/src/utils/network_diagnosis.dart'
    show connectionFailureMessage, diagnoseConnection;
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
  /// The name of the snap this is running inside, or null when it is not a
  /// snap.
  ///
  /// snapd sets SNAP_NAME in the environment of every snap it launches, so
  /// its presence is the test, and its value gives the real name to put in
  /// the command rather than a placeholder the user has to substitute.
  ///
  /// universal_io keeps this compiling for web, where the environment is
  /// empty and the answer is null.

  static String? get _snapName {
    final name = Platform.environment['SNAP_NAME'];

    return (name != null && name.isNotEmpty) ? name : null;
  }

  /// Whether [message] is snap confinement refusing the keyring, as opposed
  /// to any other secure-storage failure.
  ///
  /// Pure, and taking [snapName] rather than reading the environment, so the
  /// rule can be tested without actually being inside a snap.
  ///
  /// BOTH halves of the message matter. Being in a snap is not enough — a
  /// snap's keyring can be merely locked, which has a different remedy — and
  /// an AppArmor denial about something other than the secret service is not
  /// this either. Only a denial naming org.freedesktop.Secret.Service is
  /// fixed by connecting password-manager-service.

  @visibleForTesting
  static bool isSnapKeyringDenial(String message, String? snapName) =>
      snapName != null &&
      snapName.isNotEmpty &&
      message.contains('AppArmor') &&
      message.contains('org.freedesktop.Secret.Service');

  /// Show a dialog explaining that the system secure storage / keyring could
  /// not be accessed, and where possible how to fix it.
  ///
  /// Three cases, most specific first: a snap refused the keyring by policy
  /// and needs one `snap connect`; a Linux keyring that is merely locked; or
  /// anything else, where the raw error is shown so the user is not left
  /// wondering why login silently failed.
  ///
  /// Public so that [SolidLogin] can call it from the login paths.

  static Future<void> showSecureStorageError(
    BuildContext context,
    Object error,
  ) {
    final msg = error.toString();
    final isKeyringLocked = msg.contains('KeyringLocked');

    // 20260924 gjw A snap refused the keyring by policy, which is a wholly
    // different situation from a locked one and has a one-line fix.
    //
    // Under strict confinement the keyring is reachable only once the
    // password-manager-service interface is connected, and that interface is
    // NOT connected automatically — the Snap Store declines to auto-connect
    // it, because it exposes every secret in the session rather than just
    // this app's. So the user has to connect it by hand, once, and until
    // they do the raw error is a wall of D-Bus text that names AppArmor but
    // not the remedy.
    //
    // Recognised by the AppArmor denial naming the secret service, so a
    // genuinely locked keyring inside a snap still gets the keyring advice
    // below rather than this.

    final snap = _snapName;
    // The `snap != null` is repeated from inside the rule so the compiler
    // promotes `snap` to non-null for the content builder below.

    final isSnapDenial = snap != null && isSnapKeyringDenial(msg, snap);
    final connectCommand = 'sudo snap connect '
        '$snap:password-manager-service';

    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: Theme.of(ctx).colorScheme.error),
            const SizedBox(width: 8),
            const Expanded(child: Text('Cannot access secure storage')),
          ],
        ),
        content: SingleChildScrollView(
          child: isSnapDenial
              ? _snapDenialContent(ctx, snap, connectCommand)
              : Text(
                  isKeyringLocked
                      ? 'Your system keyring is locked, so saved login '
                          'credentials cannot be read.\n\n'
                          'On Linux, unlock the GNOME keyring and try again:\n\n'
                          '  • Install the keyring tools:\n'
                          '      sudo apt install gnome-keyring seahorse\n\n'
                          '  • Open Seahorse (Passwords and Keys), then\n'
                          '    File → New → Password Keyring, name it "Login",\n'
                          '    and set a blank password (or your login password).\n\n'
                          'After that the keyring unlocks automatically when you '
                          'log in, and the app can store and read your '
                          'credentials.'
                      : 'The app could not read or write the system secure '
                          'storage, so login cannot continue.\n\n'
                          'Details:\n$msg',
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// The body shown when a snap has been refused the keyring.
  ///
  /// The command is the whole point, so it is set apart in a monospaced box
  /// rather than buried in a paragraph, carries the snap's REAL name, and can
  /// be copied — it has to be retyped into a terminal, and
  /// "password-manager-service" is not a word anyone wants to type twice.

  static Widget _snapDenialContent(
    BuildContext ctx,
    String snap,
    String command,
  ) {
    final cs = Theme.of(ctx).colorScheme;
    const body = TextStyle(fontSize: 13, height: 1.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This app is installed as a snap, and snap confinement is '
          'blocking access to your keyring, where the login credentials '
          'are kept.\n\n'
          'Allow it once, from a terminal:',
          style: body,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  command,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copy the command',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: command));
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Command copied.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Then start $snap again.\n\n'
          'This is needed because the snap store does not grant keyring '
          'access automatically. Without a login you can still tap '
          'CONTINUE and use the app with your data kept on this device.',
          style: body,
        ),
      ],
    );
  }

  /// Reentrancy guard for [performTryAnotherAccount].

  static bool _tryAnotherAccountInProgress = false;

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
    required final String clientId,
    required final List<String> redirectUris,
    final List<String> postLogoutRedirectUris = const [],
  }) async {
    // When the user has opted out of staying signed in, discard any existing
    // cached session immediately so browser authentication is always
    // required.

    if (!staySignedIn) {
      await deleteLogIn();
      solidLoginStatusNotifier.markLoggedOut();
    }

    final podServer = webIdController.text.trim().isNotEmpty
        ? webIdController.text.trim()
        : SolidConfig.defaultServerUrl;

    // isUserLoggedIn() / getWebId() read cached credentials from the system
    // secure storage (libsecret/GNOME keyring on Linux). If the keyring is
    // locked these throw a PlatformException that, left unhandled, makes the
    // Login button silently do nothing. Catch it and tell the user.
    final bool alreadyLoggedIn;
    try {
      alreadyLoggedIn = await isUserLoggedIn();
    } catch (e) {
      if (context.mounted) {
        await showSecureStorageError(context, e);
      }
      return;
    }

    if (alreadyLoggedIn) {
      String? cachedWebId;
      try {
        cachedWebId = await getWebId();
      } catch (e) {
        if (context.mounted) {
          await showSecureStorageError(context, e);
        }
        return;
      }
      if (cachedWebId != null && cachedWebId.isNotEmpty) {
        try {
          final cachedOrigin = Uri.parse(cachedWebId).origin;
          final requestedOrigin = Uri.parse(podServer).origin;

          if (cachedOrigin != requestedOrigin) {
            await deleteLogIn();
            solidLoginStatusNotifier.markLoggedOut();
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
      clientId: clientId,
      redirectUris: redirectUris,
      postLogoutRedirectUris: postLogoutRedirectUris,
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
      solidLoginStatusNotifier.markLoggedOut();
    }

    // 20260924 gjw CONTINUE MEANS "USE THE APP WITHOUT A POD", so an
    // unreadable keyring must not stop it.
    //
    // isUserLoggedIn() reads secure storage. This used to show the
    // secure-storage dialog and then RETURN, which left CONTINUE doing
    // nothing whatever: the user tapped it, dismissed a dialog about a login
    // they were not attempting, and stayed on the login page with no way in.
    // Under strict snap confinement, where the keyring is refused until an
    // interface is connected by hand, that made the app entirely unusable
    // rather than merely Pod-less.
    //
    // Being unable to READ the session is not an error here, it is the
    // answer: no readable session means not logged in. So carry on into the
    // app with data kept on the device, which is exactly what the button
    // offers. Both blocks below are guarded by isLoggedIn, so false lands
    // the user straight in the app.
    //
    // The login paths keep the dialog: someone actually signing in does need
    // to be told why it failed.

    bool isLoggedIn;
    try {
      isLoggedIn = await isUserLoggedIn();
    } catch (e) {
      debugPrint(
        'performContinue: isUserLoggedIn failed, continuing logged out: $e',
      );
      isLoggedIn = false;
    }

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
          solidLoginStatusNotifier.markLoggedOut();

          if (!context.mounted) return;

          showSnackbar(
            'Your POD directory structure is not initialised or is incomplete. '
            'Please log in to initialise your POD.',
            duration: const Duration(seconds: 5),
          );

          return;
        }
      } on Object catch (e) {
        debugPrint('Continue: POD structure check failed: $e');

        if (!context.mounted) return;

        Navigator.of(context, rootNavigator: true).pop();

        // 20260915 gjw Probe the network so the message says whether the
        // device is offline, the server name cannot be looked up, or the
        // server itself is not responding.

        final target = await getWebId() ?? '';
        final message = connectionFailureMessage(
          'Unable to check your POD.',
          target,
          await diagnoseConnection(target),
        );

        if (!context.mounted) return;

        showSnackbar(message, duration: const Duration(seconds: 5));

        return;
      }
    }

    if (!context.mounted) return;

    // Ensure the security key has been fetched once logged in.

    if (isLoggedIn) {
      if (!await getKeyFromUserIfRequired(context, childWidget)) return;
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
    if (_tryAnotherAccountInProgress) {
      // Ignore rapid repeat clicks while we are already switching account.
      return;
    }
    _tryAnotherAccountInProgress = true;
    try {
      cancelSolidAuthenticate();
      await clearPodStructureInitialised();
      await silentLogout();
      solidLoginStatusNotifier.markLoggedOut();
      if (!context.mounted) return;

      await performLoginCallback();
    } finally {
      _tryAnotherAccountInProgress = false;
    }
  }
}
