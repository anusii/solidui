/// Track in-flight Pod writes so the window does not close over the top of one.
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

import 'dart:async';

/// Counts Pod writes that have started but not finished, so that closing the
/// window can wait for them.
///
/// Most writes are started from a synchronous UI callback and never awaited by
/// anyone — a star toggle, a drag-reorder, marking a task done. That is fine
/// while the app keeps running, but the write is killed if the window is
/// destroyed first, and the change is silently lost. Awaiting at the call site
/// does not help: an `onPressed` future has no one holding it either.
///
/// Wrap the app's Pod write at its choke point, usually the one service method
/// every save funnels through:
///
/// ```dart
/// static Future<String?> save(List<Item> items) =>
///     SolidPendingWrites.track(_save(items));
/// ```
///
/// [SolidWindowCloseGuard] then awaits [settle] before destroying the window,
/// so nothing needs to change at the call sites themselves.

class SolidPendingWrites {
  SolidPendingWrites._();

  static int _inFlight = 0;

  static final List<Completer<void>> _waiters = [];

  /// Whether any tracked write is still running.

  static bool get hasPending => _inFlight > 0;

  /// Registers [write] as in flight and returns it unchanged, so this can wrap
  /// a call without altering its result or its errors.

  static Future<T> track<T>(Future<T> write) {
    _inFlight++;

    return write.whenComplete(() {
      _inFlight--;
      if (_inFlight > 0) return;
      // Release everyone waiting on quiescence. Copy first: a waiter may start
      // another write as it resumes.
      final waiting = List<Completer<void>>.from(_waiters);
      _waiters.clear();
      for (final waiter in waiting) {
        if (!waiter.isCompleted) waiter.complete();
      }
    });
  }

  /// Waits until no tracked write is in flight.
  ///
  /// Gives up after [timeout] and returns anyway: a wedged network call must
  /// not leave the user unable to close the window. Returns whether everything
  /// actually finished, so a caller can report a forced close.

  static Future<bool> settle({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final deadline = Stopwatch()..start();

    while (_inFlight > 0) {
      if (deadline.elapsed >= timeout) return false;

      final waiter = Completer<void>();
      _waiters.add(waiter);
      try {
        await waiter.future.timeout(timeout - deadline.elapsed);
      } on TimeoutException {
        _waiters.remove(waiter);

        return false;
      }
    }

    return true;
  }
}
