/// Settings dialogue, a section for each group of preferences.
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
/// Authors: Tony Chen, Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:solidui/src/utils/is_desktop.dart';
import 'package:solidui/src/widgets/solid_preferences_appbar_defaults.dart';
import 'package:solidui/src/widgets/solid_preferences_button_order.dart';
import 'package:solidui/src/widgets/solid_preferences_models.dart';
import 'package:solidui/src/widgets/solid_preferences_notifier.dart';
import 'package:solidui/src/widgets/solid_settings_menu_section.dart';
import 'package:solidui/src/widgets/solid_settings_window_size_section.dart';

/// A dialogue of user settings, one section for each group of them: the
/// AppBar button order, where the menu sits on a narrow screen, and the size
/// of the desktop window.
///
/// A section appears only where it applies, so an app that has turned off the
/// menu preferences, or one running on the web where there is no window to
/// size, simply shows fewer sections. Adding a section here adds it to every
/// solidui app.

class SolidPreferencesDialog extends StatefulWidget {
  /// Optional callback when preferences are saved.

  final VoidCallback? onSave;

  /// Optional title for the dialogue.

  final String title;

  /// Whether to offer the AppBar button order section.

  final bool showAppBarSection;

  /// Whether to offer the menu layout section.

  final bool showMenuSection;

  /// Scaffold default for the menu layout, used until the user has saved a
  /// preference of their own.

  final bool scaffoldMenuInBottomBar;

  const SolidPreferencesDialog({
    super.key,
    this.onSave,
    this.title = 'Settings',
    this.showAppBarSection = true,
    this.showMenuSection = true,
    this.scaffoldMenuInBottomBar = true,
  });

  /// Shows the settings dialogue.

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onSave,
    bool showAppBarSection = true,
    bool showMenuSection = true,
    bool scaffoldMenuInBottomBar = true,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => SolidPreferencesDialog(
        onSave: onSave,
        showAppBarSection: showAppBarSection,
        showMenuSection: showMenuSection,
        scaffoldMenuInBottomBar: scaffoldMenuInBottomBar,
      ),
    );
  }

  @override
  State<SolidPreferencesDialog> createState() => _SolidPreferencesDialogState();
}

class _SolidPreferencesDialogState extends State<SolidPreferencesDialog> {
  late List<SolidAppBarActionItem> _appBarActions;
  late bool _menuInBottomBar;

  // The window size section loads and applies its own values, so the dialogue
  // reaches it through its state rather than holding them here.

  final GlobalKey<SolidSettingsWindowSizeSectionState> _windowSize =
      GlobalKey<SolidSettingsWindowSizeSectionState>();

  /// There is no window to size on the web or a phone.

  bool get _showWindowSection => isDesktop;

  @override
  void initState() {
    super.initState();
    _loadCurrentPreferences();
  }

  void _loadCurrentPreferences() {
    final config = solidPreferencesNotifier.config;
    _appBarActions = List.from(config.appBarActions);
    _menuInBottomBar = solidPreferencesNotifier.menuInBottomBarForScaffold(
      widget.scaffoldMenuInBottomBar,
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      // newIndex is already adjusted by ReorderableListView.onReorderItem
      // (see solid_preferences_button_order.dart). No manual `-= 1`
      // shift needed.
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

  /// Save every section, and close — unless a section reports that what the
  /// user typed cannot be used, in which case it has marked the field and the
  /// dialogue stays open on it.

  Future<void> _savePreferences() async {
    if (_showWindowSection) {
      final saved = await _windowSize.currentState?.save() ?? true;
      if (!saved) return;
    }

    final newConfig = SolidPreferencesConfig(appBarActions: _appBarActions);

    solidPreferencesNotifier.setConfig(newConfig);
    solidPreferencesNotifier.setMenuInBottomBar(_menuInBottomBar);
    widget.onSave?.call();

    if (mounted) Navigator.of(context).pop();
  }

  /// Put every section back to its default, leaving the dialogue open so the
  /// user can see what that means before saving it.

  void _resetToDefault() {
    setState(() {
      _appBarActions = solidDefaultAppBarActions(_appBarActions);
      _menuInBottomBar = widget.scaffoldMenuInBottomBar;
    });

    _windowSize.currentState?.restoreDefault();
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
              if (widget.showAppBarSection) ...[
                _sectionHeader(theme, 'Button Order'),
                const SizedBox(height: 8),
                SolidPreferencesButtonOrderSection(
                  appBarActions: _appBarActions,
                  onReorder: _onReorder,
                  onVisibilityChanged: _onVisibilityChanged,
                  onOverflowChanged: _onOverflowChanged,
                ),
              ],
              if (widget.showMenuSection) ...[
                _sectionDivider(widget.showAppBarSection),
                _sectionHeader(theme, 'Menu Layout'),
                const SizedBox(height: 8),
                SolidSettingsMenuSection(
                  menuInBottomBar: _menuInBottomBar,
                  onChanged: (value) =>
                      setState(() => _menuInBottomBar = value),
                ),
              ],
              if (_showWindowSection) ...[
                _sectionDivider(
                  widget.showAppBarSection || widget.showMenuSection,
                ),
                _sectionHeader(theme, 'Window Size'),
                const SizedBox(height: 8),
                SolidSettingsWindowSizeSection(key: _windowSize),
              ],
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

  Widget _sectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  /// A rule between sections, but not above the first one shown.

  Widget _sectionDivider(bool afterAnotherSection) =>
      afterAnotherSection ? const Divider(height: 32) : const SizedBox.shrink();
}
