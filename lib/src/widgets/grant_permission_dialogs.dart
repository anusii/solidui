/// Dialog helpers used by the grant permission form.
///
/// Copyright (C) 2024-2026, Software Innovation Institute, ANU.
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
/// Authors: Jess Moore, Anushka Vidanage, Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidpod/solidpod.dart'
    show RecipientType, WebIdCheckResult, WebIdCheckStatus;

import 'package:solidui/src/constants/ui_colors.dart' show ActionColors;
import 'package:solidui/src/utils/solid_alert.dart'
    show alertMaxWidthForCharsPerLine, defaultAlertMaxCharsPerLine;
import 'package:solidui/src/widgets/grant_permission_helpers_ui.dart'
    show podNotInitMsg;
import 'package:solidui/src/widgets/solid_invite_others.dart';
import 'package:solidui/src/widgets/solid_invite_others_models.dart';

/// Shows a dismissable error dialog whose message column is constrained to
/// approximately [maxCharsPerLine] characters wide.
///
/// The default ([defaultAlertMaxCharsPerLine], ~90 characters) matches the
/// width used by the shared [alert] helper so error dialogs raised from
/// the grant permission flow have the same reading width as alerts raised
/// elsewhere in the app. Callers can pass a smaller value for short,
/// narrow notices.

Future<void> showGrantPermissionErrorDialog(
  BuildContext context,
  String title,
  String message, {
  int maxCharsPerLine = defaultAlertMaxCharsPerLine,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: alertMaxWidthForCharsPerLine(maxCharsPerLine),
        ),
        child: Text(message),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// Handles the case where granting failed because one or more
/// recipients have not yet set up their POD. When an
/// [SolidInviteOthersConfig] is provided, the user is offered a
/// follow-up option to send the application's invitation directly.
/// Otherwise the original snackbar behaviour is kept so existing call
/// sites continue to work.

Future<void> handleNotInitialisedRecipients(
  BuildContext context,
  SolidInviteOthersConfig? inviteConfig,
) async {
  if (inviteConfig == null) {
    await showGrantPermissionErrorDialog(
      context,
      'Recipient POD not initialised',
      podNotInitMsg,
    );
    return;
  }

  if (!context.mounted) return;
  final shouldInvite = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Recipient has not set up a POD'),
      // Cap the message column at ~90 characters (within the 80–100
      // character convention used by the shared [alert] helper) so the
      // dialog reads comfortably on wide desktop windows rather than
      // stretching across the full window width.
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: alertMaxWidthForCharsPerLine(defaultAlertMaxCharsPerLine),
        ),
        child: const Text(
          'One or more of the WebIDs you entered have not yet '
          'initialised their POD. Ask them to log in once to set up '
          'their data vault — then you can grant access. Would you '
          'like to send them an invitation now?',
        ),
      ),
      actions: [
        MarkdownTooltip(
          message: '''

          **Not now**

          Dismiss this dialog without sending an invitation. You
          can grant access again once the recipient has logged
          into the app and set up their POD.

          ''',
          child: TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not now'),
          ),
        ),
        MarkdownTooltip(
          message: '''

          **Invite this user**

          Open the Invite Others dialog so you can send the
          recipient a link to the app, prompting them to set up
          their data vault.

          ''',
          child: TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Invite'),
          ),
        ),
      ],
    ),
  );

  if (!context.mounted) return;
  if (shouldInvite == true) {
    await InviteOthersDialog.show(context, config: inviteConfig);
  }
}

/// Confirm with the user before granting Public or Authenticated User
/// access to a resource.

Future<bool> confirmPublicSharingDecryption(
  BuildContext context,
  RecipientType recipientType,
) async {
  if (recipientType != RecipientType.public &&
      recipientType != RecipientType.authUser) {
    return true;
  }

  final isPublic = recipientType == RecipientType.public;
  final title = isPublic
      ? 'Make this file publicly readable?'
      : 'Share this file with all signed-in users?';
  final audienceSummary = isPublic
      ? 'Anyone on the internet — including people without a Data Vault — '
          'will be able to read this file simply by opening its URL in a '
          'web browser.'
      : 'Every person who is signed in to a Data Vault will be able to '
          'read this file by opening its URL while logged in.';
  final actionLabel = isPublic ? 'Share Publicly' : 'Share with Signed-In Users';

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: alertMaxWidthForCharsPerLine(defaultAlertMaxCharsPerLine),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(audienceSummary),
            const SizedBox(height: 12),
            const Text(
              'If this file is currently encrypted, it will be decrypted in '
              'your POD so that the new recipients can read its contents. '
              'The plaintext will be written back to the same URL, replacing '
              'the encrypted copy at rest.',
            ),
            const SizedBox(height: 12),
            const Text(
              'You can reverse this later by revoking the permission. When '
              'you do, the file will be re-encrypted automatically using '
              'the same encryption key it had before.',
            ),
          ],
        ),
      ),
      actions: [
        MarkdownTooltip(
          message: '''

          **Cancel**

          Close this dialog without changing the file. Your file remains
          encrypted and private, and no new recipients are granted access.

          ''',
          child: TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
        ),
        MarkdownTooltip(
          message: isPublic
              ? '''

          **Share Publicly**

          Decrypt this file in your POD and grant the Public class the
          selected permissions. After this, anyone with the file URL can
          read its contents.

          '''
              : '''

          **Share with Signed-In Users**

          Decrypt this file in your POD and grant the Authenticated User
          class the selected permissions. After this, any signed-in Data
          Vault user can read its contents.

          ''',
          child: TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: ActionColors.warning,
            ),
            child: Text(actionLabel),
          ),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}

/// Priority order used when several WebIDs in the group list fail. We
/// surface a single dialog and prefer the most actionable failure mode.

const List<WebIdCheckStatus> _groupReportPriority = [
  WebIdCheckStatus.invalidIpv4,
  WebIdCheckStatus.unreachable,
  WebIdCheckStatus.notProfile,
];

/// Pick the [WebIdCheckResult] to surface in a single dialog when more
/// than one WebID in the group has failed. Higher-priority statuses are
/// preferred (see [_groupReportPriority]); otherwise the first failure
/// in input order is returned.

(String, WebIdCheckResult) pickGroupFailureToReport(
  List<(String, WebIdCheckResult)> failures,
) {
  assert(failures.isNotEmpty);
  for (final status in _groupReportPriority) {
    for (final failure in failures) {
      if (failure.$2.status == status) return failure;
    }
  }
  return failures.first;
}
