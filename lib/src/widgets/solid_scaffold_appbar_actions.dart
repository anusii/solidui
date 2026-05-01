/// AppBar actions management for Solid Scaffold.
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

import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_preferences_models.dart';
import 'package:solidui/src/widgets/solid_preferences_notifier.dart';
import 'package:solidui/src/widgets/solid_theme_models.dart';

/// Manages AppBar action initialisation and configuration.

class SolidAppBarActionsManager {
  /// Initialises AppBar actions in preferences notifier if empty or missing
  /// items. Dynamically handles all buttons from config.actions and
  /// config.overflowItems in addition to standard buttons.
  ///
  /// The [hasLogout] parameter indicates whether the application has provided
  /// a logout callback. If false, the logout button will not be added to the
  /// preferences list.

  static void initializeIfNeeded(
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle, {
    bool hasLogout = false,
    bool hasSettings = false,
  }) {
    // Check if we need to add missing buttons (standard or custom).

    final existingActions = solidPreferencesNotifier.appBarActions;
    final needsInit = existingActions.isEmpty;
    final needsMerge = !needsInit &&
        _hasMissingButtons(
          existingActions,
          config,
          themeToggle,
          hasLogout,
          hasSettings,
        );

    if (!needsInit && !needsMerge) return;

    final actions = <SolidAppBarActionItem>[];

    // Collect all actions with their initial indices.

    final actionEntries = <_ActionEntry>[];

    // Add theme toggle if enabled.
    // Default: show in AppBar.

    if (themeToggle != null && themeToggle.enabled) {
      actionEntries.add(
        _ActionEntry(
          item: const SolidAppBarActionItem(
            id: SolidAppBarActionIds.themeToggle,
            label: 'Theme Toggle',
            icon: Icons.brightness_6,
            showInOverflow: false, // Show in AppBar by default.
          ),
          initialIndex: 0, // Theme toggle defaults to first position.
        ),
      );
    }

    // Add custom actions from config.
    // Default: show in AppBar.

    for (int i = 0; i < config.actions.length; i++) {
      final action = config.actions[i];
      final actionId = action.id ?? 'action_$i';
      // Use initialIndex if provided, otherwise use position + 100 to come
      // after built-in actions.

      final initialIndex = action.initialIndex ?? (100 + i);
      actionEntries.add(
        _ActionEntry(
          item: SolidAppBarActionItem(
            id: actionId,
            label: action.tooltip ?? 'Action',
            icon: action.icon,
            showInOverflow: false, // Show in AppBar by default.
          ),
          initialIndex: initialIndex,
        ),
      );
    }

    // Add overflow items from config.
    // Default: show in AppBar (user can move to overflow via preferences).

    for (int i = 0; i < config.overflowItems.length; i++) {
      final item = config.overflowItems[i];
      actionEntries.add(
        _ActionEntry(
          item: SolidAppBarActionItem(
            id: item.id,
            label: item.label,
            icon: item.icon,
            showInOverflow: false, // Show in AppBar by default.
          ),
          initialIndex: 200 + i, // Overflow items come after regular actions.
        ),
      );
    }

    // Add Logout button if the application has provided a logout callback.
    // Default: show in AppBar.

    if (hasLogout) {
      actionEntries.add(
        _ActionEntry(
          item: const SolidAppBarActionItem(
            id: SolidAppBarActionIds.logout,
            label: 'Logout',
            icon: Icons.logout,
            showInOverflow: false, // Show in AppBar by default.
          ),
          initialIndex: 300, // Logout button after custom/overflow actions.
        ),
      );
    }

    // Add Settings button if provided.
    // Default: show in AppBar.

    if (hasSettings) {
      actionEntries.add(
        _ActionEntry(
          item: const SolidAppBarActionItem(
            id: SolidAppBarActionIds.settings,
            label: 'Settings',
            icon: Icons.settings,
            showInOverflow: false, // Show in AppBar by default.
          ),
          initialIndex: 800, // Settings button before About button.
        ),
      );
    }

    // Add About button.
    // Default: show in AppBar, rightmost position.

    actionEntries.add(
      _ActionEntry(
        item: const SolidAppBarActionItem(
          id: SolidAppBarActionIds.about,
          label: 'About',
          icon: Icons.info_outline,
          showInOverflow: false, // Show in AppBar by default.
        ),
        initialIndex: 900, // About button at the rightmost position.
      ),
    );

    // Sort by initial index and assign order values.

    actionEntries.sort((a, b) => a.initialIndex.compareTo(b.initialIndex));
    for (int i = 0; i < actionEntries.length; i++) {
      actions.add(actionEntries[i].item.copyWith(order: i));
    }

    // If merging, combine existing actions with new ones.

    if (needsMerge) {
      final mergedActions = _mergeActions(existingActions, actions);
      solidPreferencesNotifier.setAppBarActions(mergedActions);
    } else {
      solidPreferencesNotifier.setAppBarActions(actions);
    }
  }

  /// Checks if any buttons are missing from existing actions.
  /// Dynamically checks all buttons including custom actions and overflow
  /// items.

  static bool _hasMissingButtons(
    List<SolidAppBarActionItem> actions,
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle,
    bool hasLogout,
    bool hasSettings,
  ) {
    final existingIds = actions.map((a) => a.id).toSet();

    // Collect all expected button IDs.

    final expectedIds = <String>[];

    // Theme toggle (if enabled).

    if (themeToggle != null && themeToggle.enabled) {
      expectedIds.add(SolidAppBarActionIds.themeToggle);
    }

    // Custom actions from config.

    for (int i = 0; i < config.actions.length; i++) {
      final action = config.actions[i];
      expectedIds.add(action.id ?? 'action_$i');
    }

    // Overflow items from config.

    for (final item in config.overflowItems) {
      expectedIds.add(item.id);
    }

    // Logout button (only if application has provided a logout callback).

    if (hasLogout) {
      expectedIds.add(SolidAppBarActionIds.logout);
    }

    // Settings button (if provided).

    if (hasSettings) {
      expectedIds.add(SolidAppBarActionIds.settings);
    }

    // About button should always exist.

    expectedIds.add(SolidAppBarActionIds.about);

    // Check if any expected ID is missing.

    for (final id in expectedIds) {
      if (!existingIds.contains(id)) {
        return true;
      }
    }
    return false;
  }

  /// Merges existing actions with new default actions, adding missing ones.

  static List<SolidAppBarActionItem> _mergeActions(
    List<SolidAppBarActionItem> existing,
    List<SolidAppBarActionItem> defaults,
  ) {
    final existingIds = existing.map((a) => a.id).toSet();
    final merged = List<SolidAppBarActionItem>.from(existing);

    // Add missing actions at the end.

    int maxOrder = existing.isEmpty
        ? 0
        : existing.map((a) => a.order).reduce((a, b) => a > b ? a : b);

    for (final action in defaults) {
      if (!existingIds.contains(action.id)) {
        merged.add(action.copyWith(order: ++maxOrder));
      }
    }

    return merged;
  }

  /// Gets the action item configuration from preferences by ID.
  /// Returns null if not found.

  static SolidAppBarActionItem? getActionConfig(String id) {
    final actions = solidPreferencesNotifier.appBarActions;
    try {
      return actions.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Helper class for sorting actions by initial index.

class _ActionEntry {
  final SolidAppBarActionItem item;
  final int initialIndex;

  _ActionEntry({required this.item, required this.initialIndex});
}
