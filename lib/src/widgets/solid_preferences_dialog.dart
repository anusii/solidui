/// Preferences dialogue for configuring appearance and AppBar button settings.
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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidui/src/widgets/solid_preferences_button_order.dart';
import 'package:solidui/src/widgets/solid_preferences_models.dart';
import 'package:solidui/src/widgets/solid_preferences_notifier.dart';

/// A dialogue widget for configuring user preferences including
/// AppBar button ordering.

class SolidPreferencesDialog extends StatefulWidget {
  /// Optional callback when preferences are saved.

  final VoidCallback? onSave;

  /// Optional title for the dialogue.

  final String title;

  const SolidPreferencesDialog({
    super.key,
    this.onSave,
    this.title = 'AppBar Preferences',
  });

  /// Shows the preferences dialogue.

  static Future<void> show(BuildContext context, {VoidCallback? onSave}) {
    return showDialog<void>(
      context: context,
      builder: (context) => SolidPreferencesDialog(onSave: onSave),
    );
  }

  @override
  State<SolidPreferencesDialog> createState() => _SolidPreferencesDialogState();
}

class _SolidPreferencesDialogState extends State<SolidPreferencesDialog> {
  late List<SolidAppBarActionItem> _appBarActions;

  @override
  void initState() {
    super.initState();
    _loadCurrentPreferences();
  }

  void _loadCurrentPreferences() {
    final config = solidPreferencesNotifier.config;
    _appBarActions = List.from(config.appBarActions);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _appBarActions.removeAt(oldIndex);
      _appBarActions.insert(newIndex, item);

      // Update order values.

      for (int i = 0; i < _appBarActions.length; i++) {
        _appBarActions[i] = _appBarActions[i].copyWith(order: i);
      }
    });
  }

  void _onOverflowChanged(int index, bool? value) {
    if (value == null) return;
    setState(() {
      _appBarActions[index] = _appBarActions[index].copyWith(
        showInOverflow: value,
      );
    });
  }

  void _onVisibilityChanged(int index, bool? value) {
    if (value == null) return;
    setState(() {
      _appBarActions[index] = _appBarActions[index].copyWith(isVisible: value);
    });
  }

  void _savePreferences() {
    final newConfig = SolidPreferencesConfig(appBarActions: _appBarActions);

    solidPreferencesNotifier.setConfig(newConfig);
    widget.onSave?.call();
    Navigator.of(context).pop();
  }

  void _resetToDefault() {
    setState(() {
      // Reset all actions to default values: visible, not in overflow,
      // and sorted by their default order based on button type.

      final resetActions = <SolidAppBarActionItem>[];
      for (final action in _appBarActions) {
        resetActions.add(
          action.copyWith(
            showInOverflow: false,
            isVisible: true,
            order: _getDefaultOrderForAction(action.id),
          ),
        );
      }

      // Sort by the default order.

      resetActions.sort((a, b) => a.order.compareTo(b.order));

      // Reassign sequential order values after sorting.

      for (int i = 0; i < resetActions.length; i++) {
        resetActions[i] = resetActions[i].copyWith(order: i);
      }

      _appBarActions = resetActions;
    });
  }

  /// Returns the default order index for an action based on its ID.
  /// This mirrors the initialIndex values in SolidAppBarActionsManager.

  int _getDefaultOrderForAction(String actionId) {
    // Theme toggle: 0.

    if (actionId == SolidAppBarActionIds.themeToggle) return 0;

    // Custom actions: 100+.

    if (actionId.startsWith('action_')) {
      final index = int.tryParse(actionId.replaceFirst('action_', '')) ?? 0;
      return 100 + index;
    }

    // Logout: 300.

    if (actionId == SolidAppBarActionIds.logout) return 300;

    // About: 900.

    if (actionId == SolidAppBarActionIds.about) return 900;

    // Other items (overflow items): 200+.

    return 200;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.tune),
          const SizedBox(width: 8),
          Flexible(child: Text(widget.title)),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Button Order Section.
              _buildSectionHeader(theme, 'Button Order'),
              const SizedBox(height: 8),
              SolidPreferencesButtonOrderSection(
                appBarActions: _appBarActions,
                onReorder: _onReorder,
                onVisibilityChanged: _onVisibilityChanged,
                onOverflowChanged: _onOverflowChanged,
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          runSpacing: 8,
          children: [
            TextButton(
              onPressed: _resetToDefault,
              child: const Text('Default'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _savePreferences,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
