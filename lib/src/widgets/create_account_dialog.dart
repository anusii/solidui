/// Show a pop up widget to create a new account on a Solid server.
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
        CssEmailAlreadyRegisteredException,
        createCssAccount;

import 'package:solidui/src/utils/snack_bar.dart';
import 'package:solidui/src/widgets/security_key_ui.dart';

/// Displays a dialog for creating a new account on a Community Solid
/// Server (CSS v7+).
///
/// The CSS account management API is independent of the OIDC authentication
/// flow, so no existing session is required — this can be called before the
/// user has logged in.
///
/// [serverUrl] is the base URL of the Solid server the account should be
/// created on, e.g. `https://pods.solidcommunity.au`.
///
/// [context] is the BuildContext from which this function is called.
/// [child] is the widget to navigate back to on cancel.
///
/// Returns `true` if the account was created successfully, otherwise `false`.
///
/// Note: this only works on servers running Community Solid Server v7 or
/// later. On other servers a message is shown that account creation is not
/// supported.

Future<bool> createAccountPopup(
  BuildContext context,
  Widget child, {
  required String serverUrl,
}) async {
  final message =
      'Create a new account on $serverUrl.\n'
      'Enter an email address, a password, and the name for your new Pod.';
  const emailStr = 'account_email';
  const passwordStr = 'new_password';
  const passwordRepeatStr = 'new_password_repeat';
  const podNameStr = 'pod_name';
  final formKey = GlobalKey<FormBuilderState>();

  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Please enter an email address.';
    }
    if (!email.contains('@')) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter a password.';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  String? validatePasswordRepeat(String password) {
    final formData = formKey.currentState?.value as Map<String, dynamic>;
    if (formData.containsKey(passwordStr) &&
        formData.containsKey(passwordRepeatStr) &&
        formData[passwordStr].toString() !=
            formData[passwordRepeatStr].toString()) {
      return 'Passwords do not match.';
    }
    return null;
  }

  // Pod name must be a valid URL path segment.

  String? validatePodName(String podName) {
    if (podName.isEmpty) {
      return 'Please enter a Pod name.';
    }
    final valid = RegExp(r'^[a-zA-Z0-9._~-]+$');
    if (!valid.hasMatch(podName)) {
      return 'Pod name may only contain letters, digits, hyphens,'
          ' underscores, tildes, and dots.';
    }
    return null;
  }

  final outerContext = context;

  BuildContext? dialogContext;

  // Tracks whether the account was actually created, so callers can react
  // (e.g. pre-fill the login form with the new email).

  var createdSuccessfully = false;

  Future<void> submitForm(Map<String, dynamic> formDataMap) async {
    final email = formDataMap[emailStr].toString();
    final password = formDataMap[passwordStr].toString();
    final passwordRepeat = formDataMap[passwordRepeatStr].toString();
    final podName = formDataMap[podNameStr]?.toString() ?? '';

    if (validateEmail(email) != null ||
        validatePassword(password) != null ||
        validatePasswordRepeat(passwordRepeat) != null ||
        validatePodName(podName) != null) {
      return;
    }

    late Color bgColor;
    late Duration duration;
    late String msg;

    // Keep the dialog open on duplicate email so the user can try another.

    var popDialog = true;

    try {
      final podUrl = await createCssAccount(
        serverUrl: serverUrl,
        email: email,
        password: password,
        podName: podName.isEmpty ? null : podName,
      );

      createdSuccessfully = true;
      if (podUrl != null) {
        msg = 'Account and Pod created successfully!\nPod URL: $podUrl';
      } else {
        msg = 'Account created successfully! You can now log in.';
      }
      bgColor = Colors.green;
      duration = const Duration(seconds: 6);
    } on CssEmailAlreadyRegisteredException {
      msg = 'An account with that email already exists on this server.';
      bgColor = Colors.red;
      duration = const Duration(seconds: 7);
      popDialog = false;
    } on CssAccountApiNotSupportedException {
      msg =
          'This Solid server does not support account creation'
          ' from within an app.';
      bgColor = Colors.red;
      duration = const Duration(seconds: 7);
    } on Exception catch (e) {
      msg = 'Failed to create the account! $e';
      bgColor = Colors.red;
      duration = const Duration(seconds: 7);
    } finally {
      final dialogCtx = dialogContext;
      if (popDialog && dialogCtx != null && dialogCtx.mounted) {
        Navigator.pop(dialogCtx);
      }
      if (outerContext.mounted) {
        showSnackBar(outerContext, msg, bgColor, duration: duration);
      }
    }
  }

  final inputFields = [
    (
      fieldKey: emailStr,
      fieldLabel: 'Email Address',
      validateFunc: (email) => validateEmail(email as String),
    ),
    (
      fieldKey: passwordStr,
      fieldLabel: 'Password',
      validateFunc: (password) => validatePassword(password as String),
    ),
    (
      fieldKey: passwordRepeatStr,
      fieldLabel: 'Repeat Password',
      validateFunc: (password) => validatePasswordRepeat(password as String),
    ),
    (
      fieldKey: podNameStr,
      fieldLabel: 'Pod Name',
      validateFunc: (podName) => validatePodName(podName as String),
    ),
  ];

  // webId is null — the user has no account yet.

  final createAccountForm = SecurityKeyUI(
    webId: null,
    title: 'Create Account',
    message: message,
    inputFields: inputFields,
    formKey: formKey,
    submitFunc: submitForm,
    displayMode: SecurityKeyDisplayMode.dialog,
    plainTextFieldKeys: const {emailStr, podNameStr},
    child: child,
  );

  if (context.mounted) {
    await showDialog(
      context: context,
      builder: (builderContext) {
        dialogContext = builderContext;
        return AlertDialog(
          content: SingleChildScrollView(child: createAccountForm),
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          elevation: 0,
        );
      },
    );
  }

  return createdSuccessfully;
}
