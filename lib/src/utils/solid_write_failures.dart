/// Surface failures from Pod writes that nothing is awaiting.
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

import 'package:flutter/foundation.dart';

/// Collects failures from Pod writes started by a synchronous UI callback,
/// where there is no caller to hand the error back to.
///
/// A star toggle or a drag-reorder fires its save and returns immediately. If
/// that save fails the user is told nothing and believes the change is stored,
/// which is worse than an error: the app looks like it worked.
///
/// Wrap such a write with [watch] and mount a `SolidWriteFailureListener` once
/// near the top of the app to show them. Writes that ARE awaited need none of
/// this — their caller already has the error and reports it.

class SolidWriteFailures {
  SolidWriteFailures._();

  /// The failure waiting to be shown, or null when there is nothing pending.
  ///
  /// A listener mounted inside the app's `MaterialApp` watches this and raises
  /// a modal dialog, then calls [clear].

  static final ValueNotifier<String?> latest = ValueNotifier<String?>(null);

  /// Records [message] as a failure needing the user's attention.

  static void report(String message) => latest.value = message;

  /// Marks the pending failure as shown.

  static void clear() => latest.value = null;

  /// Watches a Pod write that nothing awaits, so a failure is reported rather
  /// than silently dropped.
  ///
  /// Handles both conventions these apps use: the write may THROW, or it may
  /// complete with a non-null `String` describing what went wrong. [during]
  /// names the operation for the message, e.g. `'saving tasks'`.
  ///
  /// The error is deliberately not rethrown — it has been dealt with by being
  /// reported, and nothing is waiting to catch it.

  static void watch(Future<Object?> write, {String? during}) {
    write.then((result) {
      if (result is String && result.isNotEmpty) _record(during, result);
    }).catchError((Object error) {
      _record(during, error.toString());
    });
  }

  /// Reports [error] when it describes a real failure, for a write the caller
  /// has already awaited and whose message it would otherwise discard.
  ///
  /// Use this where the write MUST stay awaited and so cannot be handed to
  /// [watch] — most importantly an editor's own save, which the window-close
  /// guard relies on completing before the window is destroyed:
  ///
  /// ```dart
  /// onSave: (updated) async {
  ///   provider.updateBill(updated);
  ///   SolidWriteFailures.reportIfFailed(
  ///     await provider.saveToPod(),
  ///     during: 'saving the bill',
  ///   );
  /// },
  /// ```

  static void reportIfFailed(String? error, {String? during}) {
    if (error == null || error.isEmpty) return;
    _record(during, error);
  }

  static void _record(String? during, String detail) =>
      report(during == null ? detail : 'Failed $during.\n\n$detail');
}
