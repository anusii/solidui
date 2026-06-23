/// Show a pop up widget to change the Solid server account password.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
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

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:solidpod/solidpod.dart'
    show
        CssAccountApiNotSupportedException,
        CssWrongCredentialsException,
        NotLoggedInException,
        changeCssAccountPassword,
        getWebId,
        isUserLoggedIn;

import 'package:solidui/src/utils/snack_bar.dart';
import 'package:solidui/src/utils/web_id_parser.dart';
import 'package:solidui/src/widgets/security_key_ui.dart';

/// Displays a dialog for changing the account password on a Community Solid
/// Server (CSS v7+).
///
/// The CSS account management API is independent of the app's OIDC session,
/// so the user is asked for their account email address and current password
/// alongside the new password.
///
/// [context] is the BuildContext from which this function is called.
/// [child] is the widget to navigate back to on cancel.
///
/// Returns `true` if the password was changed successfully, otherwise
/// `false`.
///
/// Note: this only works on servers running Community Solid Server v7 or
/// later (e.g. solidcommunity.au). On other servers a message is shown that
/// changing the password is not supported.

Future<bool> changePasswordPopup(BuildContext context, Widget child) async {
  if (!await isUserLoggedIn()) {
    throw NotLoggedInException(
      'User must be logged in to change the account password.',
    );
  }

  final webId = await getWebId();
  final serverUrl = WebIdParts.tryParse(webId)?.serverUri;
  if (serverUrl == null) {
    throw NotLoggedInException(
      'Cannot determine the server URL from the WebID.',
    );
  }

  const message = 'Please enter your account email address, the current'
      ' password, the new password, and repeat the new password.';
  const emailStr = 'account_email';
  const currentPasswordStr = 'current_password';
  const newPasswordStr = 'new_password';
  const newPasswordRepeatStr = 'new_password_repeat';
  final formKey = GlobalKey<FormBuilderState>();

  // The email and current password can only be verified by the server, which
  // is asynchronous and cannot run in a synchronous form validator. So the
  // validators only check basic constraints; correctness is verified on
  // submit by `changeCssAccountPassword`, which throws
  // [CssWrongCredentialsException] when the credentials are wrong.

  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Please enter your account email address.';
    }
    if (!email.contains('@')) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? validateCurrentPassword(String password) =>
      password.isEmpty ? 'Please enter the current password.' : null;

  String? validateNewPassword(String password) {
    if (password.isEmpty) {
      return 'Please enter the new password.';
    }
    // Compare the entered strings directly to detect an unchanged password.
    final formData = formKey.currentState?.value;
    final currentPassword = formData?[currentPasswordStr]?.toString();
    if (currentPassword != null &&
        currentPassword.isNotEmpty &&
        password == currentPassword) {
      return 'New password is identical to current password.';
    }
    return null;
  }

  String? validateNewPasswordRepeat(String password) {
    final formData = formKey.currentState?.value as Map<String, dynamic>;
    if (formData.containsKey(newPasswordStr) &&
        formData.containsKey(newPasswordRepeatStr) &&
        formData[newPasswordStr].toString() !=
            formData[newPasswordRepeatStr].toString()) {
      return 'New passwords do not match.';
    }
    return null;
  }

  final outerContext = context;

  // Tracks whether the password was actually changed, so callers can react
  // accordingly.

  var changedSuccessfully = false;

  Future<void> submitForm(Map<String, dynamic> formDataMap) async {
    final email = formDataMap[emailStr].toString();
    final currentPassword = formDataMap[currentPasswordStr].toString();
    final newPassword = formDataMap[newPasswordStr].toString();
    final newPasswordRepeat = formDataMap[newPasswordRepeatStr].toString();

    if (validateEmail(email) != null ||
        validateCurrentPassword(currentPassword) != null ||
        validateNewPassword(newPassword) != null ||
        validateNewPasswordRepeat(newPasswordRepeat) != null) {
      return;
    }

    late Color bgColor;
    late Duration duration;
    late String msg;

    // Keep the dialog open on wrong credentials so the user can correct
    // their input; close it otherwise.

    var popDialog = true;

    try {
      await changeCssAccountPassword(
        serverUrl: serverUrl,
        email: email,
        oldPassword: currentPassword,
        newPassword: newPassword,
      );

      changedSuccessfully = true;
      msg = 'Successfully changed the account password!';
      bgColor = Colors.green;
      duration = const Duration(seconds: 4);
    } on CssWrongCredentialsException {
      msg = 'Incorrect email or current password!';
      bgColor = Colors.red;
      duration = const Duration(seconds: 7);
      popDialog = false;
    } on CssAccountApiNotSupportedException {
      msg = 'This Solid server does not support changing the password'
          ' from within an app.';
      bgColor = Colors.red;
      duration = const Duration(seconds: 7);
    } on Exception catch (e) {
      msg = 'Failed to change the account password! $e';
      bgColor = Colors.red;
      duration = const Duration(seconds: 7);
    } finally {
      if (popDialog && context.mounted) {
        Navigator.pop(context);
      }
      if (outerContext.mounted) {
        showSnackBar(outerContext, msg, bgColor, duration: duration);
      }
    }
  }

  final inputFields = [
    (
      fieldKey: emailStr,
      fieldLabel: 'Account Email Address',
      validateFunc: (email) => validateEmail(email as String),
    ),
    (
      fieldKey: currentPasswordStr,
      fieldLabel: 'Current Password',
      validateFunc: (password) => validateCurrentPassword(password as String),
    ),
    (
      fieldKey: newPasswordStr,
      fieldLabel: 'New Password',
      validateFunc: (password) => validateNewPassword(password as String),
    ),
    (
      fieldKey: newPasswordRepeatStr,
      fieldLabel: 'Repeat New Password',
      validateFunc: (password) => validateNewPasswordRepeat(password as String),
    ),
  ];

  // Use the unified SecurityKeyUI widget in dialog mode.

  final changePasswordForm = SecurityKeyUI(
    webId: webId,
    title: 'Change POD Password',
    message: message,
    inputFields: inputFields,
    formKey: formKey,
    submitFunc: submitForm,
    displayMode: SecurityKeyDisplayMode.dialog,
    plainTextFieldKeys: const {emailStr},
    child: child,
  );

  if (context.mounted) {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: changePasswordForm,
        ),
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  return changedSuccessfully;
}
