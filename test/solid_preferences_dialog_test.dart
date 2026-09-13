/// Tests for the sectioned settings dialogue.
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

import 'package:solidui/src/utils/solid_window_size.dart';
import 'package:solidui/src/widgets/solid_preferences_dialog.dart';
import 'package:solidui/src/widgets/solid_settings_menu_section.dart';
import 'package:solidui/src/widgets/solid_settings_window_size_section.dart';

import 'solid_window_size_test.dart' show mockWindow, mockWindowManager;

/// Pump the dialogue on its own, with the sections [showAppBarSection] and
/// [showMenuSection] ask for.
///
/// The AppBar section is left out by default: it reads the preferences
/// notifier, which belongs to a running scaffold.

Future<void> _pump(
  WidgetTester tester, {
  bool showAppBarSection = false,
  bool showMenuSection = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SolidPreferencesDialog(
          showAppBarSection: showAppBarSection,
          showMenuSection: showMenuSection,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockWindow = const Size(1000, 700);
    mockWindowManager();
  });

  testWidgets('shows a section for each group of settings', (tester) async {
    await _pump(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Menu Layout'), findsOneWidget);
    expect(find.byType(SolidSettingsMenuSection), findsOneWidget);

    // The tests run on the desktop, where there is a window to size.

    expect(find.text('Window Size'), findsOneWidget);
    expect(find.byType(SolidSettingsWindowSizeSection), findsOneWidget);
  });

  testWidgets('leaves out a section the app has turned off', (tester) async {
    await _pump(tester, showMenuSection: false);

    expect(find.text('Menu Layout'), findsNothing);
    expect(find.byType(SolidSettingsMenuSection), findsNothing);
    expect(find.text('Window Size'), findsOneWidget);
  });

  testWidgets('opens the size fields at the current window size',
      (tester) async {
    await _pump(tester);

    expect(find.widgetWithText(TextField, '1000'), findsOneWidget);
    expect(find.widgetWithText(TextField, '700'), findsOneWidget);
  });

  testWidgets('Save applies the size that was typed', (tester) async {
    await _pump(tester);

    await tester.enterText(find.widgetWithText(TextField, '1000'), '1280');
    await tester.enterText(find.widgetWithText(TextField, '700'), '860');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(await SolidWindowSize.saved(), const Size(1280, 860));
  });

  testWidgets('Save marks a size too small rather than taking it',
      (tester) async {
    await _pump(tester);

    await tester.enterText(find.widgetWithText(TextField, '1000'), '40');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('At least 100'), findsOneWidget);
    expect(await SolidWindowSize.saved(), isNull);

    // The dialogue stays up on the mistake rather than closing on it.

    expect(find.byType(SolidPreferencesDialog), findsOneWidget);
  });

  testWidgets('Default forgets the remembered size', (tester) async {
    await SolidWindowSize.resize(const Size(1280, 860));
    await _pump(tester);

    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();

    expect(await SolidWindowSize.saved(), isNull);
  });
}
