/// Header builder for SolidNavDrawer widget.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
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
import 'package:version_widget/version_widget.dart';

import 'package:solidui/src/constants/navigation.dart';
import 'package:solidui/src/services/solid_profile_notifier.dart';
import 'package:solidui/src/widgets/solid_nav_drawer_url_helper.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_profile_avatar.dart';
import 'package:solidui/src/widgets/solid_profile_editor.dart';

/// Helper class for building the user info header in navigation drawer.

class SolidNavDrawerHeader {
  /// Builds the user info header widget.

  static Widget build({
    required BuildContext context,
    required ThemeData theme,
    required SolidNavUserInfo user,
    required bool isVersionLoaded,
    required String? appVersion,
    required String Function() getVersionToDisplay,
    VoidCallback? onUserNameTap,
  }) {
    final bool willShowVersion = user.versionConfig != null;
    final double bottomPadding =
        willShowVersion ? 8.0 : NavigationConstants.userHeaderBottomPadding;

    return Container(
      padding: EdgeInsets.only(
        top: NavigationConstants.userHeaderTopPadding +
            MediaQuery.paddingOf(context).top,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          if (user.enableProfile)
            SolidProfileAvatar(
              size: user.avatarSize ?? NavigationConstants.userAvatarSize,
              showEditBadge: true,
              onTap: () => SolidProfileEditor.show(context),
            )
          else
            user.avatar ??
                Icon(
                  user.avatarIcon ?? Icons.account_circle,
                  size: user.avatarSize ?? NavigationConstants.userAvatarSize,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
          const Gap(NavigationConstants.userInfoSpacing),
          if (user.enableProfile)
            _buildProfileName(theme, user)
          else
            _buildUserName(theme, user, onUserNameTap),
          if (user.showWebId && user.webId != null && user.webId!.isNotEmpty)
            ..._buildWebIdSection(context, theme, user),
          if (user.versionConfig != null)
            ..._buildVersionSection(
              context,
              theme,
              user.versionConfig!,
              isVersionLoaded,
              appVersion,
              getVersionToDisplay,
            ),
        ],
      ),
    );
  }

  /// Displays the display name from [solidProfileNotifier], falling back
  /// to the effective user name extracted from the WebID.

  static Widget _buildProfileName(ThemeData theme, SolidNavUserInfo user) {
    return ListenableBuilder(
      listenable: solidProfileNotifier,
      builder: (context, _) {
        final displayName = solidProfileNotifier.hasDisplayName
            ? solidProfileNotifier.displayName!
            : user.effectiveUserName;
        return Text(
          displayName,
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontSize: NavigationConstants.userNameFontSize,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }

  static Widget _buildUserName(
    ThemeData theme,
    SolidNavUserInfo user,
    VoidCallback? onUserNameTap,
  ) {
    final text = Text(
      user.effectiveUserName,
      style: TextStyle(
        color: theme.colorScheme.onPrimaryContainer,
        fontSize: NavigationConstants.userNameFontSize,
        fontWeight: FontWeight.w600,
      ),
    );

    if (onUserNameTap == null) return text;

    return InkWell(
      onTap: onUserNameTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: text,
      ),
    );
  }

  static List<Widget> _buildWebIdSection(
    BuildContext context,
    ThemeData theme,
    SolidNavUserInfo user,
  ) {
    return [
      const Gap(NavigationConstants.webIdSpacing),
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: NavigationConstants.webIdHorizontalPadding,
        ),
        child: InkWell(
          onTap: () => SolidNavDrawerUrlHelper.launchProfileUrl(user.webId!),
          child: Text(
            SolidNavDrawerUrlHelper.getSimplifiedUrl(user.webId!),
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.8,
              ),
              fontSize: NavigationConstants.webIdFontSize,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ];
  }

  static List<Widget> _buildVersionSection(
    BuildContext context,
    ThemeData theme,
    SolidVersionConfig versionConfig,
    bool isVersionLoaded,
    String? appVersion,
    String Function() getVersionToDisplay,
  ) {
    return [
      const Gap(NavigationConstants.webIdSpacing),
      if (isVersionLoaded && appVersion != null && appVersion.isNotEmpty)
        _buildVersionInfo(context, theme, versionConfig, getVersionToDisplay)
      else
        const SizedBox(height: 23.0),
    ];
  }

  static Widget _buildVersionInfo(
    BuildContext context,
    ThemeData theme,
    SolidVersionConfig versionConfig,
    String Function() getVersionToDisplay,
  ) {
    final versionString =
        (versionConfig.version != null && versionConfig.version!.isNotEmpty)
            ? versionConfig.version!
            : getVersionToDisplay();

    return VersionWidget(
      version: versionString,
      changelogUrl: versionConfig.changelogUrl,
      showVersion: versionConfig.showVersion,
      showDate: versionConfig.showDate,
      userTextStyle: versionConfig.userTextStyle,
      showUpdateButton: versionConfig.showUpdateButton,
      downloadUrl: versionConfig.downloadUrl,
      updateButtonLabel: versionConfig.updateButtonLabel,
    );
  }
}
