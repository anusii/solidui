/// Tests for the Button Order section of the settings dialogue.
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
/// Authors: Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:solidui/src/widgets/solid_preferences_button_order.dart';
import 'package:solidui/src/widgets/solid_preferences_models.dart';

/// An app's own action, named by its Markdown tooltip.

const _bellLabel = '**Session Bell**\n\nChoose which bell sounds.';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SolidPreferencesButtonOrderSection(
          appBarActions: const [
            SolidAppBarActionItem(
              id: 'theme_toggle',
              label: 'Theme Toggle',
              icon: Icons.brightness_6,
            ),
            SolidAppBarActionItem(
              id: 'bell',
              label: _bellLabel,
              icon: Icons.notifications_active_outlined,
            ),
          ],
          onReorder: (_, __) {},
          onVisibilityChanged: (_, __) {},
          onOverflowChanged: (_, __) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows each button by its icon, not its name', (tester) async {
    await _pump(tester);

    expect(find.byIcon(Icons.brightness_6), findsOneWidget);
    expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);
    expect(find.text('Theme Toggle'), findsNothing);
    expect(find.text(_bellLabel), findsNothing);
  });

  testWidgets('names each button in a tooltip on its icon', (tester) async {
    await _pump(tester);

    final messages = tester
        .widgetList<MarkdownTooltip>(find.byType(MarkdownTooltip))
        .map((t) => t.message);

    expect(messages, containsAll(['Theme Toggle', _bellLabel]));
  });
}
