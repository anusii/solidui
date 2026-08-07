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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:solidui/src/constants/navigation.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';

/// Bottom navigation bar showing main menu tabs on narrow screens.

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
        selectedIndex: selectedIndex ?? 0,
        onDestinationSelected: (index) => _handleTabSelection(index, context),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: tabs.map((tab) {
          final index = tabs.indexOf(tab);
          final isSelected = index == selectedIndex;
          final tooltipMessage = tab.tooltip ?? tab.message;

          Widget icon = Icon(
            tab.icon,
            size: NavigationConstants.navIconSize,
            color: isSelected
                ? cs.primary
                : (tab.color ?? cs.onSurfaceVariant.withValues(alpha: 0.7)),
          );

          if (tooltipMessage != null) {
            icon = MarkdownTooltip(message: tooltipMessage, child: icon);
          }

          return NavigationDestination(icon: icon, label: tab.title);
        }).toList(),
      ),
    );
  }
}
