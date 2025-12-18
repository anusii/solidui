/// Solid Scaffold AppBar Builder.
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

import 'package:gap/gap.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:solidui/src/widgets/solid_about_button.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_preferences_dialog.dart';
import 'package:solidui/src/widgets/solid_preferences_models.dart';
import 'package:solidui/src/widgets/solid_preferences_notifier.dart';
import 'package:solidui/src/widgets/solid_scaffold_helpers.dart';
import 'package:solidui/src/widgets/solid_theme_models.dart';

/// Builder class for creating AppBar with SolidUI configurations.

class SolidScaffoldAppBarBuilder {
  /// Builds the AppBar with all necessary actions and overflow handling.

  static PreferredSizeWidget? buildAppBar(
    BuildContext context,
    SolidAppBarConfig config,
    bool shouldShowVersion,
    String versionToDisplay,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
    VoidCallback? themeToggleCallback,
    SolidAboutConfig aboutConfig,
    double narrowScreenThreshold, {
    bool hideNavRail = false,
    void Function(BuildContext)? onLogout,
    bool showPreferences = true,
  }) {
    final isWideScreen = !hideNavRail &&
        SolidScaffoldHelpers.isWideScreen(
          context,
          narrowScreenThreshold,
        );
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    // Build action buttons.

    List<Widget> actions = [];

    // Add version widget if configured and screen is not too narrow.

    if (config.versionConfig != null &&
        screenWidth >= config.veryNarrowScreenThreshold &&
        shouldShowVersion) {
      actions.add(
        SolidScaffoldHelpers.buildVersionWidget(
          config,
          versionToDisplay,
          theme,
        ),
      );
      actions.add(const Gap(8));
    }

    // Build ordered actions based on preferences.

    final orderedActions = _buildOrderedActions(
      config: config,
      screenWidth: screenWidth,
      themeToggle: themeToggle,
      currentThemeMode: currentThemeMode,
      themeToggleCallback: themeToggleCallback,
      aboutConfig: aboutConfig,
      context: context,
      showPreferences: showPreferences,
      onLogout: onLogout,
    );
    actions.addAll(orderedActions);

    // Handle overflow menu if on narrow screen.

    _handleOverflowMenu(
      actions,
      config,
      screenWidth,
      themeToggle,
      currentThemeMode,
      themeToggleCallback,
      aboutConfig,
      context,
      showPreferences: showPreferences,
      onLogout: onLogout,
    );

    return AppBar(
      title: Text(config.title),
      backgroundColor: config.backgroundColor,
      automaticallyImplyLeading: !isWideScreen,
      actions: actions.isEmpty ? null : actions,
    );
  }

  /// Builds the preferences button for AppBar.

  static Widget _buildPreferencesButton(
    BuildContext context,
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle,
  ) {
    return MarkdownTooltip(
      message: '''

  **Preferences:** Configure appearance and button layout settings.
  Set which theme modes are available and customise the AppBar button order.

  ''',
      child: IconButton(
        icon: const Icon(Icons.tune),
        onPressed: () => _showPreferencesDialog(context, config, themeToggle),
      ),
    );
  }

  /// Shows the preferences dialogue.

  static void _showPreferencesDialog(
    BuildContext context,
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle,
  ) {
    // Initialise AppBar actions in preferences if not already done.

    _initializeAppBarActionsIfNeeded(config, themeToggle);
    SolidPreferencesDialog.show(context);
  }

  /// Initialises AppBar actions in preferences notifier if empty or missing
  /// items. Dynamically handles all buttons from config.actions and
  /// config.overflowItems in addition to standard buttons.

