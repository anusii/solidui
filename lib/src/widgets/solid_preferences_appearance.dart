/// Preferences appearance section widgets.
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

/// Builds the appearance section for preferences dialogue.

class SolidPreferencesAppearanceSection extends StatelessWidget {
  /// Whether light mode is enabled.

  final bool lightModeEnabled;

  /// Whether dark mode is enabled.

  final bool darkModeEnabled;

  /// Whether system mode is enabled.

  final bool systemModeEnabled;

  /// Whether smart toggle is enabled.

  final bool smartToggle;

  /// Callback when light mode is changed.

  final ValueChanged<bool?> onLightModeChanged;

  /// Callback when dark mode is changed.

  final ValueChanged<bool?> onDarkModeChanged;

  /// Callback when system mode is changed.

  final ValueChanged<bool?> onSystemModeChanged;

  /// Callback when smart toggle is changed.

  final ValueChanged<bool> onSmartToggleChanged;

  const SolidPreferencesAppearanceSection({
    super.key,
    required this.lightModeEnabled,
    required this.darkModeEnabled,
    required this.systemModeEnabled,
    required this.smartToggle,
    required this.onLightModeChanged,
    required this.onDarkModeChanged,
    required this.onSystemModeChanged,
    required this.onSmartToggleChanged,
  });

  /// Whether all three modes are enabled.

  bool get _allModesEnabled =>
      lightModeEnabled && darkModeEnabled && systemModeEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              value: lightModeEnabled,
              onChanged: onLightModeChanged,
            ),
            _buildThemeModeCheckbox(
              icon: Icons.dark_mode,
              label: 'Dark Mode',
              tooltip: 'Include dark mode in theme toggle',
              value: darkModeEnabled,
              onChanged: onDarkModeChanged,
            ),
            _buildThemeModeCheckbox(
              icon: Icons.brightness_auto,
              label: 'System Mode',
              tooltip:
                  'Include system mode (follows device settings) in theme toggle',
              value: systemModeEnabled,
              onChanged: onSystemModeChanged,
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
      message: smartToggle
          ? 'Adaptive: From System mode, switches to the opposite of '
              'current system brightness, then cycles between Light and Dark.'
          : 'Sequential: Cycles through System → Light → Dark → System.',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Icon(
              smartToggle ? Icons.auto_awesome : Icons.swap_horiz,
              size: 20,
              color: smartToggle ? theme.colorScheme.primary : null,
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
                value: smartToggle,
                onChanged: onSmartToggleChanged,
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
}
