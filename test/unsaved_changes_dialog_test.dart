// Widget tests for showUnsavedChangesDialog.

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:solidui/solidui.dart';

/// Pumps a button, taps it to raise the dialog, and returns the sink the
/// answer lands in once the user chooses.

Future<List<UnsavedChangesAction>> openDialog(WidgetTester tester) async {
  final answers = <UnsavedChangesAction>[];

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async =>
                answers.add(await showUnsavedChangesDialog(context)),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  return answers;
}

void main() {
  testWidgets('offers all three choices', (tester) async {
    await openDialog(tester);

    expect(find.text('Unsaved changes'), findsOneWidget);
    expect(find.text('Keep editing'), findsOneWidget);
    expect(find.text('Discard'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  for (final (label, expected) in [
    ('Save', UnsavedChangesAction.save),
    ('Discard', UnsavedChangesAction.discard),
    ('Keep editing', UnsavedChangesAction.keepEditing),
  ]) {
    testWidgets('$label returns $expected', (tester) async {
      final answers = await openDialog(tester);

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(answers.single, expected);
    });
  }

  testWidgets('dismissing counts as keep editing', (tester) async {
    final answers = await openDialog(tester);

    // Pop without choosing, as an Escape key press would.
    Navigator.of(tester.element(find.byType(AlertDialog))).pop();
    await tester.pumpAndSettle();

    expect(answers.single, UnsavedChangesAction.keepEditing);
  });
}
