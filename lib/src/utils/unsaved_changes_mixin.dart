/// Wire an editor's unsaved changes into the desktop window-close prompt.
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

import 'package:flutter/widgets.dart';

import 'package:solidui/src/utils/solid_window_close_guard.dart';
import 'package:solidui/src/utils/solid_write_failures.dart';
import 'package:solidui/src/utils/unsaved_changes_dialog.dart';

/// Adds the desktop window-close save prompt to an editor [State].
///
/// Registration with [SolidWindowCloseGuard] is handled here, so an editor
/// only has to say what "unsaved" means and how to save:
///
/// ```dart
/// class _EntryEditState extends State<EntryEdit> with UnsavedChangesMixin {
///   @override
///   bool get hasUnsavedChanges => _hasChanges;
///
///   @override
///   Future<bool> saveUnsavedChanges() => _save();
/// }
/// ```
///
/// The editor keeps its own `initState`/`dispose` as normal — this mixin hooks
/// them through `super`, so the only requirement is the usual
/// `super.initState()` / `super.dispose()` calls.

mixin UnsavedChangesMixin<T extends StatefulWidget> on State<T> {
  /// Whether the user has edits that would be lost right now.

  bool get hasUnsavedChanges;

  /// Persists the current edits.
  ///
  /// Returns whether the edits actually reached storage. Returning false, or
  /// throwing, aborts the close and leaves the editor open — otherwise a
  /// failed write loses the work exactly as it would have without any prompt,
  /// and the error dialog never gets a frame to appear in.
  ///
  /// MUST NOT complete until the write is done — the window is destroyed as
  /// soon as [resolveUnsavedOnWindowClose] returns true, so an unawaited write
  /// would be killed mid-flight.
  ///
  /// MUST NOT pop the Navigator: on the window-close path the whole window is
  /// going away, not just this route.

  Future<bool> saveUnsavedChanges();

  /// Whether the edits are complete enough to save, e.g. a required title is
  /// filled in.
  ///
  /// When this is false, choosing Save aborts the close and leaves the editor
  /// open so the user can complete it, rather than closing and discarding
  /// work they just asked to keep.

  bool get canSaveUnsavedChanges => true;

  @override
  void initState() {
    super.initState();
    SolidWindowCloseGuard.register(resolveUnsavedOnWindowClose);
  }

  @override
  void dispose() {
    SolidWindowCloseGuard.unregister(resolveUnsavedOnWindowClose);
    super.dispose();
  }

  /// Prompts about unsaved edits when the window is closing, and reports
  /// whether the close may proceed. Never pops the Navigator.

  Future<bool> resolveUnsavedOnWindowClose() async {
    if (!hasUnsavedChanges) return true;

    final action = await showUnsavedChangesDialog(context);
    if (!mounted) return false;

    switch (action) {
      case UnsavedChangesAction.save:
        // The user asked to keep this work, so when it cannot be saved yet
        // abort the close and leave the editor open rather than closing and
        // losing it. Discard is still there for closing regardless.
        if (!canSaveUnsavedChanges) return false;
        // Awaited, and its answer respected: the window is destroyed the
        // moment this returns true, so a write that failed must keep the
        // editor open rather than close over the top of the work.
        try {
          return await saveUnsavedChanges();
        } catch (e) {
          SolidWriteFailures.report('Failed saving.\n\n$e');

          return false;
        }
      case UnsavedChangesAction.discard:
        return true;
      case UnsavedChangesAction.keepEditing:
        return false;
    }
  }
}
