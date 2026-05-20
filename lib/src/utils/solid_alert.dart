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
/// default Material body text size (~14 sp). Used to translate
/// [alert]'s `maxCharsPerLine` into an actual `maxWidth` constraint. A
/// slightly conservative value is chosen so that wide glyphs (e.g. `m`, `W`)
/// still tend to fit within the requested character budget.
const double _approxCharWidthLogicalPixels = 7.5;

/// Default character-per-line cap used by callers that want a sensible
/// reading width without picking a number themselves. ~90 characters keeps
/// long messages readable on wide desktop windows while still leaving room
/// for the dialog's chrome on a phone.
const int defaultDialogMaxCharsPerLine = 90;

/// Pop up an alert dialog with the given [msg].
///
/// [title] defaults to `'Notice'`. Pass [maxCharsPerLine] to cap the width
/// of the message column at roughly that many characters of body text,
/// preventing the dialog from stretching across the full width of a desktop
/// window when the message is long. Pass `null` (the default) to keep the
/// platform default sizing.
Future<void> alert(
  BuildContext context,
  String msg, {
  String title = 'Alert',
  int? maxCharsPerLine,
}) async {
  await showDialog(
    context: context,
    builder: (context) {
      final messageText = Text(msg);
      final content = maxCharsPerLine == null
          ? messageText
          : ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxCharsPerLine * _approxCharWidthLogicalPixels,
              ),
              child: messageText,
            );
      return AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
