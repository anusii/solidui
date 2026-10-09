/// The close button on the login page.
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
/// Authors: Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';

/// Close the login page and carry on into the app without logging in.
///
/// The way out of the login page for an app that runs without a Pod but does
/// not offer CONTINUE. Without it, someone who opened the login page from
/// within the app, or arrived there on logging out, could not get back into
/// the app without logging in.

class SolidLoginCloseButton extends StatelessWidget {
  /// Called when the button is tapped.

  final VoidCallback onPressed;

  const SolidLoginCloseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => MarkdownTooltip(
        message: '''

        **Close**

        Close the login page and use the app without logging in. Your data
        stays on this device. You can log in to your Solid Pod at any time
        from within the app.

        ''',
        child: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onPressed,
        ),
      );
}
