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

import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_scaffold_appbar_actions.dart';
import 'package:solidui/src/widgets/solid_scaffold_appbar_ordered_actions.dart';
import 'package:solidui/src/widgets/solid_scaffold_appbar_overflow.dart';
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
    bool showLogout = true,
    void Function(BuildContext)? onLogout,
    void Function(BuildContext)? onLogin,
    required BoxConstraints constraints,
  }) {
    SolidAppBarActionsManager.initializeIfNeeded(
      config,
      themeToggle,
      hasLogout: showLogout,
    );

    final layoutWidth = constraints.maxWidth;
    final isNarrowScreen = hideNavRail ||
        SolidScaffoldHelpers.isNarrowScreen(
          constraints,
          narrowThreshold: narrowScreenThreshold,
        ) ||
        SolidScaffoldHelpers.isVeryNarrowScreen(constraints);
    final theme = Theme.of(context);

    List<Widget> actions = [];

    if (config.versionConfig != null &&
        layoutWidth >= config.veryNarrowScreenThreshold &&
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

    final orderedActions = SolidAppBarOrderedActionsBuilder.build(
      config: config,
      layoutWidth: layoutWidth,
      themeToggle: themeToggle,
      currentThemeMode: currentThemeMode,
      themeToggleCallback: themeToggleCallback,
      aboutConfig: aboutConfig,
      context: context,
      showLogout: showLogout,
      onLogout: onLogout,
      onLogin: onLogin,
    );
    actions.addAll(orderedActions);

    SolidAppBarOverflowHandler.handleOverflowMenu(
      actions,
      config,
      layoutWidth,
      themeToggle,
      currentThemeMode,
      themeToggleCallback,
      aboutConfig,
      context,
      showLogout: showLogout,
      onLogout: onLogout,
      onLogin: onLogin,
    );

    return AppBar(
      title: Text(config.title),
      backgroundColor: config.backgroundColor,
      automaticallyImplyLeading: isNarrowScreen,
      actions: actions.isEmpty ? null : actions,
    );
  }
}
