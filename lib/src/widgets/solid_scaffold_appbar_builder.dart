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

import 'package:solidui/src/services/solid_login_status_notifier.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_invite_others_models.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_profile_menu_chip.dart';
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
    bool showLogin = true,
    bool showNotifications = false,
    void Function(BuildContext)? onLogout,
    void Function(BuildContext)? onLogin,
    required BoxConstraints constraints,
    bool? enableProfileOverride,
    SolidInviteOthersConfig? inviteConfig,
    bool enableOverflowMenu = true,
  }) {
    final profileEnabled = enableProfileOverride ?? config.enableProfile;

    // 20261004 gjw Tint the drawer button while a session is live.
    //
    // On a narrow screen the status bar's "Logged In" is not visible and the
    // navigation collapses to the hamburger, leaving nothing at all to say
    // whether the app is connected to a Pod. This is that missing signal.
    //
    // Read from solidLoginStatusNotifier, NOT from a stored WebID. The
    // notifier requires getWebId() AND isUserLoggedIn(), so it goes false the
    // moment a session dies; a WebID alone would leave the icon claiming a
    // connection that no longer works — the very confusion this release is
    // fixing elsewhere. SolidScaffold listens to the notifier, so the bar is
    // rebuilt when it changes.

    final isLoggedIn = solidLoginStatusNotifier.isLoggedIn;

    // Publish the overflow setting so that downstream UI such as the
    // preferences dialogue (opened from the About dialogue) can read the
    // current scaffold's choice without direct parameter plumbing.

    SolidAppBarOverflowController.isEnabled = enableOverflowMenu;

    SolidAppBarActionsManager.initializeIfNeeded(
      config,
      themeToggle,
      hasLogout: showLogout,
      hasLogin: showLogin,
      hasNotifications: showNotifications,
      inviteConfig: inviteConfig,
      profileEnabled: profileEnabled,
    );

    final layoutWidth = constraints.maxWidth;
    final isNarrowScreen = hideNavRail ||
        SolidScaffoldHelpers.isNarrowScreen(
          constraints,
          narrowThreshold: narrowScreenThreshold,
        ) ||
        SolidScaffoldHelpers.isVeryNarrowScreen(constraints);

    List<Widget> actions = [];

    if (config.versionConfig != null &&
        layoutWidth >= config.veryNarrowScreenThreshold &&
        shouldShowVersion) {
      actions.add(
        SolidScaffoldHelpers.buildVersionWidget(
          config,
          versionToDisplay,
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
      showLogin: showLogin,
      showNotifications: showNotifications,
      onLogout: onLogout,
      onLogin: onLogin,
      inviteConfig: inviteConfig,
      profileEnabled: profileEnabled,
      enableOverflowMenu: enableOverflowMenu,
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
      showLogin: showLogin,
      onLogout: onLogout,
      onLogin: onLogin,
      inviteConfig: inviteConfig,
      profileEnabled: profileEnabled,
      enableOverflowMenu: enableOverflowMenu,
    );

    // Append the profile avatar when enabled — rightmost position.

    if (profileEnabled) {
      actions.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SolidProfileMenuChip(
            showLogout: showLogout,
            showLogin: showLogin,
            onLogout: onLogout,
            onLogin: onLogin,
            aboutConfig: aboutConfig,
            onRefreshFromPod: config.onRefreshFromPod,
          ),
        ),
      );
    }

    final appBar = AppBar(
      title: Text(
        config.title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          fontSize: 18,
          color: config.backgroundColor != null
              ? ThemeData.estimateBrightnessForColor(config.backgroundColor!) ==
                      Brightness.dark
                  ? Colors.white
                  : Colors.black87
              : null,
        ),
      ),
      backgroundColor: config.backgroundColor,
      foregroundColor: config.backgroundColor != null
          ? ThemeData.estimateBrightnessForColor(config.backgroundColor!) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black87
          : null,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      automaticallyImplyLeading: isNarrowScreen,

      // The drawer button only. actionsIconTheme is pinned to the ordinary
      // foreground so the tint says "logged in" rather than colouring every
      // icon in the bar, which would say nothing at all.

      iconTheme: isLoggedIn
          ? IconThemeData(color: Theme.of(context).colorScheme.primary)
          : null,
      actionsIconTheme: isLoggedIn
          ? IconThemeData(color: Theme.of(context).appBarTheme.foregroundColor)
          : null,
      actions: actions.isEmpty ? null : actions,
    );

    // 20261005 gjw The tint alone was too subtle a sign of being logged in, so
    // the drawer button's three lines turn wavy while a session is live and
    // are the ordinary straight lines otherwise. ActionIconTheme swaps only
    // the glyph, so the button keeps its tooltip, semantics and tint. The
    // wrapping is the same whether or not the user is logged in, so a change
    // of state rebuilds rather than replaces the bar.

    return PreferredSize(
      preferredSize: appBar.preferredSize,
      child: ActionIconTheme(
        data: ActionIconThemeData(
          drawerButtonIconBuilder:
              isLoggedIn ? (_) => const Icon(Icons.water) : null,
        ),
        child: appBar,
      ),
    );
  }
}
