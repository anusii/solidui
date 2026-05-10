/// Robust loading-dialog helper for long-running operations.
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
/// Authors: Tony Chen

library;

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

/// A controller that owns the lifetime of a modal "loading" dialog and
/// guarantees it will be torn down once [close] is called.
///
/// The classic anti-pattern in long-running operations is:
///
/// ```dart
/// showDialog(context: outerContext, barrierDismissible: false, ...);
/// await someLongRunningWork();
/// if (!outerContext.mounted) return;
/// Navigator.of(outerContext).pop();
/// ```
///
/// If the originating widget is unmounted while the work is in flight (for
/// example because the surrounding list rebuilds, navigation moves
/// elsewhere, or the user logs out), the early `return` skips the
/// [Navigator.pop] and the loading dialog is stranded on the screen with
/// its barrier producing an apparently "black" backdrop.
///
/// This controller solves that by capturing the dialog's *own*
/// [BuildContext] from the dialog `builder`, so it can pop reliably via
/// the dialog's route — no longer dependent on the outer context.
///
/// Typical use:
///
/// ```dart
/// final loading = LoadingDialogController.show(
///   context: context,
///   message: 'Uploading...',
/// );
/// try {
///   await someLongRunningWork();
/// } finally {
///   loading.close();
/// }
/// ```

class LoadingDialogController {
  LoadingDialogController._();

  BuildContext? _dialogContext;
  bool _closed = false;

  /// Whether [close] has already been invoked. Useful for callers that
  /// branch on whether the dialog is still on screen.

  bool get isClosed => _closed;

  /// Show a modal, non-dismissible loading dialog and return a controller
  /// that can [close] it reliably.
  ///
  /// [context] is the originating context used to open the dialog; once
  /// the dialog is up, the controller stops relying on it. Pass an
  /// optional [message] to customise the body text or [child] to supply a
  /// completely custom dialog body.
  ///
  /// Returns a controller whose [close] method is safe to call any number
  /// of times — subsequent calls are no-ops.

  static LoadingDialogController show({
    required BuildContext context,
    String message = 'Please wait...',
    String? title,
    Widget? child,
  }) {
    final controller = LoadingDialogController._();

    // Drive the dialog ourselves rather than awaiting [showDialog], so the
    // caller can continue with its own work and tear the dialog down via
    // [close] when ready.

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          controller._dialogContext = dialogContext;
          return AlertDialog(
            title: title != null ? Text(title) : null,
            content: child ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 16),
                    Flexible(child: Text(message)),
                  ],
                ),
          );
        },
      ),
    );

    return controller;
  }

  /// Tear down the dialog. Safe to call multiple times and from any
  /// async continuation; later calls are silently ignored.
  ///
  /// Pops via the dialog's own [BuildContext] (captured at build time),
  /// using the root navigator so that nested dialogs cannot accidentally
  /// route the pop to the wrong target.

  void close() {
    if (_closed) return;
    _closed = true;
    final dialogContext = _dialogContext;
    if (dialogContext != null && dialogContext.mounted) {
      Navigator.of(dialogContext, rootNavigator: true).pop();
    }
  }
}
