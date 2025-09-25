/// Security Key Manager UI Components.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Ashley Tang, Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart' show AppInfo, getWebId;

import 'package:solidui/src/widgets/solid_security_key_manager_helpers.dart';

/// UI builder for Security Key Manager dialog content.

class SolidSecurityKeyManagerUI {
  /// Builds the content of the security key manager dialog.

  static Widget buildDialogContent(
    BuildContext context,
    String title,
    bool isLoading,
    bool hasExistingKey,
    bool showViewKeyButton,
    bool showForgetKeyButton,
    VoidCallback onShowKey,
    VoidCallback onSetChangeKey,
    VoidCallback onForgetKey,
  ) {
    const smallGapV = SizedBox(height: 20.0);

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface,
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
            // Header.
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 24.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Interactive options.
            Container(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showViewKeyButton) ...[
                          SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasExistingKey
                                    ? Theme.of(context).colorScheme.surface
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                foregroundColor: hasExistingKey
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                side: BorderSide(
                                  color: hasExistingKey
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: hasExistingKey ? onShowKey : null,
                              child: const Text('Show Security Key'),
                            ),
                          ),
                          smallGapV,
                        ],
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: onSetChangeKey,
                            child: Text(
                              hasExistingKey ? 'Change Key' : 'Set Key',
                            ),
                          ),
                        ),
                        if (hasExistingKey && showForgetKeyButton) ...[
                          smallGapV,
                          SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: onForgetKey,
                              child: const Text('Forget Security Key'),
                            ),
                          ),
                        ],
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

  /// Shows a confirmation dialogue before forgetting the security key.

  static Future<bool> showForgetKeyConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Confirm Delete',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to forget this security key?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(
                  'This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                style: SolidSecurityKeyManagerHelpers.getButtonStyle(
                  Theme.of(context),
                  isDestructive: true,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
