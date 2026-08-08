// Tests for SolidWindowCloseGuard's resolver registry.
//
// Only the pure registry logic is covered: enable() and onWindowClose() drive
// the window_manager plugin, which needs a real desktop window.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:solidui/solidui.dart';

void main() {
  test('resolveAll succeeds when nothing is registered', () async {
    expect(await SolidWindowCloseGuard.resolveAll(), isTrue);
  });

  test('resolveAll is true when every resolver agrees', () async {
    Future<bool> yes() async => true;
    SolidWindowCloseGuard.register(yes);
    addTearDown(() => SolidWindowCloseGuard.unregister(yes));

    expect(await SolidWindowCloseGuard.resolveAll(), isTrue);
  });

  test('one refusal blocks the close', () async {
    Future<bool> no() async => false;
    SolidWindowCloseGuard.register(no);
    addTearDown(() => SolidWindowCloseGuard.unregister(no));

    expect(await SolidWindowCloseGuard.resolveAll(), isFalse);
  });

  test('resolvers run most-recently-registered first, and short circuit', () {
    final order = <String>[];
    Future<bool> first() async {
      order.add('first');
      return true;
    }

    Future<bool> second() async {
      order.add('second');
      return false;
    }

    Future<bool> third() async {
      order.add('third');
      return true;
    }

    for (final r in [first, second, third]) {
      SolidWindowCloseGuard.register(r);
      addTearDown(() => SolidWindowCloseGuard.unregister(r));
    }

    return SolidWindowCloseGuard.resolveAll().then((proceed) {
      expect(proceed, isFalse);
      // third is asked first; second refuses so first is never consulted.
      expect(order, ['third', 'second']);
    });
  });

  test('unregister removes a resolver', () async {
    Future<bool> no() async => false;
    SolidWindowCloseGuard.register(no);
    expect(await SolidWindowCloseGuard.resolveAll(), isFalse);

    SolidWindowCloseGuard.unregister(no);
    expect(await SolidWindowCloseGuard.resolveAll(), isTrue);
  });

  test('resolveAll waits for a slow resolver to finish', () async {
    final gate = Completer<void>();
    var finished = false;
    Future<bool> slow() async {
      await gate.future;
      finished = true;
      return true;
    }

    SolidWindowCloseGuard.register(slow);
    addTearDown(() => SolidWindowCloseGuard.unregister(slow));

    var resolved = false;
    final pending = SolidWindowCloseGuard.resolveAll()
      ..then((_) => resolved = true);
    await Future<void>.delayed(Duration.zero);

    // Still in flight, so the window must not be destroyed yet.
    expect(resolved, isFalse);
    expect(finished, isFalse);

    gate.complete();
    expect(await pending, isTrue);
    expect(finished, isTrue);
  });

  test('a resolver may unregister itself while resolving', () async {
    late final UnsavedChangesResolver selfRemoving;
    selfRemoving = () async {
      SolidWindowCloseGuard.unregister(selfRemoving);
      return true;
    };
    SolidWindowCloseGuard.register(selfRemoving);

    expect(await SolidWindowCloseGuard.resolveAll(), isTrue);
    expect(await SolidWindowCloseGuard.resolveAll(), isTrue);
  });

  test('resolveAll ignores pending writes; the guard is what waits', () async {
    // resolveAll only consults editors. Waiting for unawaited writes is
    // onWindowClose's job, via SolidPendingWrites.settle().
    final write = Completer<void>();
    SolidPendingWrites.track(write.future).ignore();

    expect(await SolidWindowCloseGuard.resolveAll(), isTrue);
    expect(SolidPendingWrites.hasPending, isTrue);

    var settled = false;
    final pending = SolidPendingWrites.settle()..then((_) => settled = true);
    await Future<void>.delayed(Duration.zero);
    expect(settled, isFalse);

    write.complete();
    expect(await pending, isTrue);
  });
}
