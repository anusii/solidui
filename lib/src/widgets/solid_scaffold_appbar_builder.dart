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
import 'package:solidpod/solidpod.dart' show getWebId, isUserLoggedIn;

import 'package:solidui/src/handlers/solid_auth_handler.dart';
import 'package:solidui/src/services/solid_profile_notifier.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_invite_others_models.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_profile_avatar.dart';
import 'package:solidui/src/widgets/solid_profile_editor.dart';
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
    void Function(BuildContext)? onLogout,
    void Function(BuildContext)? onLogin,
    required BoxConstraints constraints,
    bool? enableProfileOverride,
    SolidInviteOthersConfig? inviteConfig,
  }) {
    final profileEnabled = enableProfileOverride ?? config.enableProfile;

    SolidAppBarActionsManager.initializeIfNeeded(
      config,
      themeToggle,
      hasLogout: showLogout,
      hasLogin: showLogin,
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
      showLogin: showLogin,
      onLogout: onLogout,
      onLogin: onLogin,
      inviteConfig: inviteConfig,
      profileEnabled: profileEnabled,
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
    );

    // Append the profile avatar when enabled — rightmost position.

    if (profileEnabled) {
      actions.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _ProfileMenuChip(
            showLogout: showLogout,
            showLogin: showLogin,
            onLogout: onLogout,
            onLogin: onLogin,
          ),
        ),
      );
    }

    return AppBar(
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
      actions: actions.isEmpty ? null : actions,
    );
  }
}

/// Avatar chip surfaced on the right of the AppBar when user profiles
/// are enabled. Tapping the avatar opens a small popup menu that hosts
/// the Settings entry (which opens the existing profile editor with
/// display name, avatar, and privacy controls) and an auth entry
/// (Logout when signed in, Login when signed out).

class _ProfileMenuChip extends StatefulWidget {
  final bool showLogout;
  final bool showLogin;
  final void Function(BuildContext)? onLogout;
  final void Function(BuildContext)? onLogin;

  const _ProfileMenuChip({
    required this.showLogout,
    required this.showLogin,
    required this.onLogout,
    required this.onLogin,
  });

  @override
  State<_ProfileMenuChip> createState() => _ProfileMenuChipState();
}

class _ProfileMenuChipState extends State<_ProfileMenuChip> {
  bool _isLoggedIn = false;
  bool _statusLoaded = false;

  @override
  void initState() {
    super.initState();
    _refreshLoginStatus();
  }

  /// Refreshes the cached login status used to decide which auth
  /// entry to render in the popup. Errors are swallowed and treated
  /// as "logged out" so the avatar remains usable when the auth
  /// stack is unavailable.

  Future<void> _refreshLoginStatus() async {
    try {
      final webId = await getWebId();
      if (webId == null || webId.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoggedIn = false;
            _statusLoaded = true;
          });
        }
        return;
      }
      final loggedIn = await isUserLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = loggedIn;
          _statusLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('ProfileMenuChip: login status check failed: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _statusLoaded = true;
        });
      }
    }
  }

  void _handleSelection(String value) {
    switch (value) {
      case 'settings':
        SolidProfileEditor.show(context);
        break;
      case 'logout':
        if (widget.onLogout != null) {
          widget.onLogout!(context);
        } else {
          SolidAuthHandler.instance.handleLogout(context);
        }
        break;
      case 'login':
        if (widget.onLogin != null) {
          widget.onLogin!(context);
        } else {
          SolidAuthHandler.instance.handleLogin(context);
        }
        break;
    }

    // Refresh after the action so the popup reflects the new state
    // the next time the avatar is tapped.

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _refreshLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: solidProfileNotifier,
      builder: (context, _) {
        final displayName = solidProfileNotifier.displayName?.trim();
        final hasName = displayName != null && displayName.isNotEmpty;
        final tooltipMessage = hasName
            ? '**$displayName**\n\nTap to manage your profile.'
            : 'Tap to manage your profile, settings, and session.';

        return MarkdownTooltip(
          message: tooltipMessage,
          child: PopupMenuButton<String>(
            tooltip: '',
            position: PopupMenuPosition.under,
            offset: const Offset(0, 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onOpened: _refreshLoginStatus,
            onSelected: _handleSelection,
            itemBuilder: (menuContext) {
              final items = <PopupMenuEntry<String>>[];

              // Settings — always available; opens the profile editor
              // dialog hosting display name, avatar and privacy.

              items.add(
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined, size: 20),
                      SizedBox(width: 12),
                      Text('Settings'),
                    ],
                  ),
                ),
              );

              // Auth entry — Logout when signed in, Login otherwise.
              // Both entries respect the scaffold's showLogout /
              // showLogin flags so applications using a dedicated
              // login screen can suppress the Login entry here.

              if (!_statusLoaded || _isLoggedIn) {
                if (widget.showLogout) {
                  items.add(const PopupMenuDivider());
                  items.add(
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 12),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  );
                }
              } else if (widget.showLogin) {
                items.add(const PopupMenuDivider());
                items.add(
                  const PopupMenuItem<String>(
                    value: 'login',
                    child: Row(
                      children: [
                        Icon(Icons.login, size: 20),
                        SizedBox(width: 12),
                        Text('Login'),
                      ],
                    ),
                  ),
                );
              }

              return items;
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: SolidProfileAvatar(size: 32),
            ),
          ),
        );
      },
    );
  }
}
