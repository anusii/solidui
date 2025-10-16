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
    double narrowScreenThreshold,
  ) {
    final isWideScreen = SolidScaffoldHelpers.isWideScreen(
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
    );

    return AppBar(
      title: Text(config.title),
      backgroundColor: config.backgroundColor,
      automaticallyImplyLeading: !isWideScreen,
      actions: actions.isEmpty ? null : actions,
    );
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
    BuildContext context,
  ) {
    final hasOverflowItems = config.overflowItems.isNotEmpty;
    final hasThemeToggleInOverflow = themeToggle != null &&
        themeToggle.enabled &&
        (!themeToggle.showInAppBarActions ||
            screenWidth < config.veryNarrowScreenThreshold);

    final hasAboutInOverflow =
        aboutConfig.enabled && screenWidth < config.veryNarrowScreenThreshold;

    if (screenWidth < config.veryNarrowScreenThreshold &&
        (hasOverflowItems || hasThemeToggleInOverflow || hasAboutInOverflow)) {
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
        ),
      );
    } else if (screenWidth >= config.veryNarrowScreenThreshold) {
      // Add overflow items as regular buttons.

      actions.addAll(SolidScaffoldHelpers.buildOverflowIconButtons(config));
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

  /// Builds the overflow menu.

  static Widget _buildOverflowMenu(
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
    VoidCallback? themeToggleCallback,
    SolidAboutConfig aboutConfig,
    bool hasThemeToggleInOverflow,
    bool hasAboutInOverflow,
    BuildContext context,
  ) {
    final overflowMenuItems = SolidScaffoldHelpers.buildOverflowMenuItems(
      config,
      themeToggle,
      currentThemeMode,
      aboutConfig,
      hasThemeToggleInOverflow,
      hasAboutInOverflow,
    );

    return PopupMenuButton<String>(
      onSelected: (String id) {
        if (id == 'theme_toggle') {
          themeToggleCallback?.call();
        } else if (id == 'about') {
          if (aboutConfig.onPressed != null) {
            aboutConfig.onPressed!();
          } else {
            // Show default About dialogue

            SolidAbout.show(context, aboutConfig);
          }
        } else {
          final item = config.overflowItems.firstWhere((item) => item.id == id);
          item.onSelected();
        }
      },
      itemBuilder: (BuildContext context) => overflowMenuItems,
    );
  }
}
