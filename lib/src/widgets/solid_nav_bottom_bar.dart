/// Solid bottom navigation bar for narrow-screen menu items.
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
/// Authors: Tony Chen, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:solidui/src/constants/navigation.dart';
import 'package:solidui/src/utils/is_phone.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';

/// Bottom navigation bar showing main menu tabs on narrow screens.
///
/// Tabs marked [SolidNavTab.showInOverflow] are collapsed into a "More"
/// destination that opens the remaining tabs in a menu when pressed. This
/// only happens on mobile platforms (iOS/Android); on web and desktop every
/// tab is shown directly, regardless of the flag.

class SolidNavBottomBar extends StatelessWidget {
  /// Navigation tabs (typically from [SolidScaffold] menu items).

  final List<SolidNavTab> tabs;

  /// Currently selected tab index.

  final int? selectedIndex;

  /// Callback when a tab is selected.

  final void Function(int) onTabSelected;

  /// Optional callback to show alert dialogs for action-only tabs.

  final void Function(BuildContext, String, String?)? onShowAlert;

  const SolidNavBottomBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onShowAlert,
  });

  void _handleTabSelection(int index, BuildContext context) {
    onTabSelected(index);

    final tab = tabs[index];
    if (tab.message != null && onShowAlert != null) {
      onShowAlert!(context, tab.message!, tab.dialogTitle);
    }
  }

  /// Shows the tabs collapsed into overflow, triggered by pressing the
  /// "More" destination.

  Future<void> _showOverflowMenu(
    BuildContext context,
    List<int> overflowIndices,
  ) async {
    final cs = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: overflowIndices.map((index) {
              final tab = tabs[index];
              final isSelected = index == selectedIndex;
              final tileColor =
                  isSelected ? cs.primary : (tab.color ?? cs.onSurfaceVariant);

              return ListTile(
                leading: Icon(tab.icon, color: tileColor),
                title: Text(
                  tab.title,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: tileColor,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _handleTabSelection(index, context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Builds the icon widget for a tab, including its optional tooltip.

  Widget _buildTabIcon(SolidNavTab tab, bool isSelected, ColorScheme cs) {
    Widget icon = Icon(
      tab.icon,
      size: NavigationConstants.navIconSize,
      color: isSelected
          ? cs.primary
          : (tab.color ?? cs.onSurfaceVariant.withValues(alpha: 0.7)),
    );

    final tooltipMessage = tab.tooltip ?? tab.message;
    if (tooltipMessage != null) {
      icon = MarkdownTooltip(message: tooltipMessage, child: icon);
    }
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Only collapse tabs into the overflow "More" destination on mobile
    // platforms; web/desktop narrow layouts always show every tab directly.

    final hasOverflow = isPhone() && tabs.any((tab) => tab.showInOverflow);

    final visibleIndices = [
      for (int i = 0; i < tabs.length; i++)
        if (!hasOverflow || !tabs[i].showInOverflow) i,
    ];
    final overflowIndices = [
      for (int i = 0; i < tabs.length; i++)
        if (hasOverflow && tabs[i].showInOverflow) i,
    ];

    final moreDestinationIndex = visibleIndices.length;
    final isOverflowSelected = overflowIndices.contains(selectedIndex);

    final navBarSelectedIndex = isOverflowSelected
        ? moreDestinationIndex
        : () {
            final position = visibleIndices.indexOf(selectedIndex ?? -1);
            return position == -1 ? 0 : position;
          }();

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return theme.textTheme.labelSmall?.copyWith(
            fontSize: NavigationConstants.navLabelFontSize,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            letterSpacing: NavigationConstants.navLabelLetterSpacing,
            color: selected ? cs.primary : cs.onSurfaceVariant,
          );
        }),
        indicatorColor: cs.primaryContainer.withValues(alpha: 0.6),
      ),
      child: NavigationBar(
        selectedIndex: navBarSelectedIndex,
        onDestinationSelected: (destinationIndex) {
          if (overflowIndices.isNotEmpty &&
              destinationIndex == moreDestinationIndex) {
            _showOverflowMenu(context, overflowIndices);
            return;
          }
          _handleTabSelection(visibleIndices[destinationIndex], context);
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final index in visibleIndices)
            NavigationDestination(
              icon: _buildTabIcon(tabs[index], index == selectedIndex, cs),
              label: tabs[index].title,
            ),
          if (overflowIndices.isNotEmpty)
            NavigationDestination(
              icon: Icon(
                Icons.more_horiz,
                size: NavigationConstants.navIconSize,
                color: isOverflowSelected
                    ? cs.primary
                    : cs.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              label: 'More',
            ),
        ],
      ),
    );
  }
}
