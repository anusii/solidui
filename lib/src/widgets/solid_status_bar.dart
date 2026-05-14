/// Solid Status Bar.
///
// Time-stamp: <Thursday 2026-03-26 09:23:47 +1100 Graham Williams>
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
import 'package:solidpod/solidpod.dart' show isUserLoggedIn;
import 'package:solidui/src/constants/navigation.dart';
import 'package:solidui/src/handlers/solid_auth_handler.dart';
import 'package:solidui/src/utils/solid_notifications.dart';
import 'package:solidui/src/widgets/solid_security_key_cache_dialogs.dart';
import 'package:solidui/src/widgets/solid_security_key_manager.dart';
import 'package:solidui/src/widgets/solid_status_bar_models.dart';
import 'package:url_launcher/url_launcher.dart';

/// A responsive status bar component for Solid applications.

class SolidStatusBar extends StatelessWidget {
  /// Status bar configuration.

  final SolidStatusBarConfig config;

  const SolidStatusBar({super.key, required this.config});

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

  /// Returns a readable status colour that works in both light and dark modes.

  Color _statusColor(BuildContext context, {required bool active}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (active) {
      return isDark
          ? const Color(0xFF66BB6A)
          : Theme.of(context).colorScheme.tertiary;
    }

    return isDark
        ? const Color(0xFFEF9A9A)
        : Theme.of(context).colorScheme.error;
  }

  /// Creates an interactive text widget.

