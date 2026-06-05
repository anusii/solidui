/// Post-grant notification broadcast for the grant-permission flow.
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

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart'
    show RecipientNotReadyException, RecipientType, sendNotification;

import 'package:solidui/src/constants/ui_colors.dart' show ActionColors;

/// Signature for the snack-bar reporter used to surface notification
/// delivery outcomes back to the caller's UI.

typedef NotifySnackBar = void Function(
  String message,
  Color backgroundColor, {
  Duration duration,
});

/// Send a "resource shared" notification to each recipient WebID and
/// report delivery problems through [showSnack].
///
/// Only the individual and group recipient types carry concrete WebIDs
/// worth notifying; public and authenticated-user shares are ignored.
/// Recipients whose Pod is not yet upgraded surface a single grouped
/// warning, while any other delivery error is reported separately so
/// the user does not lose visibility of a misconfigured recipient.

Future<void> notifyShareRecipients({
  required RecipientType recipientType,
  required List<dynamic> recipientWebIds,
  required List<String> resourceNames,
  required String? resourceDisplayName,
  required String granterWebId,
  required String ownerWebId,
  required List<String> permissionList,
  required NotifySnackBar showSnack,
}) async {
  if (recipientType != RecipientType.individual &&
      recipientType != RecipientType.group) {
    return;
  }

  final primaryResource = resourceNames.first;
  final displayName = resourceDisplayName ?? primaryResource;
  final permissions = permissionList.join(', ');

  final notReadyRecipients = <String>[];
  final otherFailures = <({String recipient, String error})>[];

  for (final recipientWebId in recipientWebIds) {
    try {
      await sendNotification(
        recipientWebId: recipientWebId as String,
        title: 'A resource has been shared with you: $displayName',
        content: jsonEncode({
          'fileUrl': primaryResource,
          'fileUrls': resourceNames,
          'fileTitle': displayName,
          'sharedBy': granterWebId,
          'owner': ownerWebId,
          'permissions': permissions,
        }),
        priority: 1,
      );
    } on RecipientNotReadyException catch (e) {
      debugPrint(
        '[GrantPermissionForm] '
        'Recipient not ready for $recipientWebId: $e',
      );
      notReadyRecipients.add(recipientWebId as String);
    } on Object catch (e) {
      debugPrint(
        '[GrantPermissionForm] '
        'Failed to send notification to $recipientWebId: $e',
      );
      otherFailures.add(
        (recipient: recipientWebId as String, error: '$e'),
      );
    }
  }

  if (notReadyRecipients.isNotEmpty) {
    final names = notReadyRecipients.join(', ');
    showSnack(
      'Permission granted, but could not notify: $names. '
      'The recipient(s) need to log in once to upgrade '
      'their Pod setup (the Update Wizard runs on login).',
      ActionColors.warning,
      duration: const Duration(seconds: 8),
    );
  }
  if (otherFailures.isNotEmpty) {
    final summary =
        otherFailures.map((f) => '${f.recipient} (${f.error})').join('; ');
    showSnack(
      'Permission granted, but notification delivery failed: $summary',
      ActionColors.warning,
      duration: const Duration(seconds: 8),
    );
  }
}
