/// Regression test for the security key field rendering inside a normal
/// Flutter Material app.
///
/// flutter_form_builder 11.x builds its text field from `package:material_ui`,
/// whose `debugCheckHasMaterial` looks for a `material_ui` `Material` ancestor
/// by exact type. A host app built on `package:flutter/material.dart` supplies
/// the SDK's `Material`, which is a different class, so the assertion fails and
/// the security key popup cannot be shown. This test pumps the field the way
/// the app does — inside a Flutter `MaterialApp`/`Scaffold` — so that mismatch
/// is caught here rather than at runtime in the backup dialog.
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solidui/src/widgets/secret_text_field.dart';

void main() {
  testWidgets('SecretTextField builds inside a Flutter Material app', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormBuilder(
            child: Column(
              children: [
                SecretTextField(
                  fieldKey: 'securityKey',
                  fieldLabel: 'Security Key',
                  validateFunc: (_) => null,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SecretTextField), findsOneWidget);
  });
}
