/// Solid Scaffold Helper Functions.
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
import 'package:flutter/scheduler.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:version_widget/version_widget.dart';

import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_preferences_models.dart';
import 'package:solidui/src/widgets/solid_preferences_notifier.dart';
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
          userTextStyle: config.versionConfig!.userTextStyle,
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
    // Determine the tooltip message based on enabled modes.

    final themeModeConfig = solidPreferencesNotifier.themeModeConfig;
    String tooltipMessage;
    if (themeConfig.tooltip != null) {
      tooltipMessage = themeConfig.tooltip!;
    } else {
      tooltipMessage =
          solidThemeNotifier.getTooltipForCurrentMode(themeModeConfig);
    }

    Widget themeButton = IconButton(
      icon: Icon(themeConfig.getNextIcon(currentThemeMode, themeModeConfig)),
      onPressed: themeToggleCallback,
    );

    return MarkdownTooltip(
      message: tooltipMessage,
      child: themeButton,
    );
  }

  /// Builds overflow menu items.
  /// Dynamically includes all buttons based on preferences configuration.

  static List<PopupMenuItem<String>> buildOverflowMenuItems(
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
    SolidAboutConfig aboutConfig,
    bool hasThemeToggleInOverflow,
    bool hasAboutInOverflow, {
    bool hasPreferencesInOverflow = false,
    bool hasLogoutInOverflow = false,
  }) {
    List<PopupMenuItem<String>> overflowMenuItems = [];

    // Get all configured actions from preferences, sorted by order.

    final allActions =
        List<SolidAppBarActionItem>.from(solidPreferencesNotifier.appBarActions)
          ..sort((a, b) => a.order.compareTo(b.order));

    for (final actionItem in allActions) {
      // Skip if not visible.
      // Note: showInOverflow check is handled by hasXxxInOverflow parameters,
      // which already account for narrow screen behavior.

      if (!actionItem.isVisible) continue;

      // Handle each action type.

      if (actionItem.id == SolidAppBarActionIds.themeToggle) {
        // Theme toggle.

        if (hasThemeToggleInOverflow && themeToggle != null) {
          final themeModeConfig = solidPreferencesNotifier.themeModeConfig;
          String labelText;
          switch (currentThemeMode) {
            case ThemeMode.light:
              labelText = 'Switch to Dark Mode';
              break;
            case ThemeMode.dark:
              labelText = 'Switch to Light Mode';
              break;
            case ThemeMode.system:
              final systemBrightness = SchedulerBinding
                  .instance.platformDispatcher.platformBrightness;
              if (systemBrightness == Brightness.light) {
                labelText = 'Switch to Dark Mode';
              } else {
                labelText = 'Switch to Light Mode';
              }
              break;
          }

          overflowMenuItems.add(
            PopupMenuItem<String>(
              value: 'theme_toggle',
              child: Row(
                children: [
                  Icon(
                    themeToggle.getNextIcon(currentThemeMode, themeModeConfig),
                  ),
                  const SizedBox(width: 8),
                  Text(labelText),
                ],
              ),
            ),
          );
        }
      } else if (actionItem.id == SolidAppBarActionIds.logout) {
        // Logout.

        if (hasLogoutInOverflow) {
          overflowMenuItems.add(
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          );
        }
      } else if (actionItem.id == SolidAppBarActionIds.preferences) {
        // Preferences.

        if (hasPreferencesInOverflow) {
          overflowMenuItems.add(
            const PopupMenuItem<String>(
              value: 'preferences',
              child: Row(
                children: [
                  Icon(Icons.tune),
                  SizedBox(width: 8),
                  Text('Preferences'),
                ],
              ),
            ),
          );
        }
      } else if (actionItem.id == SolidAppBarActionIds.about) {
        // About.

        if (hasAboutInOverflow) {
          overflowMenuItems.add(
            PopupMenuItem<String>(
              value: 'about',
              child: Row(
                children: [
                  Icon(aboutConfig.effectiveIcon),
                  const SizedBox(width: 8),
                  const Text('About'),
                ],
              ),
            ),
          );
        }
      } else if (actionItem.id.startsWith('action_')) {
        // Custom action from config.actions.

        final actionIndex =
            int.tryParse(actionItem.id.replaceFirst('action_', ''));
        if (actionIndex != null && actionIndex < config.actions.length) {
          final originalAction = config.actions[actionIndex];
          overflowMenuItems.add(
            PopupMenuItem<String>(
              value: actionItem.id,
              child: Row(
                children: [
                  Icon(originalAction.icon),
                  const SizedBox(width: 8),
                  Text(actionItem.label),
                ],
              ),
            ),
          );
        } else {
          // Try to find by id match if index doesn't work.

          final originalAction =
              config.actions.cast<SolidAppBarAction?>().firstWhere(
                    (a) => a?.id == actionItem.id,
                    orElse: () => null,
                  );
          if (originalAction != null) {
            overflowMenuItems.add(
              PopupMenuItem<String>(
                value: actionItem.id,
                child: Row(
                  children: [
                    Icon(originalAction.icon),
                    const SizedBox(width: 8),
                    Text(actionItem.label),
                  ],
                ),
              ),
            );
          }
        }
      } else {
        // Custom overflow item from config.overflowItems.

        final originalItem =
            config.overflowItems.cast<SolidOverflowMenuItem?>().firstWhere(
                  (item) => item?.id == actionItem.id,
                  orElse: () => null,
                );
        if (originalItem != null) {
          overflowMenuItems.add(
            PopupMenuItem<String>(
              value: actionItem.id,
              child: Row(
                children: [
                  Icon(originalItem.icon),
                  const SizedBox(width: 8),
                  Text(actionItem.label),
                ],
              ),
            ),
          );
        }
      }
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

      iconButton = MarkdownTooltip(message: item.label, child: iconButton);

      buttons.add(iconButton);
    }

    return buttons;
  }

  /// Determines if screen is wide.

  static bool isWideScreen(BuildContext context, double narrowScreenThreshold) {
    return MediaQuery.of(context).size.width > narrowScreenThreshold;
  }

  /// Gets effective child widget.
  ///
  /// Priority order:
  /// 1. bodyOverride (for subpages not in menu)
  /// 2. menu[selectedIndex].child (for menu-based navigation)
  /// 3. child (fallback)
  /// 4. body (final fallback)

  static Widget? getEffectiveChild(
    List<SolidMenuItem>? menu,
    int? currentSelectedIndex,
    Widget? child,
    Widget? body,
    Widget? bodyOverride,
  ) {
    // First priority: bodyOverride for subpages.

    if (bodyOverride != null) {
      return bodyOverride;
    }

    // Second priority: menu-based navigation.
    // When currentSelectedIndex is null, no menu item is selected.

    if (menu != null &&
        currentSelectedIndex != null &&
        currentSelectedIndex < menu.length &&
        currentSelectedIndex >= 0) {
      return menu[currentSelectedIndex].child;
    }

    // Fallback to child or body.

    return child ?? body;
  }

  /// Finds the menu index whose child widget type matches the given subpage.
  /// Returns null if no match is found.

  static int? findMatchingMenuIndex(Widget subpage, List<SolidMenuItem>? menu) {
    if (menu == null) return null;

    final subpageType = subpage.runtimeType;

    for (int i = 0; i < menu.length; i++) {
      final menuChild = menu[i].child;
      if (menuChild != null && menuChild.runtimeType == subpageType) {
        return i;
      }
    }

    return null;
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
      return () {
        solidThemeNotifier.toggleTheme();
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
    String Function() getVersionToDisplay, {
    bool hideNavRail = false,
    void Function(BuildContext)? onLogout,
    bool showPreferences = true,
  }) {
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
      hideNavRail: hideNavRail,
      onLogout: onLogout,
      showPreferences: showPreferences,
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
