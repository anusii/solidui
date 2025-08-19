/// Solid Status Bar.
///
// Time-stamp: <Monday 2025-08-11 15:30:00 +1000 Tony Chen>
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
import 'package:gap/gap.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/navigation.dart';
import 'solid_status_bar_models.dart';

/// A responsive status bar component for Solid applications.

class SolidStatusBar extends StatelessWidget {
  /// Status bar configuration.

  final SolidStatusBarConfig config;

  const SolidStatusBar({
    super.key,
    required this.config,
  });

  /// Determines the layout mode based on screen width.

  SolidStatusBarLayout _getLayoutMode(double screenWidth) {
    if (screenWidth < NavigationConstants.veryNarrowScreenThreshold) {
      return SolidStatusBarLayout.narrow;
    } else if (screenWidth < NavigationConstants.narrowScreenThreshold) {
      return SolidStatusBarLayout.medium;
    } else {
      return SolidStatusBarLayout.wide;
    }
  }

  /// Determines if the status bar should be visible based on screen width.

  bool _shouldShowStatusBar(double screenWidth) {
    if (config.showOnNarrowScreens) return true;
    
    final threshold = config.narrowScreenThreshold ?? 
        NavigationConstants.narrowScreenThreshold;
    
    return screenWidth > threshold;
  }

  /// Launches a URL in the default browser.

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Creates an interactive text widget.

  Widget _createInteractiveText({
    required BuildContext context,
    required String text,
    VoidCallback? onTap,
    TextStyle? style,
  }) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.primary,
    ) ?? const TextStyle(fontSize: 14, color: Colors.blue);

    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: style ?? defaultStyle,
      ),
    );
  }

  /// Builds the server information widget.

  Widget? _buildServerInfo(BuildContext context) {
    final serverInfo = config.serverInfo;
    if (serverInfo == null) return null;

    final theme = Theme.of(context);
    final displayText = serverInfo.displayText ?? serverInfo.serverUri;

    return MarkdownTooltip(
      message: serverInfo.tooltip,
      child: _createInteractiveText(
        context: context,
        text: displayText,
        onTap: serverInfo.isClickable 
            ? () => _launchUrl(serverInfo.serverUri)
            : null,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  /// Builds the login status widget.

  Widget? _buildLoginStatus(BuildContext context) {
    final loginStatus = config.loginStatus;
    if (loginStatus == null) return null;

    final theme = Theme.of(context);

    return MarkdownTooltip(
      message: loginStatus.tooltip,
      child: _createInteractiveText(
        context: context,
        text: 'Login Status: ${loginStatus.displayText}',
        onTap: loginStatus.onTap,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: loginStatus.isLoggedIn
              ? theme.colorScheme.tertiary
              : theme.colorScheme.error,
        ),
      ),
    );
  }

  /// Builds the security key status widget.

  Widget? _buildSecurityKeyStatus(BuildContext context) {
    final securityKeyStatus = config.securityKeyStatus;
    if (securityKeyStatus == null) return null;

    final theme = Theme.of(context);

    return MarkdownTooltip(
      message: securityKeyStatus.tooltip,
      child: _createInteractiveText(
        context: context,
        text: securityKeyStatus.displayText,
        onTap: securityKeyStatus.onTap,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: securityKeyStatus.isKeySaved
              ? theme.colorScheme.tertiary
              : theme.colorScheme.error,
        ),
      ),
    );
  }

  /// Builds custom status bar items.

  List<Widget> _buildCustomItems() {
    final sortedItems = List<SolidCustomStatusBarItem>.from(config.customItems);
    sortedItems.sort((a, b) => a.priority.compareTo(b.priority));
    return sortedItems.map((item) => item.widget).toList();
  }

  /// Builds the narrow layout (vertical stack).

  Widget _buildNarrowLayout(BuildContext context) {
    final theme = Theme.of(context);
    final items = <Widget>[];

    final serverInfo = _buildServerInfo(context);
    if (serverInfo != null) items.add(serverInfo);

    final loginStatus = _buildLoginStatus(context);
    if (loginStatus != null) items.add(loginStatus);

    final securityKeyStatus = _buildSecurityKeyStatus(context);
    if (securityKeyStatus != null) items.add(securityKeyStatus);

    items.addAll(_buildCustomItems());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, color: theme.dividerColor),
        Container(
          color: config.backgroundColor ?? theme.colorScheme.surface,
          height: config.narrowLayoutHeight,
          padding: config.padding,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .expand((item) => [item, Gap(2)])
                  .take(items.length * 2 - 1)
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the medium layout (mixed vertical and horizontal).

  Widget _buildMediumLayout(BuildContext context) {
    final theme = Theme.of(context);
    final serverInfo = _buildServerInfo(context);
    final loginStatus = _buildLoginStatus(context);
    final securityKeyStatus = _buildSecurityKeyStatus(context);
    final customItems = _buildCustomItems();

    final bottomItems = <Widget>[];
    if (loginStatus != null) bottomItems.add(loginStatus);
    if (securityKeyStatus != null) bottomItems.add(securityKeyStatus);
    bottomItems.addAll(customItems);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, color: theme.dividerColor),
        Container(
          color: config.backgroundColor ?? theme.colorScheme.surface,
          height: config.mediumLayoutHeight,
          padding: config.padding,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (serverInfo != null) ...[
                  serverInfo,
                  Gap(4),
                ],
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: bottomItems
                        .expand((item) => [item, Gap(config.itemSpacing)])
                        .take(bottomItems.length * 2 - 1)
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the wide layout (horizontal row).

  Widget _buildWideLayout(BuildContext context) {
    final theme = Theme.of(context);
    final serverInfo = _buildServerInfo(context);
    final loginStatus = _buildLoginStatus(context);
    final securityKeyStatus = _buildSecurityKeyStatus(context);
    final customItems = _buildCustomItems();

    final rightItems = <Widget>[];
    if (loginStatus != null) rightItems.add(loginStatus);
    if (securityKeyStatus != null) rightItems.add(securityKeyStatus);
    rightItems.addAll(customItems);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, color: theme.dividerColor),
        Container(
          color: config.backgroundColor ?? theme.colorScheme.surface,
          height: config.wideLayoutHeight,
          padding: config.padding,
          child: Row(
            children: [
              if (serverInfo != null) Expanded(child: serverInfo),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: rightItems
                    .expand((item) => [item, Gap(config.itemSpacing)])
                    .take(rightItems.length * 2 - 1)
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // Don't show status bar if it should be hidden on narrow screens

        if (!_shouldShowStatusBar(screenWidth)) {
          return const SizedBox.shrink();
        }

        final layout = _getLayoutMode(screenWidth);

        switch (layout) {
          case SolidStatusBarLayout.narrow:
            return _buildNarrowLayout(context);
          case SolidStatusBarLayout.medium:
            return _buildMediumLayout(context);
          case SolidStatusBarLayout.wide:
            return _buildWideLayout(context);
        }
      },
    );
  }
}
