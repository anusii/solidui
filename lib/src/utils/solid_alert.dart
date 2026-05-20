/// Show an Alert dialog
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
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
/// Authors: Dawei Chen

library;

import 'package:flutter/material.dart';

/// Approximate average width, in logical pixels, of one character at the
/// default Material body text size (~14 sp). Used to translate a
/// "characters per line" budget into an actual `maxWidth` constraint for
/// alert dialogs. Slightly conservative so wider glyphs (e.g. `m`, `W`)
/// still tend to fit within the requested character budget.

const double _approxCharWidthLogicalPixels = 7.0;

/// Default character-per-line cap applied to alert dialogs raised by
/// [alert]. ~90 characters keeps long error messages readable on wide
/// desktop windows without forcing short messages to look awkwardly narrow
/// on phones; it also matches the 80–100 character convention familiar
/// from prose and source-code line lengths.

const int defaultAlertMaxCharsPerLine = 90;

/// Convert a "characters per line" budget into a logical-pixel `maxWidth`
/// suitable for use with [BoxConstraints]. Shared by [alert] and any
/// custom alert dialogs that want a consistent reading width.

double alertMaxWidthForCharsPerLine(int maxCharsPerLine) =>
    maxCharsPerLine * _approxCharWidthLogicalPixels;

/// Pop up a dismissable alert dialog with the given [msg].
///
/// [title] defaults to `'Alert'`. The message column is capped at
/// approximately [defaultAlertMaxCharsPerLine] characters wide so that long
/// messages do not stretch across the full width of a desktop window.
/// Short messages are unaffected — the cap only takes effect when the
/// natural width of the text exceeds it.

Future<void> alert(
  BuildContext context,
  String msg, [
  String title = 'Alert',
]) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: alertMaxWidthForCharsPerLine(defaultAlertMaxCharsPerLine),
        ),
        child: Text(msg),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
