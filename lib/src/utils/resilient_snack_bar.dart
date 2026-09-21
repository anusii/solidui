/// A [SnackBar] reporter that survives a momentarily-unregistered Scaffold.
///
/// Copyright (C) 2024-2026, Software Innovation Institute, ANU.
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
/// Authors: Jess Moore, Anushka Vidanage

library;

import 'package:flutter/material.dart';

/// Signature for the snack-bar reporter used to surface an async action's
/// outcome back to the caller's UI.

typedef NotifySnackBar = void Function(
  String message,
  Color backgroundColor, {
  Duration duration,
});

/// Build a resilient [NotifySnackBar] bound to [messenger].
///
/// Showing a SnackBar requires a Scaffold registered with the messenger.
/// Depending on how the host embeds the form, and on the exact moment the
/// dialog is dismissed, the messenger can momentarily have no Scaffold,
/// which throws the "_scaffolds.isNotEmpty" assertion. A confirmation toast
/// is non-critical (the underlying action has already succeeded or failed
/// independently of this call), so the call is guarded and retried once on
/// the next frame rather than ever letting it crash the app.
///
/// Capture the closure returned here *before* any `await` in the caller, so
/// it keeps working even if the calling widget is unmounted mid-flow (e.g. a
/// purchase or permission-grant result that resolves after the dialog that
/// started it has already closed).

NotifySnackBar makeResilientSnackBar(ScaffoldMessengerState messenger) => (
      String message,
      Color backgroundColor, {
      Duration duration = const Duration(seconds: 4),
    }) {
      SnackBar build() => SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            duration: duration,
          );
      try {
        messenger.showSnackBar(build());
      } on Object catch (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            messenger.showSnackBar(build());
          } on Object catch (e) {
            debugPrint('Could not show snackbar "$message": $e');
          }
        });
      }
    };
