/// Tests for the profile menu's Profile and Settings entries.
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

import 'package:solidui/src/widgets/solid_nav_models.dart';
import 'package:solidui/src/widgets/solid_preferences_dialog.dart';
import 'package:solidui/src/widgets/solid_profile_avatar.dart';
import 'package:solidui/src/widgets/solid_scaffold.dart';
import 'package:solidui/src/widgets/solid_scaffold_models.dart';

import 'solid_window_size_test.dart' show mockWindow, mockWindowManager;

/// Pump a scaffold and open its profile menu.

Future<void> _openProfileMenu(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: SolidScaffold(
        appBar: SolidAppBarConfig(title: 'Test'),
        menu: [
          SolidMenuItem(
            title: 'Home',
            icon: Icons.home,
            tooltip: '**Home**\n\nThe home page.',
            child: SizedBox.shrink(),
          ),
        ],
        child: SizedBox.shrink(),
      ),
    ),
  );
  await tester.pump();

  await tester.tap(find.byType(SolidProfileAvatar));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockWindow = const Size(1000, 700);
    mockWindowManager();
  });

  testWidgets('offers Profile and Settings as separate entries',
      (tester) async {
    await _openProfileMenu(tester);

    // Profile edits the person; Settings configures the app. One word for
    // both was the confusion this menu is built to avoid.

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Settings opens the sectioned settings dialogue', (tester) async {
    await _openProfileMenu(tester);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.byType(SolidPreferencesDialog), findsOneWidget);
    expect(find.text('Window Size'), findsOneWidget);
  });
}
