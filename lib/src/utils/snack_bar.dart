/// A utility function for displaying snack bars.
///
/// Copyright (C) 2024-2025, Software Innovation Institute, ANU.
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
/// Authors: Dawei Chen, Anushka Vidanage, Graham Williams

library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

import 'package:solidui/src/constants/ui_colors.dart';

/// How long a SnackBar stays on screen.
///
/// One standard time for every message, matching Flutter's own default. Do
/// NOT extend it for an Undo action — the button rides along for the standard
/// time and then the bar gets out of the way.

const solidSnackBarDuration = Duration(seconds: 4);

/// Understated SnackBars: floating, rounded and quiet.
///
/// Apps set `snackBarTheme: solidSnackBarTheme` in their ThemeData so every
/// SnackBar in the suite shares the same shape. This is the neutral fallback
/// for a SnackBar built directly; [showPositiveSnackBar] overrides the
/// background with a soft green bar.

const solidSnackBarTheme = SnackBarThemeData(
  backgroundColor: SnackBarColors.surface,
  contentTextStyle: TextStyle(color: SnackBarColors.neutral, fontSize: 14),
  behavior: SnackBarBehavior.floating,
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  ),
);

/// Displays a snack bar with a custom message.
///
/// A customised background colour and duration can be used.

void showSnackBar(
  BuildContext context,
  String msg,
  Color bgColor, {
  Duration duration = const Duration(seconds: 4),
}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: bgColor,
      duration: duration,
    ),
  );
}

/// Confirm [message] with a soft green SnackBar that auto-dismisses.
///
/// Pass [actionLabel] and [onAction] together to add a button, e.g. Restore.
/// Match the label to the operation the user would name — Restore to bring
/// something back, Undo only to reverse the action just taken.
///
/// There is no negative variant yet, on purpose — nothing needs one, and we
/// don't carry unused code. To add one when it is needed, mirror this with a
/// `SnackBarColors.negative` bar colour and `Icons.info_outline`, and keep it
/// for outcomes worth noticing but not worth interrupting for. Real errors
/// still belong in a modal dialog, which forces acknowledgement.

void showPositiveSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = solidSnackBarDuration,
}) {
  if (!context.mounted) return;
  unawaited(
    _show(
      context,
      _positiveSnackBar(
        message,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      ),
      duration,
    ),
  );
}

/// Show [bar] and make sure it goes away again.
///
/// A SnackBar carrying an action is not always timed out by Flutter itself:
/// when accessibility features are active it deliberately leaves an
/// actionable SnackBar on screen until the action or the close button is
/// tapped, which left todopod's Undo bar sitting there indefinitely. An
/// action AND auto-dismiss are both wanted, so the bar is hidden here once
/// [duration] has passed. The grace period means we only step in if Flutter's
/// own timer did not, and the `open` flag means we never hide a later,
/// unrelated SnackBar.

Future<void> _show(
  BuildContext context,
  SnackBar bar,
  Duration duration,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final controller = messenger.showSnackBar(bar);

  var open = true;
  unawaited(controller.closed.then((_) => open = false));

  await Future<void>.delayed(duration + const Duration(milliseconds: 250));
  if (open) messenger.hideCurrentSnackBar();
}

/// The bar itself.
///
/// Text, icon and action are near-black for contrast against the light pastel
/// bar. The floating behaviour, elevation and shape come from
/// [solidSnackBarTheme], whose neutral dark background is overridden here.

SnackBar _positiveSnackBar(
  String message, {
  required Duration duration,
  String? actionLabel,
  VoidCallback? onAction,
}) =>
    SnackBar(
      duration: duration,
      backgroundColor: SnackBarColors.positive,
      content: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: SnackBarColors.ink,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: SnackBarColors.ink, fontSize: 14),
            ),
          ),
        ],
      ),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              textColor: SnackBarColors.ink,
              onPressed: onAction,
            )
          : null,
    );
