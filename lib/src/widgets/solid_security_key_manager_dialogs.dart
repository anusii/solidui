/// Security Key Manager Dialogue Components.
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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart'
    show SolidFunctionCallStatus, changeKeyPopup, getEncKeyPath, readPod;

import 'package:solidui/src/widgets/solid_security_key_manager_helpers.dart';
import 'package:solidui/src/widgets/solid_security_key_view.dart';

/// Dialog management for Security Key Manager.

class SolidSecurityKeyManagerDialogs {
  /// Shows the key input dialog for existing keys.

  static Future<void> showKeyInputDialog(
    BuildContext context,
    Widget appWidget,
    Future<void> Function() onKeyChanged,
  ) async {
    try {
      await changeKeyPopup(context, appWidget);
      await onKeyChanged();
    } catch (e) {
      if (context.mounted) {
        SolidSecurityKeyManagerHelpers.showErrorSnackBar(context, e.toString());
      }
    }
  }

  /// Shows the new key dialogue.

  static Future<void> showNewKeyDialog(
    BuildContext context,
    TextEditingController keyController,
    TextEditingController confirmKeyController,
    Future<void> Function() onKeyChanged,
    Future<bool> Function(String key, String confirmKey)
        handleSubmissionFunction,
  ) async {
    await SolidSecurityKeyManagerHelpers.showNewKeyDialog(
      context,
      keyController,
      confirmKeyController,
      onKeyChanged,
      handleSubmissionFunction,
    );
  }

  /// Shows the key file not found dialogue.

  static Future<void> showKeyFileNotFoundDialog(
    BuildContext context,
    Future<void> Function() checkKeyStatus,
    Future<void> Function(BuildContext) showKeyInputDialog,
  ) async {
    await SolidSecurityKeyManagerHelpers.showErrorDialog(
      context,
      'Security Key File Not Found',
      'The security key file could not be found. Would you like to set a new '
          'security key?',
    );
    // Clear key manager state and show input dialogue
    await checkKeyStatus();
    if (context.mounted) {
      await showKeyInputDialog(context);
    }
  }

  /// Shows the private key data.

  static Future<void> showPrivateData(
    String title,
    BuildContext context,
    bool hasExistingKey,
    Widget appWidget,
    void Function(bool) setLoading,
    void Function(bool) onKeyStatusChanged,
    Future<void> Function() checkKeyStatus,
    Future<void> Function(BuildContext) showKeyFileNotFoundDialog,
  ) async {
    if (!hasExistingKey) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Notice'),
          content: const Text(
            'No security key found. Please set a security key first.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    setLoading(true);

    try {
      final filePath = await getEncKeyPath();
      if (!context.mounted) return;

      final fileContent = await readPod(
        filePath,
        context,
        appWidget,
      );
      if (!context.mounted) return;

      if (fileContent == SolidFunctionCallStatus.notLoggedIn.toString()) {
        await SolidSecurityKeyManagerHelpers.showErrorDialog(
          context,
          'Not Logged In',
          'You must be logged in to view security keys.',
        );
        return;
      }
      if (fileContent == SolidFunctionCallStatus.fail.toString()) {
        await showKeyFileNotFoundDialog(context);
        return;
      }
      if (fileContent.isNotEmpty) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SolidSecurityKeyView(title: title, keyInfo: fileContent),
          ),
        );
      } else {
        await SolidSecurityKeyManagerHelpers.showErrorDialog(
          context,
          'Empty Key File',
          'The security key file exists but appears to be empty.',
        );
      }
    } catch (e) {
      debugPrint('Exception reading security key: $e');
      if (context.mounted) {
        await SolidSecurityKeyManagerHelpers.showErrorDialog(
          context,
          'Error Reading Key',
          e.toString(),
        );
      }
    } finally {
      setLoading(false);
    }
  }
}
