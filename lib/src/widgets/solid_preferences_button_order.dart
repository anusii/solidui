/// Preferences button order section widgets.
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

/// Builds the button order section for preferences dialogue.

class SolidPreferencesButtonOrderSection extends StatelessWidget {
  /// List of AppBar action items.

  final List<SolidAppBarActionItem> appBarActions;

  /// Callback when items are reordered.

  final void Function(int oldIndex, int newIndex) onReorder;

  /// Callback when visibility is changed.

  final void Function(int index, bool? value) onVisibilityChanged;

  /// Callback when overflow setting is changed.

  final void Function(int index, bool? value) onOverflowChanged;

  const SolidPreferencesButtonOrderSection({
    super.key,
    required this.appBarActions,
    required this.onReorder,
    required this.onVisibilityChanged,
    required this.onOverflowChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (appBarActions.isEmpty) {
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
              height: appBarActions.length * 60.0,
              child: ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                itemCount: appBarActions.length,
                onReorder: onReorder,
                itemBuilder: (context, index) {
                  final action = appBarActions[index];
                  return _SolidPreferencesButtonItem(
                    key: ValueKey(action.id),
                    index: index,
                    action: action,
                    onVisibilityChanged: onVisibilityChanged,
                    onOverflowChanged: onOverflowChanged,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single reorderable button item in the preferences list.

class _SolidPreferencesButtonItem extends StatelessWidget {
  final int index;
  final SolidAppBarActionItem action;
  final void Function(int index, bool? value) onVisibilityChanged;
  final void Function(int index, bool? value) onOverflowChanged;

  const _SolidPreferencesButtonItem({
    super.key,
    required this.index,
    required this.action,
    required this.onVisibilityChanged,
    required this.onOverflowChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
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
                      onVisibilityChanged(index, !action.isVisible),
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
                    onOverflowChanged(index, !action.showInOverflow),
              ),
            ),
          ],
        ),
        dense: true,
      ),
    );
  }
}
