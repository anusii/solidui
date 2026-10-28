/// Tests that the security key status stays hidden until it is determined.
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

import 'package:solidui/src/services/solid_security_key_notifier.dart';
import 'package:solidui/src/widgets/solid_scaffold_layout_builder.dart';
import 'package:solidui/src/widgets/solid_status_bar_models.dart';

/// Pump the scaffold's status bar with key status [isKeySaved].

Future<void> _pump(WidgetTester tester, bool? isKeySaved) async {
  const config = SolidStatusBarConfig(
    securityKeyStatus: SolidSecurityKeyStatus(),
  );
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SolidScaffoldLayoutBuilder.buildStatusBar(config, isKeySaved),
      ),
    ),
  );
}

void main() {
  testWidgets('no key status is shown before it is determined', (
    tester,
  ) async {
    await _pump(tester, null);
    expect(find.textContaining('Security Key'), findsNothing);
  });

  testWidgets('Not Cached is shown once determined', (tester) async {
    await _pump(tester, false);
    expect(find.text('Security Key Not Cached'), findsOneWidget);
  });

  test('the notifier is undetermined until a status arrives', () {
    final notifier = SecurityKeyNotifier();
    expect(notifier.isDetermined, isFalse);

    // The initial default of false still counts as determining the status.

    notifier.updateStatus(false);
    expect(notifier.isDetermined, isTrue);
  });
}
