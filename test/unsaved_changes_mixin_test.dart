// Widget tests for UnsavedChangesMixin.
//
// Drives a minimal editor through the window-close prompt without a live Pod.

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:solidui/solidui.dart';

/// A minimal editor: dirty on demand, with a save that can be held open so a
/// test can observe an in-flight write.

class FakeEditor extends StatefulWidget {
  const FakeEditor({
    super.key,
    this.dirty = true,
    this.gate,
    this.canSave = true,
  });

  final bool dirty;
  final Future<void>? gate;
  final bool canSave;

  @override
  State<FakeEditor> createState() => FakeEditorState();
}

class FakeEditorState extends State<FakeEditor> with UnsavedChangesMixin {
  /// Set once [saveUnsavedChanges] has run to completion.

  static bool saved = false;

  @override
  bool get hasUnsavedChanges => widget.dirty;

  @override
  bool get canSaveUnsavedChanges => widget.canSave;

  @override
  Future<void> saveUnsavedChanges() async {
    if (widget.gate != null) await widget.gate;
    saved = true;
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

Future<void> pumpEditor(WidgetTester tester, Widget child) async {
  FakeEditorState.saved = false;
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('clean editor closes with no prompt', (tester) async {
    await pumpEditor(tester, const FakeEditor(dirty: false));

    expect(await SolidWindowCloseGuard.resolveAll(), isTrue);
    expect(find.text('Unsaved changes'), findsNothing);
  });

  testWidgets('Discard allows the close without saving', (tester) async {
    await pumpEditor(tester, const FakeEditor());

    final pending = SolidWindowCloseGuard.resolveAll();
    await tester.pumpAndSettle();
    expect(find.text('Unsaved changes'), findsOneWidget);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(await pending, isTrue);
    expect(FakeEditorState.saved, isFalse);
  });

  testWidgets('Keep editing aborts the close', (tester) async {
    await pumpEditor(tester, const FakeEditor());

    final pending = SolidWindowCloseGuard.resolveAll();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();

    expect(await pending, isFalse);
    expect(FakeEditorState.saved, isFalse);
  });

  testWidgets('Save waits for the write before allowing the close', (
    tester,
  ) async {
    final gate = Completer<void>();
    await pumpEditor(tester, FakeEditor(gate: gate.future));

    var resolved = false;
    final pending = SolidWindowCloseGuard.resolveAll()
      ..then((_) => resolved = true);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Write still in flight: the window must not be destroyed yet.
    expect(resolved, isFalse);
    expect(FakeEditorState.saved, isFalse);

    gate.complete();
    await tester.pumpAndSettle();

    expect(await pending, isTrue);
    expect(FakeEditorState.saved, isTrue);
  });

  testWidgets('Save on an incomplete entry aborts the close', (tester) async {
    await pumpEditor(tester, const FakeEditor(canSave: false));

    final pending = SolidWindowCloseGuard.resolveAll();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Nothing could be saved, so the window must stay open rather than
    // close and lose the very work the user asked to keep.
    expect(await pending, isFalse);
    expect(FakeEditorState.saved, isFalse);
  });

  testWidgets('Discard still closes an incomplete entry', (tester) async {
    await pumpEditor(tester, const FakeEditor(canSave: false));

    final pending = SolidWindowCloseGuard.resolveAll();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(await pending, isTrue);
    expect(FakeEditorState.saved, isFalse);
  });

  testWidgets('resolver is unregistered when the editor goes away', (
    tester,
  ) async {
    await pumpEditor(tester, const FakeEditor());
    await pumpEditor(tester, const SizedBox());

    // Nothing registered, so no prompt and the close proceeds.
    expect(await SolidWindowCloseGuard.resolveAll(), isTrue);
    expect(find.text('Unsaved changes'), findsNothing);
  });
}
