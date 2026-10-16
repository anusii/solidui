/// Solid Pod Refresh — reload an app's data from the Pod and say what changed.
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
/// Authors: Graham Williams

library;

import 'package:flutter/material.dart';

/// Reload an app's data from its Pod, then say in an OK dialog whether
/// anything had changed.
///
/// [onRefresh] reloads the app's in-memory data from the Pod and returns true
/// when the data changed (the Pod had been updated elsewhere, by another
/// device or another app sharing the data), false when it was already
/// current. Comparing a content signature before and after the reload is the
/// usual way to tell. A throw is reported as a failed refresh.
///
/// This is what the profile menu's Refresh from Pod entry runs when an app
/// passes `SolidAppBarConfig.onRefreshFromPod`. Public so an app can also
/// offer it elsewhere, such as from a pull-to-refresh.
///
/// 20261017 gjw Moved here from RadioPod, where it was an AppBar button
/// copied app to app. A refresh from the Pod is part of the Pod session, not
/// of any one screen, so it sits with Change Pod Password and Backup.

Future<void> handleSolidPodRefresh({
  required BuildContext context,
  required Future<bool> Function() onRefresh,
}) async {
  bool changed;
  try {
    changed = await onRefresh();
  } catch (e) {
    if (!context.mounted) return;
    await _showRefreshDialog(
      context,
      title: 'Refresh failed',
      message: 'Could not refresh from your Pod.\n\n$e',
      icon: Icons.error_outline,
      iconColor: Colors.red,
    );

    return;
  }

  if (!context.mounted) return;

  await _showRefreshDialog(
    context,
    title: changed ? 'Data updated' : 'Already up to date',
    message: changed
        ? 'Your data has been updated from changes made in your Pod '
            'outside this app.'
        : 'Your data is already up to date with your Pod. No changes were '
            'found.',
    icon: changed ? Icons.cloud_download_outlined : Icons.check_circle_outline,
    iconColor: changed ? Colors.green : Colors.blue,
  );
}

Future<void> _showRefreshDialog(
  BuildContext context, {
  required String title,
  required String message,
  required IconData icon,
  required Color iconColor,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
