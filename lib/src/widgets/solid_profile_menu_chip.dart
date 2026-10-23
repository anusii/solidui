/// Solid Profile Menu Chip — the avatar menu on the right of the AppBar.
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
/// Authors: Tony Chen, Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidpod/solidpod.dart'
    show NotLoggedInException, getWebId, isUserLoggedIn;

import 'package:solidui/src/handlers/solid_auth_handler.dart';
import 'package:solidui/src/services/solid_profile_notifier.dart';
import 'package:solidui/src/utils/is_desktop.dart';
import 'package:solidui/src/utils/snack_bar.dart';
import 'package:solidui/src/widgets/change_password_dialog.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';
import 'package:solidui/src/widgets/solid_backup_dialog.dart';
import 'package:solidui/src/widgets/solid_pod_refresh.dart';
import 'package:solidui/src/widgets/solid_preferences_dialog.dart';
import 'package:solidui/src/widgets/solid_profile_avatar.dart';
import 'package:solidui/src/widgets/solid_profile_editor.dart';

/// Avatar chip surfaced on the right of the AppBar when user profiles
/// are enabled. Tapping the avatar opens a small popup menu that hosts
/// the Profile entry (display name, avatar, and privacy controls), the
/// Settings entry (the app's own preferences) and an auth entry
/// (Logout when signed in, Login when signed out).

class SolidProfileMenuChip extends StatefulWidget {
  final bool showLogout;
  final bool showLogin;
  final void Function(BuildContext)? onLogout;
  final void Function(BuildContext)? onLogin;

  /// The About configuration, read for which settings sections this app
  /// offers. Settings is left out of the menu when it offers none.

  final SolidAboutConfig? aboutConfig;

  /// Offers Refresh from Pod when given. See
  /// [SolidAppBarConfig.onRefreshFromPod].

  final Future<bool> Function()? onRefreshFromPod;

  const SolidProfileMenuChip({
    super.key,
    required this.showLogout,
    required this.showLogin,
    required this.onLogout,
    required this.onLogin,
    required this.aboutConfig,
    this.onRefreshFromPod,
  });

  @override
  State<SolidProfileMenuChip> createState() => SolidProfileMenuChipState();
}

class SolidProfileMenuChipState extends State<SolidProfileMenuChip> {
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

  /// Whether this app offers any settings section of its own. The window
  /// size section is desktop-only, so on the web an app that has turned off
  /// both preference flags has nothing to show and no Settings entry.

  bool get _hasSettings {
    final config = widget.aboutConfig;

    return isDesktop ||
        (config?.showLayoutPreferences ?? true) ||
        (config?.showMenuLayoutPreferences ?? true);
  }

  void _handleSelection(String value) {
    switch (value) {
      case 'profile':
        SolidProfileEditor.show(context);
        break;
      case 'settings':
        SolidPreferencesDialog.show(
          context,
          showAppBarSection: widget.aboutConfig?.showLayoutPreferences ?? true,
          showMenuSection:
              widget.aboutConfig?.showMenuLayoutPreferences ?? true,
          scaffoldMenuInBottomBar:
              widget.aboutConfig?.scaffoldMenuInBottomBar ?? true,
        );
        break;
      case 'refresh_from_pod':
        handleSolidPodRefresh(
          context: context,
          onRefresh: widget.onRefreshFromPod!,
        );
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

  /// Opens the Change Pod Password dialog. The dialog itself reports the
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
        'You must be signed in to change your Pod password.',
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
        // Bold title, then the tip, as every Markdown tooltip has.
        final tooltipMessage = '**Profile**\n\n'
            '${hasName ? 'Signed in as $displayName. ' : ''}'
            'Tap to manage your profile, settings, and session.';

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

              // Profile — always available; opens the profile editor
              // dialog hosting display name, avatar and privacy.
              //
              // 20260913 gjw Called Settings until the app's own settings
              // moved here from the About dialogue, which left the one word
              // naming two unrelated dialogues. This one edits the profile,
              // so that is what it is now called.

              items.add(
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: MarkdownTooltip(
                    message: '**Profile**\n\n'
                        'Manage your profile — display name, avatar, and '
                        'privacy controls.',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Profile'),
                      ],
                    ),
                  ),
                ),
              );

              // Settings — this app's own preferences, in whichever
              // sections it offers.

              if (_hasSettings) {
                items.add(
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: MarkdownTooltip(
                      message: '**Settings**\n\n'
                          'Customise which buttons appear in the AppBar, '
                          'where the menu sits on a narrow screen, and the '
                          'size of the app window on the desktop.',
                      child: Row(
                        children: [
                          Icon(Icons.settings_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Settings'),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Refresh from Pod — only meaningful while signed in, and only
              // when the app says how to reload its data.
              //
              // 20261017 gjw Above Change Pod Password: like it and Backup,
              // it is about the Pod session rather than any one screen.

              if (widget.onRefreshFromPod != null &&
                  (!_statusLoaded || _isLoggedIn)) {
                items.add(const PopupMenuDivider());
                items.add(
                  const PopupMenuItem<String>(
                    value: 'refresh_from_pod',
                    child: MarkdownTooltip(
                      message: '**Refresh from Pod**\n\n'
                          'Reload your data from your Pod, picking up any '
                          'changes made on another device or by another '
                          'app.',
                      child: Row(
                        children: [
                          Icon(Icons.cloud_sync_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Refresh from Pod'),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Change Pod Password — only meaningful while signed in. The
              // tooltip warns that the password is shared across every
              // application that uses this Pod, so a change here affects the
              // ability to log in to all of them.

              // 20261017 gjw No divider after Refresh from Pod: the two go
              // together, both being about the Pod itself.

              if (!_statusLoaded || _isLoggedIn) {
                if (widget.onRefreshFromPod == null) {
                  items.add(const PopupMenuDivider());
                }
                items.add(
                  const PopupMenuItem<String>(
                    value: 'change_password',
                    child: MarkdownTooltip(
                      message: '**Change Pod Password**\n\n'
                          'Change the password of your Pod account.\n\n'
                          '**Important:** this password is shared across '
                          '**all** applications that use this Pod. Changing it '
                          'here changes it everywhere, so you will need the '
                          'new password to sign in to every Pod application '
                          'in future.',
                      // 20260913 gjw Flexible so the longest label in the menu
                      // wraps rather than overflowing the popup, which is only
                      // as wide as the window allows.
                      child: Row(
                        children: [
                          Icon(Icons.lock_reset, size: 20),
                          SizedBox(width: 12),
                          Flexible(child: Text('Change Pod Password')),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Backup — only meaningful while signed in. Opens a dialog to
              // export the app's data folder as a single encrypted, compressed
              // file, or to restore such a backup (from this Pod or another).
              //
              // 20261017 gjw No divider before it: Refresh from Pod, Change Pod
              // Password and Backup Pod are one group, all about the Pod.

              if (!_statusLoaded || _isLoggedIn) {
                items.add(
                  const PopupMenuItem<String>(
                    value: 'backup',
                    child: MarkdownTooltip(
                      message: '**Backup Pod**\n\n'
                          'Export all of this app\'s data in your Pod to a '
                          'single encrypted, compressed backup file — or '
                          'restore a backup created here or on another Pod.',
                      child: Row(
                        children: [
                          Icon(Icons.backup_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Backup Pod'),
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
                            'Sign out of your current Pod session on this '
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
                          'Sign in to your Pod to access your data.',
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
