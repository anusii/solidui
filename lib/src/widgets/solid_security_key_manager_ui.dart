/// SolidUI - Security Key Manager UI Components.
///
/// Copyright (C) 2025-2026, Software Innovation Institute, ANU.
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
/// Authors: Ashley Tang, Tony Chen, Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart' show AppInfo, getWebId;

import 'package:solidui/src/widgets/solid_security_key_ui_helpers.dart';

/// UI builder for Security Key Manager dialog content.

class SolidSecurityKeyManagerUI {
  static const _gap = SizedBox(height: 20.0);

  static ButtonStyle _btnStyle(ThemeData t, {bool isError = false}) =>
      ElevatedButton.styleFrom(
        backgroundColor: t.colorScheme.surface,
        foregroundColor: isError ? t.colorScheme.error : t.colorScheme.primary,
        side: BorderSide(
          color: isError ? t.colorScheme.error : t.colorScheme.primary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );

  static Widget _btn(String text, VoidCallback onPressed, ButtonStyle style) =>
      SizedBox(
        height: 44,
        child: ElevatedButton(
          style: style,
          onPressed: onPressed,
          child: Text(text),
        ),
      );

  static Widget buildDialogContent(
    BuildContext context,
    String title,
    bool isLoading,
    bool isKeyCached,
    bool showViewKeyButton,
    VoidCallback onShowKey,
    VoidCallback onChangeKey,
    VoidCallback onCacheKey,
    VoidCallback onClearCache,
    VoidCallback onCancel,
  ) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: cs.surface,
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 24.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: t.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isKeyCached) ...[
                          if (showViewKeyButton) ...[
                            _btn('Show Security Key', onShowKey, _btnStyle(t)),
                            _gap,
                          ],
                          _btn(
                            'Change Security Key',
                            onChangeKey,
                            _btnStyle(t),
                          ),
                          _gap,
                          _btn(
                            'Clear Cached Security Key',
                            onClearCache,
                            _btnStyle(t, isError: true),
                          ),
                        ] else ...[
                          _btn('Cache Security Key', onCacheKey, _btnStyle(t)),
                        ],
                        _gap,
                        _btn(
                          'Close',
                          onCancel,
                          ElevatedButton.styleFrom(
                            backgroundColor: cs.surfaceContainerHighest,
                            foregroundColor: cs.onSurfaceVariant,
                            side: BorderSide(color: cs.outline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main dialog widget with future builder.

  static Widget buildMainDialog(
    String? configTitle,
    Widget Function(String title) contentBuilder,
  ) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 24.0,
      ),
      child: FutureBuilder<({String name, String? webId})>(
        future: _getInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final appName = snapshot.data?.name;
            final title = configTitle ??
                'Security Key Management - '
                    '${appName!.isNotEmpty ? appName[0].toUpperCase() + appName.substring(1) : ""}';
            return contentBuilder(title);
          } else {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(24.0),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  /// Retrieves app information for the title.

  static Future<({String name, String? webId})> _getInfo() async =>
      (name: await AppInfo.name, webId: await getWebId());

  /// Shows a confirmation dialogue before clearing the cached security key.

  static Future<bool> showClearCacheConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            final cs = Theme.of(ctx).colorScheme;
            return AlertDialog(
              backgroundColor: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                'Clear Cached Security Key',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to clear the locally cached '
                    'security key?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You will need to re-enter your security key to access '
                    'encrypted data.',
                    style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
                  ),
                ),
                ElevatedButton(
                  style: SecurityKeyUIHelpers.getButtonStyle(
                    Theme.of(ctx),
                    isDestructive: true,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Clear', style: TextStyle(fontSize: 16)),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
