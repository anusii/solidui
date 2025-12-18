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

import 'package:solidui/src/widgets/solid_preferences_models.dart';
import 'package:solidui/src/widgets/solid_preferences_notifier.dart';

/// A dialogue widget for configuring user preferences including appearance
/// settings and AppBar button ordering.

class SolidPreferencesDialog extends StatefulWidget {
  /// Optional callback when preferences are saved.

  final VoidCallback? onSave;

  /// Optional title for the dialogue.

  final String title;

  const SolidPreferencesDialog({
    super.key,
    this.onSave,
    this.title = 'Preferences',
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
  late bool _lightModeEnabled;
  late bool _darkModeEnabled;
  late bool _systemModeEnabled;
  late bool _smartToggle;
  late List<SolidAppBarActionItem> _appBarActions;

  @override
  void initState() {
    super.initState();
    _loadCurrentPreferences();
  }

  void _loadCurrentPreferences() {
    final config = solidPreferencesNotifier.config;
    _lightModeEnabled = config.themeModeConfig.lightModeEnabled;
    _darkModeEnabled = config.themeModeConfig.darkModeEnabled;
    _systemModeEnabled = config.themeModeConfig.systemModeEnabled;
    _smartToggle = config.themeModeConfig.smartToggle;
    _appBarActions = List.from(config.appBarActions);
  }

  /// Whether all three modes are enabled.

  bool get _allModesEnabled =>
      _lightModeEnabled && _darkModeEnabled && _systemModeEnabled;

  bool get _isAtLeastOneModeEnabled =>
      _lightModeEnabled || _darkModeEnabled || _systemModeEnabled;

  void _onLightModeChanged(bool? value) {
    if (value == null) return;

    // Prevent unchecking if it's the last enabled mode.

    if (!value && !_darkModeEnabled && !_systemModeEnabled) {
      _showMinimumModeWarning();
      return;
    }

    setState(() => _lightModeEnabled = value);
  }

  void _onDarkModeChanged(bool? value) {
    if (value == null) return;

    // Prevent unchecking if it's the last enabled mode.

    if (!value && !_lightModeEnabled && !_systemModeEnabled) {
      _showMinimumModeWarning();
      return;
    }

    setState(() => _darkModeEnabled = value);
  }

  void _onSystemModeChanged(bool? value) {
    if (value == null) return;

    // Prevent unchecking if it's the last enabled mode.

    if (!value && !_lightModeEnabled && !_darkModeEnabled) {
      _showMinimumModeWarning();
      return;
    }

    setState(() => _systemModeEnabled = value);
  }

  void _showMinimumModeWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('At least one theme mode must be enabled'),
        duration: Duration(seconds: 2),
      ),
    );
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
      _appBarActions[index] =
          _appBarActions[index].copyWith(showInOverflow: value);
    });
  }

  void _onVisibilityChanged(int index, bool? value) {
    if (value == null) return;

    // Prevent hiding Preferences button (user won't be able to restore it).

    final action = _appBarActions[index];
    if (action.id == SolidAppBarActionIds.preferences && value == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences button cannot be hidden'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _appBarActions[index] =
          _appBarActions[index].copyWith(isVisible: value);
    });
  }

  void _onSmartToggleChanged(bool value) {
    setState(() => _smartToggle = value);
  }

  void _savePreferences() {
    final themeModeConfig = SolidThemeModeConfig(
      lightModeEnabled: _lightModeEnabled,
      darkModeEnabled: _darkModeEnabled,
      systemModeEnabled: _systemModeEnabled,
      smartToggle: _smartToggle,
    );

    final newConfig = SolidPreferencesConfig(
      themeModeConfig: themeModeConfig,
      appBarActions: _appBarActions,
    );

    solidPreferencesNotifier.setConfig(newConfig);
    widget.onSave?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.settings),
          const SizedBox(width: 8),
          Text(widget.title),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section.

              _buildSectionHeader(theme, 'Appearance'),
              const SizedBox(height: 8),
              _buildAppearanceSection(theme),
              const SizedBox(height: 24),

              // Button Order Section.

              _buildSectionHeader(theme, 'Button Order'),
              const SizedBox(height: 8),
              _buildButtonOrderSection(theme),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isAtLeastOneModeEnabled ? _savePreferences : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAppearanceSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select which theme modes to include in the toggle cycle:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _buildThemeModeCheckbox(
              icon: Icons.light_mode,
              label: 'Light Mode',
              tooltip: 'Include light mode in theme toggle',
              value: _lightModeEnabled,
              onChanged: _onLightModeChanged,
            ),
            _buildThemeModeCheckbox(
              icon: Icons.dark_mode,
              label: 'Dark Mode',
              tooltip: 'Include dark mode in theme toggle',
              value: _darkModeEnabled,
              onChanged: _onDarkModeChanged,
            ),
            _buildThemeModeCheckbox(
              icon: Icons.brightness_auto,
              label: 'System Mode',
              tooltip:
                  'Include system mode (follows device settings) in theme toggle',
              value: _systemModeEnabled,
              onChanged: _onSystemModeChanged,
            ),

            // Smart toggle switch - only shown when all modes are enabled.

            if (_allModesEnabled) ...[
              const Divider(height: 24),
              _buildSmartToggleSwitch(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSmartToggleSwitch(ThemeData theme) {
    return Tooltip(
      message: _smartToggle
          ? 'Adaptive: From System mode, switches to the opposite of '
              'current system brightness, then cycles between Light and Dark.'
          : 'Sequential: Cycles through System → Light → Dark → System.',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Icon(
              _smartToggle ? Icons.auto_awesome : Icons.swap_horiz,
              size: 20,
              color: _smartToggle ? theme.colorScheme.primary : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Adaptive Toggle',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Transform.scale(
              scale: 0.85,
              child: Switch(
                value: _smartToggle,
                onChanged: _onSmartToggleChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeCheckbox({
    required IconData icon,
    required String label,
    required String tooltip,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Tooltip(
      message: tooltip,
      child: CheckboxListTile(
        secondary: Icon(icon),
        title: Text(label),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
      ),
    );
  }

  Widget _buildButtonOrderSection(ThemeData theme) {
    if (_appBarActions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No configurable buttons available.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Drag to reorder buttons. Use the eye icon to toggle visibility, '
              'and the menu icon to move to overflow on narrow screens:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: _appBarActions.length * 60.0,
              child: ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                itemCount: _appBarActions.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final action = _appBarActions[index];
                  return _buildReorderableItem(
                    key: ValueKey(action.id),
                    index: index,
                    action: action,
                    theme: theme,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableItem({
    required Key key,
    required int index,
    required SolidAppBarActionItem action,
    required ThemeData theme,
  }) {
    return Material(
      key: key,
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
        title: Row(
          children: [
            Icon(
              action.icon,
              size: 20,
              color: action.isVisible
                  ? null
                  : theme.colorScheme.onSurface.withValues(alpha: 0.38),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                action.label,
                style: action.isVisible
                    ? null
                    : TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.38,
                        ),
                      ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Visibility toggle.
            // Disabled for Preferences button (cannot be hidden).

            if (action.id == SolidAppBarActionIds.preferences)
              Tooltip(
                message: 'Preferences button is always visible',
                child: IconButton(
                  icon: Icon(
                    Icons.visibility,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  onPressed: null, // Disabled.
                ),
              )
            else
              Tooltip(
                message: action.isVisible ? 'Hide button' : 'Show button',
                child: IconButton(
                  icon: Icon(
                    action.isVisible ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                    color: action.isVisible
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  onPressed: () =>
                      _onVisibilityChanged(index, !action.isVisible),
                ),
              ),

            // Overflow toggle.

            Tooltip(
              message: action.showInOverflow
                  ? 'Show in AppBar'
                  : 'Move to overflow menu',
              child: IconButton(
                icon: Icon(
                  action.showInOverflow ? Icons.more_vert : Icons.push_pin,
                  size: 20,
                  color: action.showInOverflow
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                      : theme.colorScheme.primary,
                ),
                onPressed: () =>
                    _onOverflowChanged(index, !action.showInOverflow),
              ),
            ),
          ],
        ),
        dense: true,
      ),
    );
  }
}
