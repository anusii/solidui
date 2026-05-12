/// pop up login button
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
/// Authors: Kevin Wang, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:solidpod/solidpod.dart'
    show
        getWebId,
        isUserLoggedIn,
        solidAuthenticate,
        initialStructureTest,
        generateDefaultFolders,
        generateDefaultFiles;

import 'package:solidui/src/constants/initial_setup.dart'
    show initialStructureSnackbarMsg, initialUpdateSnackbarMsg;
import 'package:solidui/src/constants/solid_config.dart';
import 'package:solidui/src/constants/ui.dart';
import 'package:solidui/src/screens/initial_setup_screen.dart';
import 'package:solidui/src/services/solid_login_status_notifier.dart';
import 'package:solidui/src/utils/solid_pod_helpers.dart' show isPodUpdateMode;
import 'package:solidui/src/widgets/solid_loading_screen.dart';
import 'package:solidui/src/widgets/solid_login_auth_handler.dart';

/// A widget to pop up the login prompt if the user is not logged in.

class SolidPopupLogin extends StatefulWidget {
  /// Constructor for the PopupLogin.

  const SolidPopupLogin({this.webId = SolidConfig.defaultServerUrl, super.key});

  /// The URI of the user's webID used to identify the Solid server to
  /// authenticate against.
  /// Currently this is not a required argument here and is set
  /// by default.

  final String webId;

  @override
  State<SolidPopupLogin> createState() => _SolidPopupLoginState();
}

class _SolidPopupLoginState extends State<SolidPopupLogin> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Returns the capitalised current app name from the platform package
  // info, or the generic fallback when unavailable. Used to produce the
  // POD setup snackbar message. Also replaces a trailing pod with
  // Pod.

  Future<String> _currentAppName() async {
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

  // Verify the remote POD directory structure and navigate to the setup
  // screen when resources are missing.

  Future<bool> _checkAndSetupPod(BuildContext context) async {
    final defaultFolders = await generateDefaultFolders();
    final defaultFiles = await generateDefaultFiles();
    final resCheckList = await initialStructureTest(
      defaultFolders,
      defaultFiles,
    );
    final allExists = resCheckList.first as bool;

    if (!context.mounted) return false;

    if (!allExists) {
      // Determine whether the POD needs a first-time setup or an update,
      // then surface the corresponding snackbar so the user has the
      // right context before the wizard opens.

      final isUpdate = await isPodUpdateMode(resCheckList);
      final appName = await _currentAppName();
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUpdate
                ? initialUpdateSnackbarMsg(appName)
                : initialStructureSnackbarMsg(appName),
          ),
          duration: const Duration(seconds: 5),
        ),
      );

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InitialSetupScreen(
            resCheckList: resCheckList,
            isUpdate: isUpdate,
            child: _successDialog(),
          ),
        ),
      );
    }

    return true;
  }

  // Login and check POD initialisation status.
  // If POD structure is incomplete, navigate to InitialSetupScreen.

  Future<bool> _loginAndInitPods(String webId, BuildContext context) async {
    try {
      await solidAuthenticate(webId, context);

      // Persist the WebID/server URL so the re-login dialog can prefill it
      // next time the user is logged out. Prefer the canonical WebID
      // returned by the server when available.

      final canonicalWebId = await getWebId();
      await SolidLoginAuthHandler.setLastWebId(
        (canonicalWebId != null && canonicalWebId.isNotEmpty)
            ? canonicalWebId
            : webId,
      );

      // Notify global listeners (e.g. the status bar) that the login state
      // has just changed.

      await solidLoginStatusNotifier.refreshStatus();

      if (!context.mounted) return false;

      return _checkAndSetupPod(context);
    } on Object catch (e) {
      debugPrint('solidAuthenticate() failed: $e');

      // Check whether auth data was persisted before the failure – if so,
      // the POD is not initialised rather than the server being down.

      final isNowLoggedIn = await isUserLoggedIn();

      if (!context.mounted) return false;

      if (isNowLoggedIn) {
        // Snackbar is emitted by _checkAndSetupPod() once it knows
        // whether the POD needs a first-time setup or an update.

        return _checkAndSetupPod(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to authenticate with $webId. '
              'The server may be inaccessible or down.',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      return false;
    }
  }

  // Build success dialog widget.

  Widget _successDialog() {
    return AlertDialog(
      title: const Text('Success'),
      content: const Text(
        'You have successfully logged in and/or initialised your PODs',
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () {
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder(
        future: _loginAndInitPods(widget.webId, context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _loadedScreen(snapshot.data!);
          }
          return loadingScreen(normalLoadingScreenHeight);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _loadedScreen(bool loginStatus) {
    final dialogTitle = loginStatus ? 'Success' : 'Failed';
    final dialogContent = loginStatus
        ? 'You have successfully logged in'
        : 'You have cancelled the login';
    return AlertDialog(
      title: Text(dialogTitle),
      content: Text(dialogContent),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
