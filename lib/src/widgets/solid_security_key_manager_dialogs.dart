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
    show
        PathType,
        SolidFunctionCallStatus,
        changeKeyPopup,
        getEncKeyPath,
        readPod;

import 'package:solidui/src/widgets/solid_security_key_set_dialog.dart';
import 'package:solidui/src/widgets/solid_security_key_ui_helpers.dart';
import 'package:solidui/src/widgets/solid_security_key_utils.dart';

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
      if (!context.mounted) return;
      await onKeyChanged();
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

  /// Shows the restore key dialog for verifying an existing security key.
  /// Used when server has enc-keys.ttl but local storage doesn't have the key.

  static Future<void> showRestoreKeyDialog(
    BuildContext context,
    TextEditingController keyController,
    Future<void> Function() onKeyRestored,
    Future<bool> Function(String key) handleRestoreFunction,
  ) async {
    keyController.clear();
    bool isLoading = false;
    bool obscureText = true;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.key, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Restore Security Key',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your encrypted data was found on the server.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please enter the security key you originally set to restore '
                'access to your encrypted data.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ If you forgot your key, your encrypted data cannot be recovered.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keyController,
                obscureText: obscureText,
                decoration: InputDecoration(
                  labelText: 'Security Key',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => obscureText = !obscureText),
                  ),
                ),
                enabled: !isLoading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);
                      final success =
                          await handleRestoreFunction(keyController.text);
                      if (success) {
                        if (context.mounted) Navigator.pop(context);
                        await onKeyRestored();
                      } else {
                        setState(() => isLoading = false);
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Restore'),
            ),
          ],
        ),
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
        pathType: PathType.relativeToPod,
      );
      if (!context.mounted) return;

      if (fileContent == SolidFunctionCallStatus.notLoggedIn.toString()) {
        await SecurityKeyUIHelpers.showErrorDialog(
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
        await _showSecurityKeyDialog(context, title, fileContent);
      } else {
        await SecurityKeyUIHelpers.showErrorDialog(
          context,
          'Empty Key File',
          'The security key file exists but appears to be empty.',
        );
      }
    } catch (e) {
      debugPrint('Exception reading security key: $e');
      if (context.mounted) {
        await SecurityKeyUIHelpers.showErrorDialog(
          context,
          'Error Reading Key',
          e.toString(),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  /// Shows the security key data in a dialogue.

  static Future<void> _showSecurityKeyDialog(
    BuildContext context,
    String title,
    String keyInfo,
  ) async {
    final encFileData = parseEncKeyContent(keyInfo);

    // Map the data into rows for the DataTable.

    final dataRows = encFileData.entries.map((entry) {
      return DataRow(
        cells: [
          DataCell(
            Text(entry.key as String, style: const TextStyle(fontSize: 12)),
          ),
          DataCell(
            SizedBox(
              width: 400,
              child: Text(
                entry.value[1] as String,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      );
    }).toList();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: DataTable(
              columnSpacing: 30.0,
              columns: const [
                DataColumn(
                  label: Text(
                    'Parameter',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Value',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: dataRows,
            ),
          ),
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
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
