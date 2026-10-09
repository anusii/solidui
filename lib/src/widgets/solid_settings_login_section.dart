/// The Login Page section of the settings dialogue.
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

/// Choose whether the login page is shown when the app starts, or the app
/// goes straight in as though CONTINUE had been tapped.
///
/// The value is held by the enclosing dialogue, which saves it through
/// `SolidSkipLogin`. The dialogue shows this section only for an app that
/// can be used without a Pod.

class SolidSettingsLoginSection extends StatelessWidget {
  /// Whether the login page is shown at start-up.

  final bool showLoginPage;

  /// Called as the user flips the switch.

  final ValueChanged<bool> onChanged;

  const SolidSettingsLoginSection({
    super.key,
    required this.showLoginPage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The app works without a Solid Pod. You can log in to your Pod '
            'at any time from within the app.',
          ),
          const SizedBox(height: 16),
          MarkdownTooltip(
            message: '''

            **Show the login page**

            When on, the app opens on its login page, from where you can log
            in to your Solid Pod or carry on without one. When off, the app
            opens straight into its own pages, as though you had chosen to
            continue. You are still logged in automatically if you chose to
            stay signed in.

            ''',
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show the login page on start-up'),
              value: showLoginPage,
              onChanged: onChanged,
            ),
          ),
        ],
      );
}
