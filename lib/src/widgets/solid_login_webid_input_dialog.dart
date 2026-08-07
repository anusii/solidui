/// A dialog to input Group of WebIDs.
///
// Time-stamp: <Friday 2025-10-24 09:03:05 +1100 Graham Williams>
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
/// Authors: Anushka Vidanage

library;

import 'package:flutter/material.dart';

import 'package:solidui/src/constants/solid_config.dart';
import 'package:solidui/src/utils/solid_alert.dart';
import 'package:solidui/src/widgets/solid_login_auth_handler.dart';
import 'package:solidui/src/widgets/solid_popup_login.dart';

/// A dialog for adding an individual webId. Function call requires the
/// following inputs
/// [context] is the BuildContext from which this function is called.
///
/// The text field is prefilled with the last WebID/server URL that the
/// user successfully authenticated with (when available), so an
/// accidentally logged-out user does not have to retype it. Falls back
/// to [SolidConfig.defaultServerUrl] for first-time users.

Future<dynamic> loginWebIdInputDialog({
  required BuildContext context,
  required String clientId,
  required List<String> redirectUris,
  List<String> postLogoutRedirectUris = const [],
}) async {
  final lastWebId = await SolidLoginAuthHandler.getLastWebId();
  if (!context.mounted) return null;

  final formControllerWebId = TextEditingController()
    ..text = (lastWebId != null && lastWebId.isNotEmpty)
        ? lastWebId
        : SolidConfig.defaultServerUrl;
  return showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 50),
        title: const Text('Input server URL/your WebId to login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Web ID text field.
            TextFormField(
              controller: formControllerWebId,
              decoration: const InputDecoration(
                hintText:
                    '${SolidConfig.defaultServerUrl}/'
                    'username/profile/card#me',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              final receiverWebId = formControllerWebId.text.trim();

              // Check the web ID field is not empty and it is a true link.

              if (receiverWebId.isNotEmpty &&
                  Uri.parse(receiverWebId.replaceAll('#me', '')).isAbsolute) {
                final outerNavigator = Navigator.of(context);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                }
                await outerNavigator.push(
                  MaterialPageRoute(
                    builder: (_) => SolidPopupLogin(
                      webId: receiverWebId,
                      clientId: clientId,
                      redirectUris: redirectUris,
                      postLogoutRedirectUris: postLogoutRedirectUris,
                    ),
                  ),
                );
              } else {
                if (!dialogContext.mounted) return;
                await alert(dialogContext, 'Please enter a valid URL/WebID');
              }
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}
