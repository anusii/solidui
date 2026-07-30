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
import 'package:solidpod/solidpod.dart'
    show NotLoggedInException, getWebId, isUserLoggedIn;
import 'package:url_launcher/url_launcher.dart';

import 'package:solidui/src/handlers/solid_auth_handler.dart';
import 'package:solidui/src/services/solid_profile_notifier.dart';
import 'package:solidui/src/utils/snack_bar.dart';
import 'package:solidui/src/widgets/change_password_dialog.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_backup_dialog.dart';
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
    bool showNotifications = false,
    void Function(BuildContext)? onLogout,
    void Function(BuildContext)? onLogin,
    required BoxConstraints constraints,
    bool? enableProfileOverride,
    SolidInviteOthersConfig? inviteConfig,
    bool enableOverflowMenu = true,
  }) {
    final profileEnabled = enableProfileOverride ?? config.enableProfile;

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
  String? _webId;

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
            _webId = null;
          });
        }
        return;
      }
      final loggedIn = await isUserLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = loggedIn;
          _statusLoaded = true;
          _webId = webId;
        });
      }
    } catch (e) {
      debugPrint('ProfileMenuChip: login status check failed: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _statusLoaded = true;
          _webId = null;
        });
      }
    }
  }

  void _handleSelection(String value) {
    switch (value) {
      case 'settings':
        SolidProfileEditor.show(context);
        break;
      case 'change_password':
        _handleChangePassword();
        break;
      case 'backup':
        SolidBackupDialog.show(context);
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

  /// Opens the Change POD Password dialog. The dialog itself reports the
  /// outcome via a snack bar; this only guards against the user no longer
  /// being signed in (the entry should not be reachable in that case, but the
  /// underlying call throws [NotLoggedInException] defensively).

  Future<void> _handleChangePassword() async {
    try {
      // In dialog mode the [child] argument is only used as a navigation
      // target on cancel in fullscreen mode, so an empty placeholder suffices.

      await changePasswordPopup(context, const SizedBox.shrink());
    } on NotLoggedInException {
      if (!mounted) return;
      showSnackBar(
        context,
        'You must be signed in to change your POD password.',
        Colors.red,
      );
    }
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
                  child: MarkdownTooltip(
                    message: '**Profile Settings**\n\n'
                        'Manage your profile — display name, avatar, webid, and '
                        'privacy controls.',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('Profile Settings'),
                      ],
                    ),
                  ),
                ),
              );

              // Change POD Password — only meaningful while signed in. The
              // tooltip warns that the password is shared across every
              // application that uses this POD, so a change here affects the
              // ability to log in to all of them.

              if (!_statusLoaded || _isLoggedIn) {
                items.add(const PopupMenuDivider());
                items.add(
                  const PopupMenuItem<String>(
                    value: 'change_password',
                    child: MarkdownTooltip(
                      message: '**Change POD Password**\n\n'
                          'Change the password of your POD account.\n\n'
                          '**Important:** this password is shared across '
                          '**all** applications that use this POD. Changing it '
                          'here changes it everywhere, so you will need the '
                          'new password to sign in to every POD application '
                          'in future.',
                      child: Row(
                        children: [
                          Icon(Icons.lock_reset, size: 20),
                          SizedBox(width: 12),
                          Text('Change POD Password'),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Backup — only meaningful while signed in. Opens a dialog to
              // export the app's data folder as a single encrypted, compressed
              // file, or to restore such a backup (from this POD or another).

              if (!_statusLoaded || _isLoggedIn) {
                items.add(const PopupMenuDivider());
                items.add(
                  const PopupMenuItem<String>(
                    value: 'backup',
                    child: MarkdownTooltip(
                      message: '**Backup**\n\n'
                          'Export all of this app\'s data in your POD to a '
                          'single encrypted, compressed backup file — or '
                          'restore a backup created here or on another POD.',
                      child: Row(
                        children: [
                          Icon(Icons.backup_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Backup'),
                        ],
                      ),
                    ),
                  ),
                );
              }

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
                      child: MarkdownTooltip(
                        message: '**Logout**\n\n'
                            'Sign out of your current POD session on this '
                            'device.',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 12),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              } else if (widget.showLogin) {
                items.add(const PopupMenuDivider());
                items.add(
                  const PopupMenuItem<String>(
                    value: 'login',
                    child: MarkdownTooltip(
                      message: '**Login**\n\n'
                          'Sign in to your POD to access your data.',
                      child: Row(
                        children: [
                          Icon(Icons.login, size: 20),
                          SizedBox(width: 12),
                          Text('Login'),
                        ],
                      ),
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
