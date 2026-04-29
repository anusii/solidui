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

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:version_widget/version_widget.dart';

import 'package:solidui/src/constants/ui_window.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_invite_others_models.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_overflow_menu_helpers.dart';
import 'package:solidui/src/widgets/solid_scaffold_appbar_builder.dart';
import 'package:solidui/src/widgets/solid_scaffold_models.dart';
import 'package:solidui/src/widgets/solid_theme_models.dart';
import 'package:solidui/src/widgets/solid_theme_notifier.dart';
import 'package:solidui/src/widgets/solid_theme_toggle_helpers.dart';

// Re-export helpers for backwards compatibility.

export 'package:solidui/src/widgets/solid_overflow_menu_helpers.dart';
export 'package:solidui/src/widgets/solid_theme_toggle_helpers.dart';

/// Helper class for Solid Scaffold operations.

class SolidScaffoldHelpers {
  /// Converts SolidMenuItem to SolidNavTab.

  static List<SolidNavTab> convertToNavTabs(List<SolidMenuItem>? menu) {
    if (menu == null) return [];
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
    // Determine if the app bar has a dark background.

    final isDarkBg = config.backgroundColor != null &&
        ThemeData.estimateBrightnessForColor(config.backgroundColor!) ==
            Brightness.dark;

    final textOpacity = isDarkBg ? 0.8 : 0.6;
    final errorOpacity = isDarkBg ? 0.7 : 0.5;

    return MarkdownTooltip(
      message: config.versionConfig!.tooltip ??
          'Version: $versionToDisplay\n\n'
              'Tap to view changelog if available.',
      child: Theme(
        data: theme.copyWith(
          textTheme: theme.textTheme.copyWith(
            bodyMedium: theme.textTheme.bodySmall?.copyWith(
              color: isDarkBg
                  ? Colors.white.withValues(alpha: textOpacity)
                  : theme.colorScheme.onSurface.withValues(alpha: textOpacity),
              fontSize: 13,
            ),
            bodySmall: theme.textTheme.bodySmall?.copyWith(
              color: isDarkBg
                  ? Colors.white.withValues(alpha: textOpacity - 0.1)
                  : theme.colorScheme.onSurface
                      .withValues(alpha: textOpacity - 0.1),
              fontSize: 12,
            ),
          ),
          colorScheme: theme.colorScheme.copyWith(
            error: theme.colorScheme.error.withValues(alpha: errorOpacity),
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
  ) =>
      SolidThemeToggleHelpers.buildThemeToggleButton(
        themeConfig,
        currentThemeMode,
        themeToggleCallback,
      );

  /// Builds the system mode icon with an 'A' badge.

  static Widget buildSystemModeIcon({double iconSize = 24.0}) =>
      SolidThemeToggleHelpers.buildSystemModeIcon(iconSize: iconSize);

  /// Builds overflow menu items.

  static List<PopupMenuItem<String>> buildOverflowMenuItems(
    SolidAppBarConfig config,
    SolidThemeToggleConfig? themeToggle,
    ThemeMode currentThemeMode,
    SolidAboutConfig aboutConfig,
    bool hasThemeToggleInOverflow,
    bool hasAboutInOverflow, {
    bool hasLogoutInOverflow = false,
    bool isLoggedIn = true,
    bool hasInviteOthersInOverflow = false,
    SolidInviteOthersConfig? inviteConfig,
  }) =>
      SolidOverflowMenuHelpers.buildOverflowMenuItems(
        config,
        themeToggle,
        currentThemeMode,
        aboutConfig,
        hasThemeToggleInOverflow,
        hasAboutInOverflow,
        hasLogoutInOverflow: hasLogoutInOverflow,
        isLoggedIn: isLoggedIn,
        hasInviteOthersInOverflow: hasInviteOthersInOverflow,
        inviteConfig: inviteConfig,
      );

  /// Builds overflow icon buttons for wider screens.

  static List<Widget> buildOverflowIconButtons(SolidAppBarConfig config) =>
      SolidOverflowMenuHelpers.buildOverflowIconButtons(config);

  /// Delegates to [WindowSize.isNarrow] using [BoxConstraints].

  static bool isNarrowScreen(
    BoxConstraints constraints, {
    double? narrowThreshold,
  }) {
    if (narrowThreshold != null) {
      return WindowSize.isNarrow(
        constraints,
        narrowThreshold: narrowThreshold,
      );
    }
    return WindowSize.isNarrow(constraints);
  }

  /// Delegates to [WindowSize.isVeryNarrow] using [BoxConstraints].

  static bool isVeryNarrowScreen(BoxConstraints constraints) {
    return WindowSize.isVeryNarrow(constraints);
  }

  /// Delegates to [WindowSize.isMedium] using [BoxConstraints].

  static bool isMedScreen(BoxConstraints constraints) {
    return WindowSize.isMedium(constraints);
  }

  /// Delegates to [WindowSize.isWide] using [BoxConstraints].

  static bool isWideScreen(BoxConstraints constraints) {
    return WindowSize.isWide(constraints);
  }

  /// Delegates to [WindowSize.isVeryWide] using [BoxConstraints].

  static bool isVeryWideScreen(BoxConstraints constraints) {
    return WindowSize.isVeryWide(constraints);
  }

  /// Gets effective child widget.
  /// Priority: bodyOverride > menu[selectedIndex].child > child > body.

  static Widget? getEffectiveChild(
    List<SolidMenuItem>? menu,
    int? currentSelectedIndex,
    Widget? child,
    Widget? body,
    Widget? bodyOverride,
  ) {
    if (bodyOverride != null) return bodyOverride;
    if (menu != null &&
        currentSelectedIndex != null &&
        currentSelectedIndex < menu.length &&
        currentSelectedIndex >= 0) {
      return menu[currentSelectedIndex].child;
    }
    return child ?? body;
  }

  /// Finds the menu index whose child widget type matches the given subpage.

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
    if (appBar is PreferredSizeWidget) return appBar;
    if (appBar is SolidAppBarConfig) return buildAppBar(context);
    if (appBar == null) {
      if (isCompatibilityMode) return scaffoldAppBar;
      return menu != null ? buildAppBar(context) : null;
    }
    return scaffoldAppBar;
  }

  /// Gets the current theme mode based on internal management.

  static ThemeMode getCurrentThemeMode(
    bool usesInternalManagement,
    SolidThemeNotifier solidThemeNotifier,
    SolidThemeToggleConfig? themeToggle,
  ) =>
      SolidThemeToggleHelpers.getCurrentThemeMode(
        usesInternalManagement,
        solidThemeNotifier,
        themeToggle,
      );

  /// Gets theme toggle callback.

  static VoidCallback? getThemeToggleCallback(
    bool usesInternalManagement,
    SolidThemeNotifier solidThemeNotifier,
    SolidThemeToggleConfig? themeToggle,
  ) =>
      SolidThemeToggleHelpers.getThemeToggleCallback(
        usesInternalManagement,
        solidThemeNotifier,
        themeToggle,
      );

  /// Checks if uses internal management.

  static bool getUsesInternalManagement(SolidThemeToggleConfig? themeToggle) =>
      SolidThemeToggleHelpers.getUsesInternalManagement(themeToggle);

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
    bool showLogout = true,
    bool showLogin = true,
    void Function(BuildContext)? onLogout,
    void Function(BuildContext)? onLogin,
    required BoxConstraints constraints,
    bool? enableProfileOverride,
    SolidInviteOthersConfig? inviteConfig,
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
      showLogout: showLogout,
      showLogin: showLogin,
      onLogout: onLogout,
      onLogin: onLogin,
      constraints: constraints,
      enableProfileOverride: enableProfileOverride,
      inviteConfig: inviteConfig,
    );
  }

  /// Gets version to display.

  static String getVersionToDisplay(bool isVersionLoaded, String? appVersion) {
    if (isVersionLoaded && appVersion != null) return appVersion;
    return '0.0.0+0';
  }

  /// Checks if should show version.

  static bool shouldShowVersion(bool isVersionLoaded) => isVersionLoaded;
}
