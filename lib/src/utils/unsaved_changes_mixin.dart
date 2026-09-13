/// Wire an editor's unsaved changes into the desktop window-close prompt.
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
