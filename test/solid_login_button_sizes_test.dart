/// Tests that the login page's buttons are all the same width.
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
/// Authors: Anushka Vidanage

library;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:solidui/src/widgets/solid_login_helper.dart';
import 'package:solidui/src/widgets/solid_login_panel.dart';

/// Pump the login panel's content with buttons named [names], two to a row.

Future<void> _pump(WidgetTester tester, List<String> names) async {
  tester.view.physicalSize = const Size(600, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final webId = TextEditingController();
  addTearDown(webId.dispose);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Builder(
            builder: (context) => SolidLoginPanel.buildPanelContent(
              context: context,
              logo: const AssetImage('assets/images/app_icon.png'),
              title: 'App',
              appVersion: '1.0.0',
              webIdController: webId,
              buttons: [
                for (final name in names)
                  ElevatedButton(
                    key: ValueKey(name),
                    onPressed: () {},
                    child: Text(name),
                  ),
              ],
              currentTheme: const SolidLoginThemeMode(),
            ),
          ),
        ),
      ),
    ),
  );
}

double _width(WidgetTester tester, String name) =>
    tester.getSize(find.byKey(ValueKey(name))).width;

void main() {
  testWidgets('a button alone on its row is as wide as one in a pair',
      (tester) async {
    await _pump(tester, ['LOGIN', 'CONTINUE', 'REGISTER']);

    final paired = _width(tester, 'LOGIN');
    expect(_width(tester, 'CONTINUE'), paired);
    expect(_width(tester, 'REGISTER'), paired);
    // Lined up with the button above it, not just the same size.
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('REGISTER'))).dx,
      tester.getTopLeft(find.byKey(const ValueKey('LOGIN'))).dx,
    );
  });

  testWidgets('two buttons share a row equally', (tester) async {
    await _pump(tester, ['LOGIN', 'REGISTER']);

    expect(_width(tester, 'LOGIN'), _width(tester, 'REGISTER'));
  });
}
