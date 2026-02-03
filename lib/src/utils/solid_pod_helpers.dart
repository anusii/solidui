/// Helper functions for Solid Pod operations requiring user interaction.
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
/// Authors: Anushka Vidanage, Dawei Chen, Zheyuan Xu, Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:solidpod/solidpod.dart'
    show isUserLoggedIn, getWebId, KeyManager, verifySecurityKey;

import 'package:solidui/src/constants/ui.dart' show SecurityStrings;
import 'package:solidui/src/widgets/security_key_ui.dart' show SecurityKeyUI;
import 'package:solidui/src/widgets/solid_login_webid_input_dialog.dart';

/// Login if the user has not done so.

Future<bool> loginIfRequired(BuildContext context) async {
  final loggedIn = await isUserLoggedIn();
  if (!loggedIn && context.mounted) {
    await loginWebIdInputDialog(context);
    // await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => const SolidPopupLogin(),
    //     ));
  }
  return isUserLoggedIn();
}

/// Ask for the security key from the user if the security key is not available
/// or cannot be verfied using the verification key stored in PODs.

Future<void> getKeyFromUserIfRequired(
  BuildContext context,
  Widget child,
) async {
  if (await KeyManager.hasSecurityKey()) {
    return;
  } else {
    final verificationKey = await KeyManager.getVerificationKey();
    // Get the webId to display in the security key prompt.

    final webId = await getWebId();

    const inputKey = 'security_key';
    final inputField = (
      fieldKey: inputKey,
      fieldLabel: 'Security Key',
      validateFunc: (key) {
        assert(key != null);
        return verifySecurityKey(key as String, verificationKey)
            ? null
            : 'Incorrect Security Key';
      },
    );

    // Use the unified SecurityKeyUI widget with the appropriate configuration.

    final securityKeyInput = SecurityKeyUI(
      webId: webId,
      title: 'Security Key',
      message: SecurityStrings.securityKeyPrompt,
      inputFields: [inputField],
      formKey: GlobalKey<FormBuilderState>(),
      submitFunc: (formDataMap) async {
        await KeyManager.setSecurityKey(formDataMap[inputKey].toString());
        debugPrint('Security key saved');
        if (context.mounted) Navigator.pop(context);
      },
      child: child,
    );

    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => securityKeyInput),
      );
    }
  }
}
