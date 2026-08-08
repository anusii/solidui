// Tests for SolidWriteFailures and SolidWriteFailureListener — reporting
// failures from Pod writes that nothing awaits.

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:solidui/solidui.dart';

void main() {
  setUp(SolidWriteFailures.clear);

  group('watch', () {
    test('a successful write reports nothing', () async {
      SolidWriteFailures.watch(Future<String?>.value(null));
      await Future<void>.delayed(Duration.zero);

      expect(SolidWriteFailures.latest.value, isNull);
    });

    test('a returned error string is reported', () async {
      // The convention in most of these apps: the future SUCCEEDS, carrying a
      // message. Nothing throws, which is exactly why it went unnoticed.
      SolidWriteFailures.watch(Future<String?>.value('403 Forbidden'));
      await Future<void>.delayed(Duration.zero);

      expect(SolidWriteFailures.latest.value, contains('403 Forbidden'));
    });

    test('a thrown error is reported', () async {
      SolidWriteFailures.watch(Future<void>.error(StateError('no network')));
      await Future<void>.delayed(Duration.zero);

      expect(SolidWriteFailures.latest.value, contains('no network'));
    });

    test('during names the operation in the message', () async {
      SolidWriteFailures.watch(
        Future<String?>.value('boom'),
        during: 'saving tasks',
      );
      await Future<void>.delayed(Duration.zero);

      expect(SolidWriteFailures.latest.value, contains('saving tasks'));
      expect(SolidWriteFailures.latest.value, contains('boom'));
    });

    test('an empty string is not a failure', () async {
      SolidWriteFailures.watch(Future<String?>.value(''));
      await Future<void>.delayed(Duration.zero);

      expect(SolidWriteFailures.latest.value, isNull);
    });
  });

  group('reportIfFailed', () {
    test('a null error reports nothing', () {
      SolidWriteFailures.reportIfFailed(null);

      expect(SolidWriteFailures.latest.value, isNull);
    });

    test('an empty error reports nothing', () {
      SolidWriteFailures.reportIfFailed('');

      expect(SolidWriteFailures.latest.value, isNull);
    });

    test('a real error is reported with its operation', () {
      SolidWriteFailures.reportIfFailed(
        '409 Conflict',
        during: 'saving the bill',
      );

      expect(SolidWriteFailures.latest.value, contains('saving the bill'));
      expect(SolidWriteFailures.latest.value, contains('409 Conflict'));
    });
  });

  group('listener', () {
    Future<void> pump(WidgetTester tester) => tester.pumpWidget(
          const MaterialApp(
            home: SolidWriteFailureListener(child: Scaffold(body: Text('app'))),
          ),
        );

    testWidgets('shows a modal dialog for a failure', (tester) async {
      await pump(tester);

      SolidWriteFailures.report('disk full');
      await tester.pumpAndSettle();

      expect(find.text('Save failed'), findsOneWidget);
      expect(find.text('disk full'), findsOneWidget);
    });

    testWidgets('clears once shown, so it does not reappear', (tester) async {
      await pump(tester);

      SolidWriteFailures.report('disk full');
      await tester.pumpAndSettle();
      expect(SolidWriteFailures.latest.value, isNull);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('disk full'), findsNothing);
    });

    testWidgets('a failure during the dialog is still shown after', (
      tester,
    ) async {
      await pump(tester);

      SolidWriteFailures.report('first');
      await tester.pumpAndSettle();
      expect(find.text('first'), findsOneWidget);

      // Arrives while the first dialog is up: must not be dropped.
      SolidWriteFailures.report('second');
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    testWidgets('a failure arriving before mount is still shown', (
      tester,
    ) async {
      SolidWriteFailures.report('earlier');
      await pump(tester);
      await tester.pumpAndSettle();

      expect(find.text('earlier'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });
  });
}
