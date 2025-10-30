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
    show checkLoggedIn, getWebId, KeyManager, verifySecurityKey;

import 'package:solidui/src/widgets/solid_popup_login.dart';

/// Check if the user is logged in and prompt for login if required.
///
/// This function checks whether the user is currently logged in to their
/// Solid Pod. If not logged in, it displays a login dialog to prompt the
/// user to authenticate.
///
/// [context] - The build context for displaying dialogs
/// [child] - The child widget to return to after login
///
/// Returns `true` if the user is logged in or successfully logs in,
/// `false` if the user cancels the login or login fails.

Future<bool> loginIfRequired(
  BuildContext context,
  Widget child,
) async {
  if (await checkLoggedIn()) {
    return true;
  }

  if (!context.mounted) return false;

  // Show login popup dialog.

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const SolidPopupLogin(),
  );

  // Return whether the login was successful.

  return result ?? false;
}

/// Ask for the security key from the user if the security key is not available
/// or cannot be verified using the verification key stored in Pods.
///
/// This function checks if a security key is already cached. If not, it prompts
/// the user to enter their security key and verifies it against the verification
/// key stored in their Pod.
///
/// [context] - The build context for displaying dialogs
/// [child] - The child widget to return to after entering the key
///
/// Returns `true` if the security key is available or successfully entered,
/// `false` if the user cancels the operation.

Future<bool> getKeyFromUserIfRequired(
  BuildContext context,
  Widget child,
) async {
  if (await KeyManager.hasSecurityKey()) {
    return true;
  }

  final verificationKey = await KeyManager.getVerificationKey();

  // Get the webId to display in the security key prompt.

  final webId = await getWebId();

  if (!context.mounted) return false;

  // Create a simple security key input dialog.

  final keyController = TextEditingController();
  final formKey = GlobalKey<FormBuilderState>();

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Security Key Required'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Currently logged in as:',
            style: Theme.of(dialogContext).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            webId ?? 'Not logged in',
            style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                  color: webId != null ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Please enter your security key to access encrypted data:',
          ),
          const SizedBox(height: 16),
          FormBuilder(
            key: formKey,
            child: FormBuilderTextField(
              name: 'security_key',
              controller: keyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Security Key',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a security key';
                }
                if (!verifySecurityKey(value, verificationKey)) {
                  return 'Incorrect security key';
                }
                return null;
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext, false);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (formKey.currentState?.saveAndValidate() ?? false) {
              final key = keyController.text;
              await KeyManager.setSecurityKey(key);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext, true);
              }
            }
          },
          child: const Text('Submit'),
        ),
      ],
    ),
  );

  keyController.dispose();

  // Return whether the key was successfully entered.

  return result ?? false;
}
