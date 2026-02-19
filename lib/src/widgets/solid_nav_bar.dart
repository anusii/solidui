/// Solid Navigation Bar.
///
// Time-stamp: <Sunday 2025-08-10 08:32:58 +1000 Graham Williams>
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

import 'package:solidui/src/constants/navigation.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';

/// A reusable navigation rail component designed for Solid POD applications.
///
/// This widget provides a left-side navigation rail that can be easily
/// integrated into different applications built for Solid Pods.

class SolidNavBar extends StatelessWidget {
  /// List of navigation tabs to display.

  final List<SolidNavTab> tabs;

  /// Currently selected tab index.

  final int? selectedIndex;

  /// Callback when a tab is selected.

  final void Function(int) onTabSelected;

  /// Optional callback to show alert dialogs.

  final void Function(BuildContext, String, String?)? onShowAlert;

  /// Optional custom minimum width for the navigation rail.

  final double? minWidth;

  /// Optional custom group alignment for navigation items.

  final double? groupAlignment;

  /// Optional custom icon size.

  final double? iconSize;

  /// Optional custom label font size.

  final double? labelFontSize;

  /// Optional custom Settings widget.

  final Widget? settingsWidget;

  /// Creates a [SolidNavBar] with the specified configuration.

  const SolidNavBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onShowAlert,
    this.minWidth,
    this.groupAlignment,
    this.iconSize,
    this.labelFontSize,
    this.settingsWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final effectiveIconSize = iconSize ?? NavigationConstants.navIconSize;
    final effectiveLabelSize =
        labelFontSize ?? NavigationConstants.navLabelFontSize;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(
            right: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height,
            ),
            child: IntrinsicHeight(
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) =>
                    _handleTabSelection(index, context),
                labelType: NavigationRailLabelType.all,
                minWidth: minWidth ?? NavigationConstants.navRailMinWidth,
                groupAlignment:
                    groupAlignment ?? NavigationConstants.navRailGroupAlignment,
                useIndicator: true,
                indicatorColor: cs.primaryContainer.withValues(alpha: 0.6),
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                selectedIconTheme: IconThemeData(
                  size: effectiveIconSize,
                  color: cs.primary,
                ),
                unselectedIconTheme: IconThemeData(
                  size: effectiveIconSize,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                destinations: tabs.map((tab) {
                  final tooltipMessage = tab.tooltip ?? tab.message;
                  final isSelected = tabs.indexOf(tab) == selectedIndex;

                  Widget iconWidget = Icon(
                    tab.icon,
                    size: effectiveIconSize,
                    color: isSelected
                        ? cs.primary
                        : (tab.color ??
                            cs.onSurfaceVariant.withValues(alpha: 0.7)),
                  );

                  // Wrap with tooltip if available.

                  if (tooltipMessage != null) {
                    iconWidget = MarkdownTooltip(
                      message: tooltipMessage,
                      child: iconWidget,
                    );
                  }

                  return NavigationRailDestination(
                    icon: iconWidget,
                    label: Text(
                      tab.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: effectiveLabelSize,
                        fontWeight: FontWeight.w500,
                        letterSpacing:
                            NavigationConstants.navLabelLetterSpacing,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: NavigationConstants.navLabelMaxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical:
                          NavigationConstants.navDestinationVerticalPadding,
                    ),
                  );
                }).toList(),
                selectedLabelTextStyle: theme.textTheme.bodySmall?.copyWith(
                  fontSize: effectiveLabelSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: NavigationConstants.navLabelLetterSpacing,
                  color: cs.primary,
                ),
                unselectedLabelTextStyle: theme.textTheme.bodySmall?.copyWith(
                  fontSize: effectiveLabelSize,
                  fontWeight: FontWeight.w400,
                  letterSpacing: NavigationConstants.navLabelLetterSpacing,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                trailing: settingsWidget != null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: settingsWidget,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTabSelection(int index, BuildContext context) {
    onTabSelected(index);

    final tab = tabs[index];

    // Handle special tab actions.

    if (tab.message != null && onShowAlert != null) {
      onShowAlert!(context, tab.message!, tab.dialogTitle);
    } else if (tab.action != null) {
      tab.action!(context);
    }
  }
}
