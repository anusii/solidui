/// Tests for skipping the login page at start-up.
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
import 'package:shared_preferences/shared_preferences.dart';

import 'package:solidui/src/utils/solid_skip_login.dart';
import 'package:solidui/src/widgets/solid_preferences_dialog.dart';
import 'package:solidui/src/widgets/solid_settings_login_section.dart';

import 'solid_window_size_test.dart' show mockWindow, mockWindowManager;

/// Pump the settings dialogue on its own, without the AppBar section, which
/// belongs to a running scaffold.

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(body: SolidPreferencesDialog(showAppBarSection: false)),
    ),
  );
  await tester.pumpAndSettle();
}

/// The value of the Show the login page switch.

bool _shown(WidgetTester tester) => tester
    .widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Show the login page on start-up'),
    )
    .value;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SolidSkipLogin.reset();
    mockWindow = const Size(1000, 700);
    mockWindowManager();
  });

  group('SolidSkipLogin.atStartup', () {
    test('skips by the app default when CONTINUE is offered', () async {
      expect(
        await SolidSkipLogin.atStartup(offersContinue: true, byDefault: true),
        isTrue,
      );
      expect(SolidSkipLogin.offered, isTrue);
    });

    test('shows the login page when the app default says so', () async {
      expect(
        await SolidSkipLogin.atStartup(offersContinue: true, byDefault: false),
        isFalse,
      );
      expect(SolidSkipLogin.offered, isTrue);
    });

    test('never skips, nor offers to, when a login is required', () async {
      expect(
        await SolidSkipLogin.atStartup(offersContinue: false, byDefault: true),
        isFalse,
      );
      expect(SolidSkipLogin.offered, isFalse);
    });

    test('the user choice overrides the app default', () async {
      SharedPreferences.setMockInitialValues({SolidSkipLogin.skipPref: false});

      expect(
        await SolidSkipLogin.atStartup(offersContinue: true, byDefault: true),
        isFalse,
      );
    });

    test('decides only once, so a re-login page is never skipped', () async {
      await SolidSkipLogin.atStartup(offersContinue: true, byDefault: true);

      expect(
        await SolidSkipLogin.atStartup(offersContinue: true, byDefault: true),
        isFalse,
      );
    });
  });

  group('SolidSkipLogin.setSkipping', () {
    test('keeps a choice that differs from the app default', () async {
      await SolidSkipLogin.atStartup(offersContinue: true, byDefault: true);
      await SolidSkipLogin.setSkipping(false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(SolidSkipLogin.skipPref), isFalse);
      expect(SolidSkipLogin.skipping, isFalse);
    });

    test('forgets a choice that matches the app default', () async {
      SharedPreferences.setMockInitialValues({SolidSkipLogin.skipPref: false});
      await SolidSkipLogin.atStartup(offersContinue: true, byDefault: true);
      await SolidSkipLogin.setSkipping(true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(SolidSkipLogin.skipPref), isFalse);
    });
  });

  group('Login Page settings section', () {
    testWidgets('is left out when the app requires a login', (tester) async {
      await SolidSkipLogin.atStartup(offersContinue: false, byDefault: true);
      await _pump(tester);

      expect(find.text('Login Page'), findsNothing);
      expect(find.byType(SolidSettingsLoginSection), findsNothing);
    });

    testWidgets('appears, off, when the app skips by default', (tester) async {
      await SolidSkipLogin.atStartup(offersContinue: true, byDefault: true);
      await _pump(tester);

      expect(find.text('Login Page'), findsOneWidget);
      expect(_shown(tester), isFalse);
    });

    testWidgets('Save keeps the choice to show the login page', (tester) async {
      await SolidSkipLogin.atStartup(offersContinue: true, byDefault: true);
      await _pump(tester);

      await tester.ensureVisible(find.byType(SolidSettingsLoginSection));
      await tester.tap(find.byType(Switch).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(SolidSkipLogin.skipping, isFalse);
    });

    testWidgets('Default restores the app default', (tester) async {
      SharedPreferences.setMockInitialValues({SolidSkipLogin.skipPref: false});
      await SolidSkipLogin.atStartup(offersContinue: true, byDefault: true);
      await _pump(tester);

      expect(_shown(tester), isTrue);

      await tester.tap(find.text('Default'));
      await tester.pumpAndSettle();

      expect(_shown(tester), isFalse);
    });
  });
}
