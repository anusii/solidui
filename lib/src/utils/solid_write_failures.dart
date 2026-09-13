/// Surface failures from Pod writes that nothing is awaiting.
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
