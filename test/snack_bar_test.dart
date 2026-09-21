// Tests for showPositiveSnackBar — the understated confirmation bar shared
// across the app suite.
//
// The behaviour worth pinning down is the auto-dismiss: Flutter does not
// reliably time out a SnackBar that carries an action, so the helper hides it
// once the duration has passed.

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:solidui/solidui.dart';

/// Pump a button that shows a positive SnackBar when tapped.

Future<void> pumpBar(
  WidgetTester tester, {
  String message = 'Saved.',
  String? actionLabel,
  VoidCallback? onAction,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(snackBarTheme: solidSnackBarTheme),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showPositiveSnackBar(
              context,
              message,
              actionLabel: actionLabel,
              onAction: onAction,
            ),
            child: const Text('show'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('show'));

  // Let the bar finish sliding in, or its action is not yet hittable.

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 750));
}

/// Run past the auto-dismiss so no timer outlives the test.

Future<void> settle(WidgetTester tester) async {
  await tester.pump(solidSnackBarDuration + const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the message on a soft green bar', (tester) async {
    await pumpBar(tester);

    expect(find.text('Saved.'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.backgroundColor, SnackBarColors.positive);

    await settle(tester);
  });

  testWidgets('auto-dismisses once the duration has passed', (tester) async {
    await pumpBar(tester);
    expect(find.text('Saved.'), findsOneWidget);

    await settle(tester);

    expect(find.text('Saved.'), findsNothing);
  });

  testWidgets('a bar carrying an action still auto-dismisses', (tester) async {
    // The regression: with an action present Flutter can leave the bar up
    // until it is tapped, which stranded todopod's Undo bar on screen.

    await pumpBar(tester, actionLabel: 'Restore', onAction: () {});

    expect(find.text('Restore'), findsOneWidget);

    await settle(tester);

    expect(find.text('Saved.'), findsNothing);
    expect(find.text('Restore'), findsNothing);
  });

  testWidgets('the action fires when tapped', (tester) async {
    var restored = false;
    await pumpBar(
      tester,
      actionLabel: 'Restore',
      onAction: () => restored = true,
    );

    await tester.tap(find.text('Restore'));
    await settle(tester);

    expect(restored, isTrue);
  });

  testWidgets('an action alone adds no button', (tester) async {
    // Both halves are needed: a label with no callback would be a dead
    // button.

    await pumpBar(tester, actionLabel: 'Restore');

    expect(find.text('Restore'), findsNothing);

    await settle(tester);
  });
}
