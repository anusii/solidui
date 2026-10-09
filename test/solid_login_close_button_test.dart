/// Tests for the close button on the login page.
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

import 'package:solidui/src/widgets/solid_login_close_button.dart';
import 'package:solidui/src/widgets/solid_login_panel.dart';

/// Pump the login panel's top layer, with a close action if [onClose].

Future<void> _pump(WidgetTester tester, {VoidCallback? onClose}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SolidLoginPanel.buildPanelWithThemeToggle(
            panelContent: const SizedBox(width: 400, height: 400),
            currentThemeMode: ThemeMode.light,
            onThemeToggle: () {},
            onClose: onClose,
          ),
        ),
      ),
    );

void main() {
  testWidgets('no close button without a way into the app', (tester) async {
    await _pump(tester);

    expect(find.byType(SolidLoginCloseButton), findsNothing);
  });

  testWidgets('the close button carries on into the app', (tester) async {
    var closed = false;
    await _pump(tester, onClose: () => closed = true);

    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(closed, isTrue);
  });
}
