/// Tests for navigation entries that draw their own icon (`iconBuilder`):
/// every navigation surface uses it, with the size and colour it would have
/// given the `IconData`.
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

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:solidui/src/widgets/solid_nav_bar.dart';
import 'package:solidui/src/widgets/solid_nav_bottom_bar.dart';
import 'package:solidui/src/widgets/solid_nav_drawer.dart';
import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_scaffold_helpers.dart';
import 'package:solidui/src/widgets/solid_scaffold_models.dart';

/// Every style the badge was drawn with.
final List<SolidNavIconStyle> _drawn = [];

Widget _badge(BuildContext context, SolidNavIconStyle style) {
  _drawn.add(style);
  return Container(key: const ValueKey('badge'), color: style.color);
}

final _tabs = [
  const SolidNavTab(title: 'Home', icon: Icons.home),
  const SolidNavTab(title: 'Work', icon: Icons.mail, iconBuilder: _badge),
  const SolidNavTab(
    title: 'Later',
    icon: Icons.mail,
    iconBuilder: _badge,
    showInOverflow: true,
  ),
];

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  setUp(_drawn.clear);

  testWidgets('the rail draws it, at the rail icon size', (tester) async {
    await tester.pumpWidget(
      _app(
        Row(
          children: [
            SolidNavBar(tabs: _tabs, selectedIndex: 1, onTabSelected: (_) {}),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );

    expect(find.byKey(const ValueKey('badge')), findsNWidgets(2));
    expect(find.byIcon(Icons.mail), findsNothing);
    expect(find.byIcon(Icons.home), findsOneWidget);
    final selected = _drawn.firstWhere((s) => s.selected);
    expect(
      tester.getSize(find.byKey(const ValueKey('badge')).first).width,
      selected.size,
    );
    expect(
      selected.color,
      Theme.of(tester.element(find.byType(SolidNavBar))).colorScheme.primary,
    );
  });

  testWidgets('the bottom bar and its More sheet draw it', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: SolidNavBottomBar(
            tabs: _tabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('badge')), findsOneWidget);
    expect(_drawn.every((s) => !s.selected), isTrue);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('badge')), findsNWidgets(2));
  });

  testWidgets('the drawer draws it', (tester) async {
    await tester.pumpWidget(
      _app(
        SolidNavDrawer(tabs: _tabs, selectedIndex: 2, onTabSelected: (_) {}),
      ),
    );
    expect(find.byKey(const ValueKey('badge')), findsNWidgets(2));
    expect(_drawn.where((s) => s.selected), hasLength(1));
  });

  test('a menu item passes it through to its tab', () {
    final tabs = SolidScaffoldHelpers.convertToNavTabs(const [
      SolidMenuItem(title: 'Work', icon: Icons.mail, iconBuilder: _badge),
    ]);
    expect(tabs.single.iconBuilder, same(_badge));
  });
}
