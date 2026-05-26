/// A button for revoking permission.
///
// Time-stamp: <Saturday 2026-01-17 16:21:26 +1100 Graham Williams>
///
/// Copyright (C) 2024-2025, Software Innovation Institute, ANU.
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
/// Authors: Jess Moore, Anushka Vidanage

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidpod/solidpod.dart';

import 'package:solidui/solidui.dart' show ActionColors;
import 'package:solidui/src/utils/snack_bar.dart';
import 'package:solidui/src/utils/solid_alert.dart'
    show alertMaxWidthForCharsPerLine, defaultAlertMaxCharsPerLine;

/// A [StatefulWidget] for the revoke permission icon button. Updates
/// owner's ACL for resource, updates owner, granter, recipient logs,
/// and calls updatePermissions() to refresh permission table data.
///
/// Parameters:
/// - [resourceName] - The filename or file url of the resource. If [isExternalRes], it should be the url of the resource.
/// - [permDataMap] is the map of permission data for the [resourceName]
/// - [ownerWebId] - WebId of the owner of the resource. Required if the resource is externally owned.
/// - [granterWebId] - WebId of the granter of the resource. Required if the resource is externally owned.
/// - [receiverWebId] - WebId with access to the resource, one of ownerWebId, granterWebId or recipientWebId.
/// - [isFile] - Boolean flag describing whether the resource is a file. If false, the resource is assumed to be a directory.
/// - [isExternalRes] - Boolean flag describing whether the resource
/// is externally owned.
/// - [updatePermissionsFunction] is the function to be called to refresh the permission table.
///

class RevokePermissionButton extends StatefulWidget {
  /// The name of the file or directory for which permissions are being
  /// shown.

  final String resourceName;

  /// Map of access permission data being displayed for [resourceName].

  final Map<dynamic, dynamic> permDataMap;

  /// WebId with access to resource.

  final String receiverWebId;

  /// WebId of the resource owner.

  final String ownerWebId;

  /// WebId of the user granting/revoking access to the resource.

  final String granterWebId;

  /// A flag denoting whether resource is externally owned.

  final bool isExternalRes;

  /// A flag to determine whether the given resource is a file or not.

  final bool isFile;

  /// Function run to update permissions table

  final Function updatePermissionsFunction;

  const RevokePermissionButton({
    super.key,
    required this.resourceName,
    required this.permDataMap,
    required this.receiverWebId,
    required this.ownerWebId,
    required this.granterWebId,
    required this.updatePermissionsFunction,
    required this.isFile,
    this.isExternalRes = false,
  });

  @override
  State<RevokePermissionButton> createState() => _RevokePermissionButtonState();
}

class _RevokePermissionButtonState extends State<RevokePermissionButton> {
  @override
  void initState() {
    super.initState();
  }

  /// Build a human-friendly recipient label for the confirmation dialog.
  ///
  /// For Public or Authenticated User permissions, the raw receiver
  /// identifier is the underlying agent class URI (e.g. the FOAF Agent
  /// or ACL AuthenticatedAgent IRI), which is not meaningful to the
  /// user. Show a descriptive label instead.

  String _formatReceiverForDisplay(RecipientType recipientType) {
    if (recipientType == RecipientType.public) {
      return 'the Public';
    }
    if (recipientType == RecipientType.authUser) {
      return 'all signed-in users';
    }
    return widget.receiverWebId.replaceAll('.ttl', '');
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownTooltip(
      message: 'Revoke all access to this recipient',
      child: IconButton(
        icon: const Icon(
          Icons.delete,
          size: 24.0,
          color: ActionColors.delete,
        ),
        onPressed: () {
          // Derive recipient metadata once so we can adapt the
          // confirmation message to the recipient class.
          final recipientType = getRecipientType(
            widget.permDataMap[widget.receiverWebId][agentStr] as String,
            widget.receiverWebId,
          );
          final permList =
              widget.permDataMap[widget.receiverWebId][permStr] as List;
          final isPublicClass = recipientType == RecipientType.public ||
              recipientType == RecipientType.authUser;

          showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('Please Confirm'),
                content: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: alertMaxWidthForCharsPerLine(
                      defaultAlertMaxCharsPerLine,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Are you sure you want to remove the '
                        '[${permList.join(', ')}] permission/s from '
                        '${_formatReceiverForDisplay(recipientType)}?',
                      ),
                      // When revoking Public or Authenticated User access,
                      // solidpod will re-encrypt the file in place if it
                      // had previously been decrypted for sharing. Make
                      // that side-effect explicit so the user understands
                      // the action is not a pure permission change.
                      if (isPublicClass) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'If this file had been decrypted in your POD so '
                          'that this audience could read it, it will be '
                          're-encrypted automatically using the same '
                          'encryption key it had before.',
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  // The "Yes" button
                  TextButton(
                    onPressed: () async {
                      await revokePermission(
                        fileName: widget.resourceName,
                        isFile: widget.isFile,
                        permissionList: permList,
                        recipientIndOrGroupWebId: widget.receiverWebId,
                        ownerWebId: widget.ownerWebId,
                        granterWebId: widget.granterWebId,
                        recipientType: recipientType,
                        isExternalRes: widget.isExternalRes,
                      );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (ctx.mounted) {
                        showSnackBar(
                          context,
                          'Permission revoked successfully!',
                          ActionColors.success,
                        );
                      }
                      await widget.updatePermissionsFunction(
                        widget.resourceName,
                        isFile: widget.isFile,
                      );
                    },
                    child: const Text('Yes'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Close the dialog
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('No'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
