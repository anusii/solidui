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
    show getEncKeyPath, getWebId, isUserLoggedIn, KeyManager, verifySecurityKey;

import 'package:solidui/src/constants/ui.dart' show SecurityStrings;
import 'package:solidui/src/services/solid_login_status_notifier.dart'
    show solidLoginStatusNotifier;
import 'package:solidui/src/services/solid_security_key_notifier.dart'
    show securityKeyNotifier;
import 'package:solidui/src/widgets/security_key_ui.dart' show SecurityKeyUI;
import 'package:solidui/src/widgets/solid_login_webid_input_dialog.dart';

/// Inspects the missing-resources list returned by `initialStructureTest`
/// and returns `true` when the POD already contains the encryption key
/// file for this app but is missing other resources.
///
/// This distinguishes two very different wizard scenarios:
///   * "Update" mode (true): the user has previously initialised their POD
///     for this app and simply needs to add newly required folders or
///     files (e.g. a notifications folder added in a later app version).
///     The wizard should reuse the existing security key, not create a
///     new one.
///   * "First-time setup" mode (false): the POD has never been initialised
///     for this app, so the encryption key file is also missing.
///
/// Using the cached [resCheckList] avoids an extra network round-trip
/// because the enc-keys.ttl file is already verified by the structure
/// test.

Future<bool> isPodUpdateMode(List<dynamic> resCheckList) async {
  try {
    if (resCheckList.isEmpty) return false;
    final allExists = resCheckList.first as bool;

    // When every expected folder/file is already in place there is no
    // missing resource to "update"; fall back to first-time-setup wording
    // which is the safe default for the caller's snackbar/logic.

    if (allExists) return false;

    final missing = resCheckList.last as Map;
    final missingFileNames = ((missing['fileNames'] as List?) ?? const [])
        .map((e) => e.toString())
        .toSet();

    // enc-keys.ttl is the on-POD marker that the app has been initialised
    // at least once. If it is present we are only topping up additional
    // resources — i.e. running the update wizard.

    final encKeyPath = await getEncKeyPath();
    final encKeyFileName = encKeyPath.split('/').last;
    return !missingFileNames.contains(encKeyFileName);
  } on Object catch (e) {
    debugPrint('isPodUpdateMode failed: $e');
    return false;
  }
}

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

    // After the popup-driven re-login flow, broadcast the new auth state so
    // any listeners (e.g. the dynamic status bar, app-level WebID labels)
    // can refresh themselves regardless of whether the user actually
    // completed the login.

    await solidLoginStatusNotifier.refreshStatus();
  }
  return isUserLoggedIn();
}

/// Ask for the security key from the user if the security key is not available
/// or cannot be verfied using the verification key stored in PODs.

Future<bool> getKeyFromUserIfRequired(
  BuildContext context,
  Widget child,
) async {
  if (await KeyManager.hasSecurityKey()) {
    return true;
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
        if (context.mounted) Navigator.pop(context, true);
      },
      child: child,
    );

    if (context.mounted) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => securityKeyInput),
      );

      // Notify the global status bar notifier that the key status may have
      // changed after the user submitted (or dismissed) the key prompt.

      await securityKeyNotifier.refreshStatus();

      return result ?? false;
    }
    return false;
  }
}
