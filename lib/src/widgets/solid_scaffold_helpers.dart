/// Solid Scaffold Helper Functions.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:version_widget/version_widget.dart';

import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_scaffold_appbar_builder.dart';
import 'package:solidui/src/widgets/solid_scaffold_models.dart';
import 'package:solidui/src/widgets/solid_theme_models.dart';
import 'package:solidui/src/widgets/solid_theme_notifier.dart';

/// Helper class for Solid Scaffold operations.

class SolidScaffoldHelpers {
  /// Converts SolidMenuItem to SolidNavTab.

  static List<SolidNavTab> convertToNavTabs(List<SolidMenuItem>? menu) {
    if (menu == null) {
      return [];
    }

    return menu
        .map(
          (item) => SolidNavTab(
            title: item.title,
            icon: item.icon,
            color: item.color,
            child: item.child,
            tooltip: item.tooltip,
            message: item.message,
            dialogTitle: item.dialogTitle,
            action: item.onTap,
          ),
        )
        .toList();
  }

  /// Builds version widget for AppBar actions.

  static Widget buildVersionWidget(
    SolidAppBarConfig config,
    String versionToDisplay,
    ThemeData theme,
  ) {
    return MarkdownTooltip(
      message: config.versionConfig!.tooltip ??
          'Version: $versionToDisplay\n\n'
              'Tap to view changelog if available.',
      child: Theme(
        data: theme.copyWith(
          textTheme: theme.textTheme.copyWith(
            bodyMedium: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            bodySmall: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          colorScheme: theme.colorScheme.copyWith(
            error: theme.colorScheme.error.withValues(alpha: 0.6),
          ),
        ),
        child: VersionWidget(
          version: versionToDisplay,
          changelogUrl: config.versionConfig!.changelogUrl,
          showDate: config.versionConfig!.showDate,
        ),
      ),
    );
  }

  /// Builds theme toggle button for AppBar actions.

  static Widget buildThemeToggleButton(
    SolidThemeToggleConfig themeConfig,
    ThemeMode currentThemeMode,
    VoidCallback? themeToggleCallback,
  ) {
    Widget themeButton = IconButton(
      icon: Icon(themeConfig.getNextIcon(currentThemeMode)),
      onPressed: themeToggleCallback,
    );

    return MarkdownTooltip(
      message: themeConfig.getNextTooltip(currentThemeMode),
      child: themeButton,
    );
  }

  /// Builds overflow menu items.

  static List<PopupMenuItem<String>> buildOverflowMenuItems(
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
    SolidAboutConfig aboutConfig,
    bool hasThemeToggleInOverflow,
    bool hasAboutInOverflow,
  ) {
    List<PopupMenuItem<String>> overflowMenuItems = [];

    // Add regular overflow items.

    overflowMenuItems.addAll(
      config.overflowItems.where((item) => item.showInOverflow).map(
            (item) => PopupMenuItem<String>(
              value: item.id,
              child: Row(
                children: [
                  Icon(item.icon),
                  const SizedBox(width: 8),
                  Text(item.label),
                ],
              ),
            ),
          ),
    );

    // Add theme toggle to overflow menu if configured.

    if (hasThemeToggleInOverflow && themeToggle != null) {
      overflowMenuItems.add(
        PopupMenuItem<String>(
          value: 'theme_toggle',
          child: Row(
            children: [
              Icon(themeToggle.getNextIcon(currentThemeMode)),
              const SizedBox(width: 8),
              Text(themeToggle.getNextOverflowLabel(currentThemeMode)),
            ],
          ),
        ),
      );
    }

    // Add About button to overflow menu if configured.

    if (hasAboutInOverflow) {
      overflowMenuItems.add(
        PopupMenuItem<String>(
          value: 'about',
          child: Row(
            children: [
              Icon(aboutConfig.effectiveIcon),
              const SizedBox(width: 8),
              Text('About'),
            ],
          ),
        ),
      );
    }

    return overflowMenuItems;
  }

  /// Builds overflow icon buttons for wider screens.

  static List<Widget> buildOverflowIconButtons(SolidAppBarConfig config) {
    List<Widget> buttons = [];

    for (final item in config.overflowItems) {
      Widget iconButton = IconButton(
        icon: Icon(item.icon),
        onPressed: item.onSelected,
      );

      iconButton = MarkdownTooltip(
        message: item.label,
        child: iconButton,
      );

      buttons.add(iconButton);
    }

    return buttons;
  }

  /// Determines if screen is wide.

  static bool isWideScreen(BuildContext context, double narrowScreenThreshold) {
    return MediaQuery.of(context).size.width > narrowScreenThreshold;
  }

  /// Gets effective child widget.

  static Widget? getEffectiveChild(
    List<SolidMenuItem>? menu,
    int currentSelectedIndex,
    Widget? child,
    Widget? body,
  ) {
    if (menu != null &&
        currentSelectedIndex < menu.length &&
        currentSelectedIndex >= 0) {
      return menu[currentSelectedIndex].child;
    }
    return child ?? body;
  }

  /// Resolves the app bar to use.

  static PreferredSizeWidget? resolveAppBar(
    BuildContext context,
    dynamic appBar,
    PreferredSizeWidget? scaffoldAppBar,
    bool isCompatibilityMode,
    List<SolidMenuItem>? menu,
    PreferredSizeWidget? Function(BuildContext) buildAppBar,
  ) {
    if (appBar is PreferredSizeWidget) {
      return appBar;
    } else if (appBar is SolidAppBarConfig) {
      return buildAppBar(context);
    } else if (appBar == null) {
      if (isCompatibilityMode) {
        return scaffoldAppBar;
      } else {
        return menu != null ? buildAppBar(context) : null;
      }
    }
    return scaffoldAppBar;
  }

  /// Gets the current theme mode based on internal management.

  static ThemeMode getCurrentThemeMode(
    bool usesInternalManagement,
    SolidThemeNotifier solidThemeNotifier,
    SolidThemeToggleConfig? themeToggle,
  ) {
    if (usesInternalManagement) {
      return solidThemeNotifier.themeMode;
    }
    return themeToggle?.currentThemeMode ?? ThemeMode.system;
  }

  /// Gets theme toggle callback.

  static VoidCallback? getThemeToggleCallback(
    bool usesInternalManagement,
    SolidThemeNotifier solidThemeNotifier,
    SolidThemeToggleConfig? themeToggle,
  ) {
    if (usesInternalManagement) {
      return () async {
        await solidThemeNotifier.toggleTheme();
      };
    }
    return themeToggle?.onToggleTheme;
  }

  /// Checks if uses internal management.

  static bool getUsesInternalManagement(SolidThemeToggleConfig? themeToggle) {
    return themeToggle?.usesInternalManagement ?? false;
  }

  /// Builds the app bar.

  static PreferredSizeWidget? buildAppBarFromConfig(
    BuildContext context,
    dynamic appBar,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
    VoidCallback? themeToggleCallback,
    SolidAboutConfig aboutConfig,
    double narrowScreenThreshold,
    bool Function() shouldShowVersion,
    String Function() getVersionToDisplay,
  ) {
    if (appBar == null) return null;
    if (appBar is! SolidAppBarConfig) return null;

    return SolidScaffoldAppBarBuilder.buildAppBar(
      context,
      appBar,
      shouldShowVersion(),
      getVersionToDisplay(),
      themeToggle,
      currentThemeMode,
      themeToggleCallback,
      aboutConfig,
      narrowScreenThreshold,
    );
  }

  /// Gets version to display.

  static String getVersionToDisplay(bool isVersionLoaded, String? appVersion) {
    if (isVersionLoaded && appVersion != null) {
      return appVersion;
    }
    return '0.0.0+0';
  }

  /// Checks if should show version.

  static bool shouldShowVersion(bool isVersionLoaded) => isVersionLoaded;
}
