/// Show a modal dialog when a background Pod write fails.
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
