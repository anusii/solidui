/// Ask whether to save, discard, or keep editing unsaved changes.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.
//
// Time-stamp: <Saturday 2026-08-08 10:00:00 +1000 Graham Williams>
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

/// What the user chose when told they have unsaved changes.

enum UnsavedChangesAction {
  /// Save the edits, then continue with whatever prompted the question.

  save,

  /// Throw the edits away and continue.

  discard,

  /// Abandon the close/navigation and stay in the editor.

  keepEditing,
}

/// Asks whether to save, discard, or keep editing.
///
/// Used both when leaving an editor and when the desktop window is closed (see
/// [SolidWindowCloseGuard]), so the wording stays the same either way.
///
/// Dismissing the dialog counts as [UnsavedChangesAction.keepEditing] — the
/// safe choice, since it neither writes nor destroys anything.
///
/// The caller decides what to do with the answer. On
/// [UnsavedChangesAction.save] the caller MUST await its save before letting a
/// window close proceed, or the write is killed mid-flight.

Future<UnsavedChangesAction> showUnsavedChangesDialog(
  BuildContext context,
) async {
  final action = await showDialog<UnsavedChangesAction>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Unsaved changes'),
      content: const Text(
        'You have unsaved changes. Would you like to save them?',
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(UnsavedChangesAction.keepEditing),
          child: const Text('Keep editing'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(UnsavedChangesAction.discard),
          child: const Text('Discard'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(UnsavedChangesAction.save),
          child: const Text('Save'),
        ),
      ],
    ),
  );

  return action ?? UnsavedChangesAction.keepEditing;
}