  Widget _createInteractiveText({
    required BuildContext context,
    required String text,
    VoidCallback? onTap,
    TextStyle? style,
  }) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontSize: 13,
        ) ??
        const TextStyle(fontSize: 13, color: Colors.blue);

    final child = Text(text, style: style ?? defaultStyle);
    if (onTap == null) return child;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: child),
    );
  }

  /// Builds the server information widget.

  Widget? _buildServerInfo(BuildContext context) {
    final serverInfo = config.serverInfo;
    if (serverInfo == null) return null;

    final theme = Theme.of(context);
    final displayText = serverInfo.effectiveDisplayText;

    return MarkdownTooltip(
      message: serverInfo.tooltipText,
      child: _createInteractiveText(
        context: context,
        text: displayText,
        onTap: serverInfo.isClickable
            ? () => _launchUrl(serverInfo.serverUri)
            : null,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontSize: 13,
        ),
      ),
    );
  }

  /// Builds the login status widget.

  Widget? _buildLoginStatus(BuildContext context) {
    final loginStatus = config.loginStatus;
    if (loginStatus == null) return null;

    final theme = Theme.of(context);

    final statusColor = _statusColor(context, active: loginStatus.isLoggedIn);

    return MarkdownTooltip(
      message: loginStatus.tooltipText,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: loginStatus.onTap ??
              () => SolidAuthHandler.instance.handleAuthAction(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(6),
              Text(
                loginStatus.displayText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the security key status widget.

  Widget? _buildSecurityKeyStatus(BuildContext context) {
    final securityKeyStatus = config.securityKeyStatus;
    if (securityKeyStatus == null) return null;

    final theme = Theme.of(context);

    // Determine the onTap handler.

    VoidCallback? onTap = securityKeyStatus.onTap;

    // If no custom tap handler is provided, use built-in security key management

    onTap ??= () => _showSecurityKeyManager(context, securityKeyStatus);

    final statusColor = _statusColor(
      context,
      active: securityKeyStatus.isKeySaved == true,
    );

    return MarkdownTooltip(
      message: securityKeyStatus.tooltipText,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                securityKeyStatus.isKeySaved == true
                    ? Icons.key
                    : Icons.key_off,
                size: 14,
                color: statusColor,
              ),
              const Gap(5),
              Text(
                securityKeyStatus.displayText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows the built-in security key manager dialogue.

  Future<void> _showSecurityKeyManager(
    BuildContext context,
    SolidSecurityKeyStatus config,
  ) async {
    // Check user login status before showing the security key manager.

    final isLoggedIn = await isUserLoggedIn();
    if (!context.mounted) return;

    if (!isLoggedIn) {
      // User is not logged in - show login required dialog.

      final shouldLogin =
          await SecurityKeyCacheDialogs.showLoginRequiredDialog(context);
      if (shouldLogin && context.mounted) {
        await SolidAuthHandler.instance.handleLogin(context);
      }
      return;
    }

    // User is logged in - proceed to show the security key manager.

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) => SolidSecurityKeyManager(
        config: SolidSecurityKeyManagerConfig(
          appWidget: config.appWidget ??
              const SizedBox(), // Provide default empty widget
          title: config.title ?? 'Security Key Management',
        ),
        onKeyStatusChanged: (bool hasKey) {
          config.onKeyStatusChanged?.call(hasKey);
          _refreshParentSecurityKeyStatus(context, hasKey);

          debugPrint('Security key status changed: $hasKey');
        },
      ),
    );
  }

  /// Refreshes the security key status in the parent SolidScaffold.

  void _refreshParentSecurityKeyStatus(BuildContext context, bool isKeySaved) {
    try {
      // Send a notification to trigger status refresh with actual key status.

      SecurityKeyStatusChangedNotification(
        isKeySaved: isKeySaved,
      ).dispatch(context);
    } catch (e) {
      debugPrint('Could not refresh parent security key status: $e');
    }
  }

  /// Builds custom status bar items.

  List<Widget> _buildCustomItems() {
    final sortedItems = List<SolidCustomStatusBarItem>.from(config.customItems);
    sortedItems.sort((a, b) => a.priority.compareTo(b.priority));
    return sortedItems.map((item) => item.widget).toList();
  }

  /// Builds the narrow layout (vertical stack).

  Widget _buildNarrowLayout(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = <Widget>[];

    final serverInfo = _buildServerInfo(context);
    if (serverInfo != null) items.add(serverInfo);

    final loginStatus = _buildLoginStatus(context);
    if (loginStatus != null) items.add(loginStatus);

    final securityKeyStatus = _buildSecurityKeyStatus(context);
    if (securityKeyStatus != null) items.add(securityKeyStatus);

    items.addAll(_buildCustomItems());

    return _statusContainer(
      cs: cs,
      height: config.narrowLayoutHeight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .expand((item) => [item, const Gap(2)])
              .take(items.length * 2 - 1)
              .toList(),
        ),
      ),
    );
  }

  /// Builds the medium layout (mixed vertical and horizontal).

  Widget _buildMediumLayout(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final serverInfo = _buildServerInfo(context);
    final loginStatus = _buildLoginStatus(context);
    final securityKeyStatus = _buildSecurityKeyStatus(context);
    final customItems = _buildCustomItems();

    final bottomItems = <Widget>[];
    if (loginStatus != null) bottomItems.add(loginStatus);
    if (securityKeyStatus != null) bottomItems.add(securityKeyStatus);
    bottomItems.addAll(customItems);

    return _statusContainer(
      cs: cs,
      height: config.mediumLayoutHeight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (serverInfo != null) ...[serverInfo, const Gap(4)],
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _interleaveWithSeparator(bottomItems, cs),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the wide layout (horizontal row).

  Widget _buildWideLayout(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final serverInfo = _buildServerInfo(context);
    final loginStatus = _buildLoginStatus(context);
    final securityKeyStatus = _buildSecurityKeyStatus(context);
    final customItems = _buildCustomItems();

    final rightItems = <Widget>[];
    if (loginStatus != null) rightItems.add(loginStatus);
    if (securityKeyStatus != null) rightItems.add(securityKeyStatus);
    rightItems.addAll(customItems);

    return _statusContainer(
      cs: cs,
      height: config.wideLayoutHeight,
      child: Row(
        children: [
          Expanded(child: serverInfo ?? const SizedBox.shrink()),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _interleaveWithSeparator(rightItems, cs),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Wraps content in a consistent status bar container with a subtle top
  /// border and surface background.

  Widget _statusContainer({
    required ColorScheme cs,
    required double height,
    required Widget child,
  }) =>
      Container(
        height: height,
        padding: config.padding,
        decoration: BoxDecoration(
          color: config.backgroundColor ?? cs.surface,
          border: Border(
            top: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: child,
      );

  /// Interleaves a list of widgets with subtle separator dots.

  List<Widget> _interleaveWithSeparator(List<Widget> items, ColorScheme cs) {
    if (items.isEmpty) return items;
    final sep = Padding(
      padding: EdgeInsets.symmetric(horizontal: config.itemSpacing / 2),
      child: Text(
        '·',
        style: TextStyle(
          color: cs.onSurfaceVariant.withValues(alpha: 0.4),
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
    );

    return [
      for (int i = 0; i < items.length; i++) ...[
        items[i],
        if (i < items.length - 1) sep,
      ],
    ];
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
