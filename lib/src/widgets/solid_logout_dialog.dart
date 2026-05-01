/// Copyright (C) 2024-2025, Software Innovation Institute, ANU.
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
/// Authors: Dawei Chen, Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart'
    show getAppNameVersion, getWebId, logoutPod;

import 'package:solidui/src/services/solid_profile_service.dart';
import 'package:solidui/src/services/solid_login_status_notifier.dart';
import 'package:solidui/src/utils/web_id_parser.dart';

/// A pop up widget for user to logout.

class LogoutDialog extends StatefulWidget {
  /// Constructor.

  const LogoutDialog({
    required this.child,
    this.onLogoutSuccess,
    super.key,
  });

  /// The child widget after logging out.

  final Widget child;

  /// Optional callback invoked after successful logout.
  /// This is called AFTER [logoutPod] completes successfully but BEFORE
  /// navigation occurs. Use this to reset UI state such as security key
  /// status notifiers.

  final VoidCallback? onLogoutSuccess;

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  Widget _build(
    BuildContext context,
    String title,
    WebIdParts? webIdParts,
  ) {
    final contentText = webIdParts != null && webIdParts.username.isNotEmpty
        ? 'Logout ${webIdParts.username} from ${webIdParts.host}?'
        : 'Logout from the remote Solid Server for $title?';

    return AlertDialog(
      title: const Text('Notice'),
      content: Text(contentText),
      actions: [
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () async {
            if (await logoutPod()) {
              SolidProfileService.instance.clearCache();
              solidLoginStatusNotifier.markLoggedOut();
              widget.onLogoutSuccess?.call();
              if (context.mounted) {
                await Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => widget.child),
                  (Route<dynamic> route) => false,
                );
              }
            } else {
              if (context.mounted) {
                Navigator.pop(context);
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logging out failed'),
                    content: Text(
                      'Unable to logging out the $title, please try again later',
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                );
              }
            }
          },
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
        ({({String name, String version}) app, String? webId})>(
      future: () async {
        final app = await getAppNameVersion();
        final webId = await getWebId();
        return (app: app, webId: webId);
      }(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final appName = snapshot.data?.app.name;
          final title = appName != null && appName.isNotEmpty
              ? appName[0].toUpperCase() + appName.substring(1)
              : '';
          final webIdParts = WebIdParts.tryParse(snapshot.data?.webId);
          return _build(context, title, webIdParts);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

/// Display a pop up dialog for logging out.
///
/// Parameters:
/// - [context] - The build context.
/// - [child] - The widget to navigate to after successful logout.
/// - [onLogoutSuccess] - Optional callback invoked after successful logout
///   but before navigation. Use this to reset UI state managers.

Future<void> logoutPopup(
  BuildContext context,
  Widget child, {
  VoidCallback? onLogoutSuccess,
}) async {
  await showDialog(
    context: context,
    builder: (context) => LogoutDialog(
      onLogoutSuccess: onLogoutSuccess,
      child: child,
    ),
  );
}
