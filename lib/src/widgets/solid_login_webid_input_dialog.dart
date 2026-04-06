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
import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidpod/solidpod.dart' show whatIsWebID, demoWebID;

import 'package:solidui/solidui.dart'
    show smallGapV, makeSubHeading, WebIdLayout;
import 'package:solidui/src/constants/solid_config.dart';
import 'package:solidui/src/utils/solid_alert.dart';
import 'package:solidui/src/widgets/solid_popup_login.dart';

/// A dialog for adding an individual webId. Function call requires the
/// following inputs
/// [context] is the BuildContext from which this function is called.

Future<dynamic> loginWebIdInputDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      final formControllerWebId = TextEditingController()
        ..text = SolidConfig.defaultServerUrl;
      bool textEntered = false;

      return StatefulBuilder(
        builder: (context, setState) {
          String? getHelpText() {
            final text = formControllerWebId.text.trim();
            final uri = Uri.tryParse(text);

            if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
              return 'Must start with https://';
            }

            // Check for https scheme and ://
            if (!uri.isScheme('HTTPS') || !uri.toString().contains('://')) {
              return 'Must start with https://';
            }
            // Check WebID contains host followed by '/'

            if (!uri.path.contains('/')) {
              return 'Must have form https://[POD server host]/[their username]/profile/card#me';
            }
            // Check for WebID path with profile suffix
            if (!uri.path.toLowerCase().contains('/profile/card')) {
              return 'Must end with \'/[their username]/profile/card#me\'';
            }
            // Check ends in #me
            if (!(uri.fragment.toLowerCase() == 'me')) {
              return 'Must end with URL fragment #me after /profile/card';
            }
            // Check fully qualified web address
            // 20250721 jm Retaining this check, may not be needed
            if (!Uri.parse(text.replaceAll('#me', '')).isAbsolute) {
              return 'Must be a fully qualified web address';
            }
            // return null if the text is valid
            return null;
          }

          return AlertDialog(
            insetPadding: WebIdLayout.contentPadding,
            title: const Text('Input server URL/your WebId to login'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownTooltip(
                  message: '$whatIsWebID Eg: $demoWebID',
                  child: makeSubHeading('Enter your WebId'),
                ),
                smallGapV,
                // Web ID text field.
                TextFormField(
                  controller: formControllerWebId,
                  decoration: InputDecoration(
                    labelText: 'Individual\'s webID',
                    hintText: '${SolidConfig.defaultServerUrl}/'
                        'username/profile/card#me',
                    errorText: textEntered ? getHelpText() : null,
                  ),
                  onChanged: (value) => setState(() {
                    textEntered = true;
                  }),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  final receiverWebId = formControllerWebId.text.trim();

                  // Check the web ID field is not empty and it is a true link.

                  if (receiverWebId.isNotEmpty &&
                      Uri.parse(receiverWebId.replaceAll('#me', ''))
                          .isAbsolute) {
                    if (!context.mounted) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SolidPopupLogin(webId: receiverWebId),
                      ),
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  } else {
                    if (!context.mounted) return;
                    await alert(context, 'Please enter a valid URL/WebID');
                  }
                },
                child: const Text('Ok'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
  );
}
