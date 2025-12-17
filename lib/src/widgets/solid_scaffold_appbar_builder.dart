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

    // Add regular action buttons.

    actions.addAll(_buildRegularActions(config, screenWidth));

    // Add theme toggle if configured.

    if (_shouldShowThemeToggle(themeToggle, config, screenWidth)) {
      actions.add(
        SolidScaffoldHelpers.buildThemeToggleButton(
          themeToggle!,
          currentThemeMode,
          themeToggleCallback,
        ),
      );
    }

    // Add preferences button if enabled and screen is wide enough.

    if (showPreferences && screenWidth >= config.veryNarrowScreenThreshold) {
      actions.add(_buildPreferencesButton(context, config, themeToggle));
    }

    // Handle overflow menu or regular buttons based on screen width.

    _handleOverflowItems(
      actions,
      config,
      screenWidth,
      themeToggle,
      currentThemeMode,
      themeToggleCallback,
      aboutConfig,
      context,
      onLogout: onLogout,
      showPreferences: showPreferences,
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

  /// Initialises AppBar actions in preferences notifier if empty.

  static void _initializeAppBarActionsIfNeeded(
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle,
  ) {
    if (solidPreferencesNotifier.appBarActions.isNotEmpty) return;

    final actions = <SolidAppBarActionItem>[];
    int order = 0;

    // Add theme toggle if enabled.

    if (themeToggle != null && themeToggle.enabled) {
      actions.add(
        SolidAppBarActionItem(
          id: SolidAppBarActionIds.themeToggle,
          label: 'Theme Toggle',
          icon: Icons.brightness_6,
          showInOverflow: !themeToggle.showInAppBarActions,
          order: order++,
        ),
      );
    }

    // Add custom actions from config.

    for (final action in config.actions) {
      actions.add(
        SolidAppBarActionItem(
          id: 'action_${actions.length}',
          label: action.tooltip ?? 'Action',
          icon: action.icon,
          showInOverflow: !action.showOnNarrowScreen,
          order: order++,
        ),
      );
    }

    // Add overflow items from config.

    for (final item in config.overflowItems) {
      actions.add(
        SolidAppBarActionItem(
          id: item.id,
          label: item.label,
          icon: item.icon,
          showInOverflow: item.showInOverflow,
          order: order++,
        ),
      );
    }

    // Add About button.

    actions.add(
      SolidAppBarActionItem(
        id: SolidAppBarActionIds.about,
        label: 'About',
        icon: Icons.info_outline,
        showInOverflow: true,
        order: order++,
      ),
    );

    // Add Preferences button.

    actions.add(
      SolidAppBarActionItem(
        id: SolidAppBarActionIds.preferences,
        label: 'Preferences',
        icon: Icons.tune,
        showInOverflow: true,
        order: order++,
      ),
    );

    solidPreferencesNotifier.setAppBarActions(actions);
  }

  /// Builds regular action buttons.

  static List<Widget> _buildRegularActions(
    SolidAppBarConfig config,
    double screenWidth,
  ) {
    List<Widget> actions = [];

    for (final action in config.actions) {
      bool shouldShow = _shouldShowAction(action, config, screenWidth);

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

        actions.add(iconButton);
      }
    }

    return actions;
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

  /// Handles overflow items and about button.

  static void _handleOverflowItems(
    List<Widget> actions,
    SolidAppBarConfig config,
    double screenWidth,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
    VoidCallback? themeToggleCallback,
    SolidAboutConfig aboutConfig,
    BuildContext context, {
    void Function(BuildContext)? onLogout,
    bool showPreferences = true,
  }) {
    final hasOverflowItems = config.overflowItems.isNotEmpty;
    final hasThemeToggleInOverflow = themeToggle != null &&
        themeToggle.enabled &&
        (!themeToggle.showInAppBarActions ||
            screenWidth < config.veryNarrowScreenThreshold);

    final hasAboutInOverflow =
        aboutConfig.enabled && screenWidth < config.veryNarrowScreenThreshold;

    final hasPreferencesInOverflow =
        showPreferences && screenWidth < config.veryNarrowScreenThreshold;

    if (screenWidth < config.veryNarrowScreenThreshold &&
        (hasOverflowItems ||
            hasThemeToggleInOverflow ||
            hasAboutInOverflow ||
            hasPreferencesInOverflow)) {
      // Add overflow menu.

      actions.add(
        _buildOverflowMenu(
          config,
          themeToggle,
          currentThemeMode,
          themeToggleCallback,
          aboutConfig,
          hasThemeToggleInOverflow,
          hasAboutInOverflow,
          context,
          hasPreferencesInOverflow: hasPreferencesInOverflow,
        ),
      );
    } else if (screenWidth >= config.veryNarrowScreenThreshold) {
      // Add overflow items as regular buttons.

      actions.addAll(SolidScaffoldHelpers.buildOverflowIconButtons(config));
    }

    // Add logout button if callback is provided.

    if (onLogout != null) {
      actions.add(
        _buildLogoutButton(context, onLogout),
      );
    }

    // Add About button if it should be shown.

    if (aboutConfig.enabled &&
        aboutConfig.shouldShow(
          screenWidth,
          config.narrowScreenThreshold,
          config.veryNarrowScreenThreshold,
        ) &&
        screenWidth >= config.veryNarrowScreenThreshold) {
      actions.add(SolidAboutButton(config: aboutConfig));
    }
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

  static Widget _buildOverflowMenu(
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
    VoidCallback? themeToggleCallback,
    SolidAboutConfig aboutConfig,
    bool hasThemeToggleInOverflow,
    bool hasAboutInOverflow,
    BuildContext context, {
    bool hasPreferencesInOverflow = false,
  }) {
    final overflowMenuItems = SolidScaffoldHelpers.buildOverflowMenuItems(
      config,
      themeToggle,
      currentThemeMode,
      aboutConfig,
      hasThemeToggleInOverflow,
      hasAboutInOverflow,
      hasPreferencesInOverflow: hasPreferencesInOverflow,
    );

    return PopupMenuButton<String>(
      onSelected: (String id) {
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
        } else {
          final item = config.overflowItems.firstWhere((item) => item.id == id);
          item.onSelected();
        }
      },
      itemBuilder: (BuildContext context) => overflowMenuItems,
    );
  }
}
