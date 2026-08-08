/// Ask whether to save, discard, or keep editing unsaved changes.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Saturday 2026-08-08 10:00:00 +1000 Graham Williams>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
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