  static void _initializeAppBarActionsIfNeeded(
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle,
  ) {
    // Check if we need to add missing buttons (standard or custom).

    final existingActions = solidPreferencesNotifier.appBarActions;
    final needsInit = existingActions.isEmpty;
    final needsMerge =
        !needsInit && _hasMissingButtons(existingActions, config, themeToggle);

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

    // Add Logout button.
    // Default: show in AppBar.

    actionEntries.add(
      _ActionEntry(
        item: const SolidAppBarActionItem(
          id: SolidAppBarActionIds.logout,
          label: 'Logout',
          icon: Icons.logout,
          showInOverflow: false, // Show in AppBar by default.
        ),
        initialIndex: 800, // Logout button before About.
      ),
    );

    // Add About button.
    // Default: show in AppBar.

    actionEntries.add(
      _ActionEntry(
        item: const SolidAppBarActionItem(
          id: SolidAppBarActionIds.about,
          label: 'About',
          icon: Icons.info_outline,
          showInOverflow: false, // Show in AppBar by default.
        ),
        initialIndex: 900, // About button near the end.
      ),
    );

    // Add Preferences button.
    // Default: show in AppBar.

    actionEntries.add(
      _ActionEntry(
        item: const SolidAppBarActionItem(
          id: SolidAppBarActionIds.preferences,
          label: 'Preferences',
          icon: Icons.tune,
          showInOverflow: false, // Show in AppBar by default.
        ),
        initialIndex: 910, // Preferences button at the end.
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
  /// Dynamically checks all buttons including custom actions and overflow items.

  static bool _hasMissingButtons(
    List<SolidAppBarActionItem> actions,
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle,
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

    // Standard buttons that should always exist.

    expectedIds.addAll([
      SolidAppBarActionIds.logout,
      SolidAppBarActionIds.about,
      SolidAppBarActionIds.preferences,
    ]);

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

  static SolidAppBarActionItem? _getActionConfig(String id) {
    final actions = solidPreferencesNotifier.appBarActions;
    try {
      return actions.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Builds ordered action buttons based on preferences configuration.
  /// On wide screens: shows all visible buttons (ignores showInOverflow).
  /// On narrow screens: shows buttons marked as "add to appbar" (showInOverflow
  /// = false), others go to overflow menu.

  static List<Widget> _buildOrderedActions({
    required SolidAppBarConfig config,
    required double screenWidth,
    required SolidThemeToggleConfig? themeToggle,
    required ThemeMode currentThemeMode,
    required VoidCallback? themeToggleCallback,
    required SolidAboutConfig aboutConfig,
    required BuildContext context,
    required bool showPreferences,
    void Function(BuildContext)? onLogout,
  }) {
    final List<_OrderedAction> orderedActions = [];
    // Use narrowScreenThreshold to determine when to collapse buttons.
    final isNarrowScreen = screenWidth < config.narrowScreenThreshold;

    // On wide screens: show all visible buttons (ignore showInOverflow).
    // On narrow screens: only show buttons with showInOverflow = false.

    // Add theme toggle.

    if (themeToggle != null && themeToggle.enabled) {
      final actionConfig = _getActionConfig(SolidAppBarActionIds.themeToggle);
      final isVisible = actionConfig?.isVisible ?? true;
      final isInOverflow = actionConfig?.showInOverflow ?? false;
      final order = actionConfig?.order ?? 0;

      // Show if: wide screen, or narrow screen with showInOverflow = false.

      final shouldShow = isVisible &&
          (!isNarrowScreen || !isInOverflow) &&
          _shouldShowThemeToggle(themeToggle, config, screenWidth);

      if (shouldShow) {
        orderedActions.add(
          _OrderedAction(
            order: order,
            widget: SolidScaffoldHelpers.buildThemeToggleButton(
              themeToggle,
              currentThemeMode,
              themeToggleCallback,
            ),
          ),
        );
      }
    }

    // Add custom actions from config.

    for (int i = 0; i < config.actions.length; i++) {
      final action = config.actions[i];
      final actionId = action.id ?? 'action_$i';
      final actionConfig = _getActionConfig(actionId);
      final isVisible = actionConfig?.isVisible ?? true;
      final isInOverflow = actionConfig?.showInOverflow ?? false;
      final order = actionConfig?.order ?? (100 + i);

      // Show if: wide screen, or narrow screen with showInOverflow = false.

      final shouldShow = isVisible &&
          (!isNarrowScreen || !isInOverflow) &&
          _shouldShowAction(action, config, screenWidth);

      if (shouldShow) {
        Widget iconButton = IconButton(
          icon: Icon(action.icon),
          onPressed: action.onPressed,
          color: action.color,
        );

        if (action.tooltip != null) {
          iconButton = MarkdownTooltip(
            message: action.tooltip!,
            child: iconButton,
          );
        }

        orderedActions.add(_OrderedAction(order: order, widget: iconButton));
      }
    }

    // Add preferences button.
    // Preferences button is always visible (forced true) to ensure user can
    // always access settings.

    if (showPreferences) {
      final actionConfig = _getActionConfig(SolidAppBarActionIds.preferences);

      // Force isVisible to true - Preferences button cannot be hidden.

      const isVisible = true;
      final isInOverflow = actionConfig?.showInOverflow ?? false;
      final order = actionConfig?.order ?? 910;

      // Show if: wide screen, or narrow screen with showInOverflow = false.

      if (isVisible && (!isNarrowScreen || !isInOverflow)) {
        orderedActions.add(
          _OrderedAction(
            order: order,
            widget: _buildPreferencesButton(context, config, themeToggle),
          ),
        );
      }
    }

    // Add overflow items as regular buttons.

    for (int i = 0; i < config.overflowItems.length; i++) {
      final item = config.overflowItems[i];
      final actionConfig = _getActionConfig(item.id);
      final isVisible = actionConfig?.isVisible ?? true;
      final isInOverflow = actionConfig?.showInOverflow ?? true;
      final order = actionConfig?.order ?? (200 + i);

      // Show if: wide screen, or narrow screen with showInOverflow = false.

      if (isVisible && (!isNarrowScreen || !isInOverflow)) {
        Widget iconButton = IconButton(
          icon: Icon(item.icon),
          onPressed: item.onSelected,
        );

        iconButton = MarkdownTooltip(message: item.label, child: iconButton);
        orderedActions.add(_OrderedAction(order: order, widget: iconButton));
      }
    }

    // Add logout button.

    if (onLogout != null) {
      final actionConfig = _getActionConfig(SolidAppBarActionIds.logout);
      final isVisible = actionConfig?.isVisible ?? true;
      final isInOverflow = actionConfig?.showInOverflow ?? false;
      final order = actionConfig?.order ?? 800;

      // Show if: wide screen, or narrow screen with showInOverflow = false.

      if (isVisible && (!isNarrowScreen || !isInOverflow)) {
        orderedActions.add(
          _OrderedAction(
            order: order,
            widget: _buildLogoutButton(context, onLogout),
          ),
        );
      }
    }

    // Add About button.

    if (aboutConfig.enabled &&
        aboutConfig.shouldShow(
          screenWidth,
          config.narrowScreenThreshold,
          config.veryNarrowScreenThreshold,
        )) {
      final actionConfig = _getActionConfig(SolidAppBarActionIds.about);
      final isVisible = actionConfig?.isVisible ?? true;
      final isInOverflow = actionConfig?.showInOverflow ?? false;
      final order = actionConfig?.order ?? 900;

      // Show if: wide screen, or narrow screen with showInOverflow = false.

      if (isVisible && (!isNarrowScreen || !isInOverflow)) {
        orderedActions.add(
          _OrderedAction(
            order: order,
            widget: SolidAboutButton(config: aboutConfig),
          ),
        );
      }
    }

    // Sort by order and return widgets.

    orderedActions.sort((a, b) => a.order.compareTo(b.order));
    return orderedActions.map((a) => a.widget).toList();
  }

  /// Determines if an action should be shown based on screen width.

  static bool _shouldShowAction(
    SolidAppBarAction action,
    SolidAppBarConfig config,
    double screenWidth,
  ) {
    if (!action.showOnVeryNarrowScreen &&
        screenWidth < config.veryNarrowScreenThreshold) {
      return false;
    } else if (!action.showOnNarrowScreen &&
        screenWidth < config.narrowScreenThreshold) {
      return false;
    }
    return true;
  }

  /// Determines if theme toggle should be shown.

  static bool _shouldShowThemeToggle(
    SolidThemeToggleConfig? themeToggle,
    SolidAppBarConfig config,
    double screenWidth,
  ) {
    if (themeToggle == null || !themeToggle.enabled) return false;

    if (!themeToggle.showOnVeryNarrowScreen &&
        screenWidth < config.veryNarrowScreenThreshold) {
      return false;
    } else if (!themeToggle.showOnNarrowScreen &&
        screenWidth < config.narrowScreenThreshold) {
      return false;
    }

    return themeToggle.showInAppBarActions &&
        screenWidth >= config.veryNarrowScreenThreshold;
  }

  /// Handles overflow menu on narrow screens.

  static void _handleOverflowMenu(
    List<Widget> actions,
    SolidAppBarConfig config,
    double screenWidth,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
    VoidCallback? themeToggleCallback,
    SolidAboutConfig aboutConfig,
    BuildContext context, {
    bool showPreferences = true,
    void Function(BuildContext)? onLogout,
  }) {
    // Use narrowScreenThreshold to determine when to show overflow menu.

    final isNarrowScreen = screenWidth < config.narrowScreenThreshold;

    // Only show overflow menu on narrow screens.
    // On wide screens, all buttons are displayed directly in AppBar.

    if (!isNarrowScreen) return;

    actions.add(
      _buildOverflowMenu(
        config,
        themeToggle,
        currentThemeMode,
        themeToggleCallback,
        aboutConfig,
        _shouldShowThemeToggleInOverflow(
          themeToggle,
          config,
          screenWidth,
          forceOverflow: true,
        ),
        _shouldShowAboutInOverflow(
          aboutConfig,
          config,
          screenWidth,
          forceOverflow: true,
        ),
        context,
        hasPreferencesInOverflow: _shouldShowPreferencesInOverflow(
          showPreferences,
          screenWidth,
          forceOverflow: true,
        ),
        hasLogoutInOverflow: _shouldShowLogoutInOverflow(
          onLogout != null,
          forceOverflow: true,
        ),
        onLogout: onLogout,
      ),
    );
  }

  static bool _shouldShowLogoutInOverflow(
    bool hasLogout, {
    bool forceOverflow = false,
  }) {
    if (!hasLogout) return false;
    final actionConfig = _getActionConfig(SolidAppBarActionIds.logout);
    final isVisible = actionConfig?.isVisible ?? true;
    if (!isVisible) return false;

    final isInOverflow = actionConfig?.showInOverflow ?? false;

    // On narrow screens, only show in overflow if showInOverflow = true.
    // Buttons marked as "add to appbar" (showInOverflow = false) stay in AppBar.

    if (forceOverflow) return isInOverflow;
    return isInOverflow;
  }

  static bool _shouldShowThemeToggleInOverflow(
    SolidThemeToggleConfig? themeToggle,
    SolidAppBarConfig config,
    double screenWidth, {
    bool forceOverflow = false,
  }) {
    if (themeToggle == null || !themeToggle.enabled) return false;
    final actionConfig = _getActionConfig(SolidAppBarActionIds.themeToggle);
    final isVisible = actionConfig?.isVisible ?? true;
    if (!isVisible) return false;

    final isInOverflow = actionConfig?.showInOverflow ?? false;

    // On narrow screens, only show in overflow if showInOverflow = true.
    // Buttons marked as "add to appbar" (showInOverflow = false) stay in AppBar.

    if (forceOverflow) return isInOverflow;
    return isInOverflow;
  }

  static bool _shouldShowAboutInOverflow(
    SolidAboutConfig aboutConfig,
    SolidAppBarConfig config,
    double screenWidth, {
    bool forceOverflow = false,
  }) {
    if (!aboutConfig.enabled) return false;
    final actionConfig = _getActionConfig(SolidAppBarActionIds.about);
    final isVisible = actionConfig?.isVisible ?? true;
    if (!isVisible) return false;

    final isInOverflow = actionConfig?.showInOverflow ?? false;

    // On narrow screens, only show in overflow if showInOverflow = true.
    // Buttons marked as "add to appbar" (showInOverflow = false) stay in AppBar.

    if (forceOverflow) return isInOverflow;
    return isInOverflow;
  }

  static bool _shouldShowPreferencesInOverflow(
    bool showPreferences,
    double screenWidth, {
    bool forceOverflow = false,
  }) {
    if (!showPreferences) return false;
    final actionConfig = _getActionConfig(SolidAppBarActionIds.preferences);
    // Preferences button is always visible (forced true).

    final isInOverflow = actionConfig?.showInOverflow ?? false;

    // On narrow screens, only show in overflow if showInOverflow = true.
    // Buttons marked as "add to appbar" (showInOverflow = false) stay in AppBar.

    if (forceOverflow) return isInOverflow;
    return isInOverflow;
  }

  /// Builds the logout button.

  static Widget _buildLogoutButton(
    BuildContext context,
    void Function(BuildContext) onLogout,
  ) {
    return MarkdownTooltip(
      message: 'Log out of the current session',
      child: IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () => onLogout(context),
      ),
    );
  }

  /// Builds the overflow menu.
  /// Uses Builder to ensure context is valid during callbacks.

  static Widget _buildOverflowMenu(
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
    VoidCallback? themeToggleCallback,
    SolidAboutConfig aboutConfig,
    bool hasThemeToggleInOverflow,
    bool hasAboutInOverflow,
    BuildContext parentContext, {
    bool hasPreferencesInOverflow = false,
    bool hasLogoutInOverflow = false,
    void Function(BuildContext)? onLogout,
  }) {
    final overflowMenuItems = SolidScaffoldHelpers.buildOverflowMenuItems(
      config,
      themeToggle,
      currentThemeMode,
      aboutConfig,
      hasThemeToggleInOverflow,
      hasAboutInOverflow,
      hasPreferencesInOverflow: hasPreferencesInOverflow,
      hasLogoutInOverflow: hasLogoutInOverflow,
    );

    // Use Builder to get a valid context for callbacks, preventing
    // "deactivated widget's ancestor" errors during window resize.

    return Builder(
      builder: (BuildContext context) {
        return PopupMenuButton<String>(
          onSelected: (String id) {
            // Check if context is still mounted before using it.

            if (!context.mounted) return;

            if (id == 'theme_toggle') {
              themeToggleCallback?.call();
            } else if (id == 'about') {
              if (aboutConfig.onPressed != null) {
                aboutConfig.onPressed!();
              } else {
                // Show default About dialogue.

                SolidAbout.show(context, aboutConfig);
              }
            } else if (id == 'preferences') {
              _showPreferencesDialog(context, config, themeToggle);
            } else if (id == 'logout') {
              onLogout?.call(context);
            } else if (id.startsWith('action_')) {
              // Handle custom actions from config.actions.

              final actionIndex = int.tryParse(id.replaceFirst('action_', ''));
              if (actionIndex != null && actionIndex < config.actions.length) {
                config.actions[actionIndex].onPressed();
              } else {
                // Try to find by id match if index doesn't work.

                final action =
                    config.actions.cast<SolidAppBarAction?>().firstWhere(
                          (a) => a?.id == id,
                          orElse: () => null,
                        );
                action?.onPressed();
              }
            } else {
              // Handle overflow items from config.overflowItems.

              final item = config.overflowItems
                  .cast<SolidOverflowMenuItem?>()
                  .firstWhere(
                    (item) => item?.id == id,
                    orElse: () => null,
                  );
              item?.onSelected();
            }
          },
          itemBuilder: (BuildContext menuContext) => overflowMenuItems,
        );
      },
    );
  }
}

/// Helper class for sorting actions by initial index.

class _ActionEntry {
  final SolidAppBarActionItem item;
  final int initialIndex;

  _ActionEntry({required this.item, required this.initialIndex});
}

/// Helper class for building ordered action widgets.

class _OrderedAction {
  final int order;
  final Widget widget;

  _OrderedAction({required this.order, required this.widget});
}
