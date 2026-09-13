/// The Menu Layout section of the settings dialogue.
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

/// Choose whether navigation items appear in the bottom bar or the hamburger
/// drawer on narrow screens.
///
/// The value is held by the enclosing dialogue, which saves it to the
/// preferences notifier.

class SolidSettingsMenuSection extends StatelessWidget {
  /// Whether the menu currently sits in the bottom bar.

  final bool menuInBottomBar;

  /// Called as the user flips the switch.

  final ValueChanged<bool> onChanged;

  const SolidSettingsMenuSection({
    super.key,
    required this.menuInBottomBar,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'On narrow screens, choose where the main navigation items '
            'appear.',
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show menu in bottom bar'),
            subtitle: const Text(
              'When on, page buttons sit along the bottom edge. '
              'When off, page buttons sit in the menu drawer. '
              'The login and security key remain in the menu drawer.',
            ),
            value: menuInBottomBar,
            onChanged: onChanged,
          ),
        ],
      );
}
