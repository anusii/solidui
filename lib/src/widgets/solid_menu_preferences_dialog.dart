/// SolidUI - Menu layout preferences dialogue for narrow-screen navigation.
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

import 'package:flutter/material.dart';

import 'package:solidui/src/widgets/solid_preferences_notifier.dart';

/// Dialogue for choosing whether navigation items appear in the bottom bar
/// or the hamburger drawer on narrow screens.

class SolidMenuPreferencesDialog extends StatefulWidget {
  /// Scaffold default when the user has not saved a preference yet.

  final bool scaffoldMenuInBottomBar;

  /// Optional callback when preferences are saved.

  final VoidCallback? onSave;

  const SolidMenuPreferencesDialog({
    super.key,
    this.scaffoldMenuInBottomBar = true,
    this.onSave,
  });

  /// Shows the menu layout preferences dialogue.

  static Future<void> show(
    BuildContext context, {
    bool scaffoldMenuInBottomBar = true,
    VoidCallback? onSave,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => SolidMenuPreferencesDialog(
        scaffoldMenuInBottomBar: scaffoldMenuInBottomBar,
        onSave: onSave,
      ),
    );
  }

  @override
  State<SolidMenuPreferencesDialog> createState() =>
      _SolidMenuPreferencesDialogState();
}

class _SolidMenuPreferencesDialogState
    extends State<SolidMenuPreferencesDialog> {
  late bool _menuInBottomBar;

  @override
  void initState() {
    super.initState();
    _menuInBottomBar = solidPreferencesNotifier.menuInBottomBarForScaffold(
      widget.scaffoldMenuInBottomBar,
    );
  }

  void _save() {
    solidPreferencesNotifier.setMenuInBottomBar(_menuInBottomBar);
    widget.onSave?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Menu Preferences'),
      content: Column(
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
            value: _menuInBottomBar,
            onChanged: (value) => setState(() => _menuInBottomBar = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
