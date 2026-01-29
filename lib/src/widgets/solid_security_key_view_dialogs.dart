/// Security Key View Dialogue Components.
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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart'
    show PathType, SolidFunctionCallStatus, getEncKeyPath, readPod;

import 'package:solidui/src/widgets/solid_security_key_ui_helpers.dart';
import 'package:solidui/src/widgets/solid_security_key_utils.dart';

/// Dialogs for viewing security keys.

class SecurityKeyViewDialogs {
  /// Shows the private key data.

  static Future<void> showPrivateData(
    String title,
    BuildContext context,
    bool hasExistingKey,
    void Function(bool) setLoading,
    Future<void> Function(BuildContext) showKeyFileNotFoundDialog,
  ) async {
    if (!hasExistingKey) {
      await _showNoKeyFoundDialog(context);
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
        await showSecurityKeyDataDialog(context, title, fileContent);
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

  /// Shows a dialog when no key is found.

  static Future<void> _showNoKeyFoundDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Notice',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'No security key found. Please set a security key first.',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Shows the security key data in a dialogue.

  static Future<void> showSecurityKeyDataDialog(
    BuildContext context,
    String title,
    String keyInfo,
  ) async {
    final encFileData = parseEncKeyContent(keyInfo);
    final theme = Theme.of(context);

    final dataRows = encFileData.entries.map((entry) {
      return DataRow(
        cells: [
          DataCell(
            Text(
              entry.key as String,
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface),
            ),
          ),
          DataCell(
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                entry.value[1] as String,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogTheme = Theme.of(dialogContext);
        return AlertDialog(
          backgroundColor: dialogTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: dialogTheme.colorScheme.onSurface,
            ),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 30.0,
                columns: [
                  DataColumn(
                    label: Text(
                      'Parameter',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: dialogTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Value',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: dialogTheme.colorScheme.onSurface,
                      ),
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
                backgroundColor: dialogTheme.colorScheme.primary,
                foregroundColor: dialogTheme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
