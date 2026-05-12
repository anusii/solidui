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

import 'package:solidui/src/widgets/change_key_dialog.dart' show changeKeyPopup;
import 'package:solidui/src/widgets/solid_security_key_cache_dialogs.dart';
import 'package:solidui/src/widgets/solid_security_key_set_dialog.dart';
import 'package:solidui/src/widgets/solid_security_key_ui_helpers.dart';
import 'package:solidui/src/widgets/solid_security_key_view_dialogs.dart';

/// Dialog management for Security Key Manager.

class SolidSecurityKeyManagerDialogs {
  /// Shows the key input dialog for existing keys.
  ///
  /// Returns `true` if the security key was successfully changed, otherwise
  /// `false`.

  static Future<bool> showKeyInputDialog(
    BuildContext context,
    Widget appWidget,
    Future<void> Function() onKeyChanged,
  ) async {
    try {
      final changed = await changeKeyPopup(context, appWidget);
      if (!context.mounted) return changed;
      await onKeyChanged();
      return changed;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      final isScaffoldError =
          errorStr.contains('scaffold') || errorStr.contains('assertion');
      final isCancellation =
          errorStr.contains('cancel') || errorStr.contains('dismissed');

      if (!isScaffoldError && !isCancellation && context.mounted) {
        SecurityKeyUIHelpers.showErrorSnackBar(
          context,
          'Failed to change security key: ${e.toString()}',
        );
      }
      return false;
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
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SetKeyDialog(
        keyController: keyController,
        confirmKeyController: confirmKeyController,
        onKeyChanged: onKeyChanged,
        handleSubmissionFunction: handleSubmissionFunction,
      ),
    );
  }

  /// Shows the key file not found dialogue.

  static Future<void> showKeyFileNotFoundDialog(
    BuildContext context,
    Future<void> Function() checkKeyStatus,
    Future<void> Function(BuildContext) showKeyInputDialog,
  ) async {
    await SecurityKeyUIHelpers.showErrorDialog(
      context,
      'Security Key File Not Found',
      'The security key file could not be found. Would you like to set a new '
          'security key?',
    );
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
    await SecurityKeyViewDialogs.showPrivateData(
      title,
      context,
      hasExistingKey,
      setLoading,
      showKeyFileNotFoundDialog,
    );
  }

  /// Shows the cache security key input dialog.

  static Future<String?> showCacheKeyDialog(
    BuildContext context,
    TextEditingController keyController,
  ) async {
    return SecurityKeyCacheDialogs.showCacheKeyDialog(context, keyController);
  }

  /// Shows an error dialog for invalid security key.

  static Future<void> showInvalidKeyDialog(BuildContext context) async {
    return SecurityKeyCacheDialogs.showInvalidKeyDialog(context);
  }

  /// Handles the login redirect after showing login required dialog.

  static Future<void> handleLoginRedirect(BuildContext context) async {
    return SecurityKeyCacheDialogs.handleLoginRedirect(context);
  }
}
