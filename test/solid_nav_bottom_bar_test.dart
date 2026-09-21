/// Tests for the bottom navigation bar's overflow "More" menu.
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
/// Authors: Jess Moore

library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:solidui/src/widgets/solid_nav_bottom_bar.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';

Widget _buildBar({
  required List<SolidNavTab> tabs,
  int? selectedIndex,
  required void Function(int) onTabSelected,
}) {
  return MaterialApp(
    home: Scaffold(
      bottomNavigationBar: SolidNavBottomBar(
        tabs: tabs,
        selectedIndex: selectedIndex,
        onTabSelected: onTabSelected,
      ),
    ),
  );
}

void main() {
  testWidgets(
    'shows all tabs directly when none are marked for overflow',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        const tabs = [
          SolidNavTab(title: 'Home', icon: Icons.home),
          SolidNavTab(title: 'Files', icon: Icons.folder),
        ];

        await tester.pumpWidget(
          _buildBar(tabs: tabs, selectedIndex: 0, onTabSelected: (_) {}),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Files'), findsOneWidget);
        expect(find.text('More'), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets(
    'collapses tabs marked showInOverflow into a More button on mobile',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        int? selected;
        const tabs = [
          SolidNavTab(title: 'Home', icon: Icons.home),
          SolidNavTab(title: 'Files', icon: Icons.folder),
          SolidNavTab(
            title: 'Settings',
            icon: Icons.settings,
            showInOverflow: true,
          ),
        ];

        await tester.pumpWidget(
          _buildBar(
            tabs: tabs,
            selectedIndex: 0,
            onTabSelected: (i) => selected = i,
          ),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Files'), findsOneWidget);
        expect(find.text('More'), findsOneWidget);
        expect(find.text('Settings'), findsNothing);

        await tester.tap(find.text('More'));
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        expect(selected, 2);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets(
    'does not collapse tabs into overflow on non-mobile platforms',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        const tabs = [
          SolidNavTab(title: 'Home', icon: Icons.home),
          SolidNavTab(
            title: 'Settings',
            icon: Icons.settings,
            showInOverflow: true,
          ),
        ];

        await tester.pumpWidget(
          _buildBar(tabs: tabs, selectedIndex: 0, onTabSelected: (_) {}),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('More'), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );
}
