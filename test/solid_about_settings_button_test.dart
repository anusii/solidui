/// Tests for where the Settings dialogue is reached from.
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
import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:solidui/src/widgets/solid_about_button.dart';
import 'package:solidui/src/widgets/solid_about_models.dart';

/// Stand in for package_info_plus, which the About dialogue reads its
/// version from and which has no native side under `flutter test`.

void mockPackageInfo() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/package_info'),
    (call) async => <String, dynamic>{
      'appName': 'Test',
      'packageName': 'au.com.example.test',
      'version': '1.0.0',
      'buildNumber': '1',
    },
  );
}

/// Open the About dialogue for [config] and settle it.

Future<void> _openAbout(WidgetTester tester, SolidAboutConfig config) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => SolidAbout.show(context, config),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(mockPackageInfo);

  testWidgets('About leaves Settings to the profile menu', (tester) async {
    // The profile menu is where Settings lives, so About does not offer a
    // second way in to the same dialogue.

    await _openAbout(tester, const SolidAboutConfig(text: 'About this app'));

    expect(find.text('About this app'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Settings'), findsNothing);
  });

  testWidgets('About keeps Settings when there is no profile menu',
      (tester) async {
    // Without a profile menu there is nowhere else to reach the settings
    // from, so the button stays here rather than the app losing them.

    await _openAbout(
      tester,
      const SolidAboutConfig(text: 'About this app', profileEnabled: false),
    );

    expect(find.widgetWithText(TextButton, 'Settings'), findsOneWidget);
  });

  testWidgets('an app offering no sections gets no Settings button',
      (tester) async {
    await _openAbout(
      tester,
      const SolidAboutConfig(
        text: 'About this app',
        profileEnabled: false,
        showLayoutPreferences: false,
        showMenuLayoutPreferences: false,
      ),
    );

    expect(find.widgetWithText(TextButton, 'Settings'), findsNothing);
  });

  test('profileEnabled defaults to there being a profile menu', () {
    expect(const SolidAboutConfig().profileEnabled, isTrue);
    expect(
      const SolidAboutConfig().copyWith(profileEnabled: false).profileEnabled,
      isFalse,
    );
  });
}
