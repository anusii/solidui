/// Show a modal dialog when a background Pod write fails.
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

import 'package:solidui/src/utils/solid_alert.dart';
import 'package:solidui/src/utils/solid_write_failures.dart';

/// Watches [SolidWriteFailures] and raises a modal dialog for each failure.
///
/// Mount once, inside the app's `MaterialApp` so a Navigator is available, and
/// around the part of the tree that outlives individual screens:
///
/// ```dart
/// home: SolidLogin(
///   child: const SolidWriteFailureListener(child: AppScaffold()),
/// ),
/// ```
///
/// A dialog is used rather than a SnackBar because a lost save needs
/// acknowledging — a bar that fades away is how the failure got missed in the
/// first place.

class SolidWriteFailureListener extends StatefulWidget {
  const SolidWriteFailureListener({
    super.key,
    required this.child,
    this.title = 'Save failed',
  });

  final Widget child;

  /// Dialog title. Override where "save" is the wrong word for the app.

  final String title;

  @override
  State<SolidWriteFailureListener> createState() =>
      _SolidWriteFailureListenerState();
}

class _SolidWriteFailureListenerState extends State<SolidWriteFailureListener> {
  /// Guards against stacking dialogs when writes fail in quick succession.

  bool _showing = false;

  @override
  void initState() {
    super.initState();
    SolidWriteFailures.latest.addListener(_onFailure);
    // A failure may already be waiting if one arrived before this mounted.
    if (SolidWriteFailures.latest.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onFailure());
    }
  }

  @override
  void dispose() {
    SolidWriteFailures.latest.removeListener(_onFailure);
    super.dispose();
  }

  Future<void> _onFailure() async {
    if (_showing) return;
    _showing = true;

    // Loop so a failure arriving while the dialog is up is still shown, rather
    // than being lost behind the one behind it.
    try {
      var message = SolidWriteFailures.latest.value;
      while (message != null && mounted) {
        SolidWriteFailures.clear();
        await alert(context, message, widget.title);
        if (!mounted) return;
        message = SolidWriteFailures.latest.value;
      }
    } finally {
      _showing = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
