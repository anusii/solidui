/// Track in-flight Pod writes so the window does not close over the top of one.
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
