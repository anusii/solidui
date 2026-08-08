// Tests for SolidPendingWrites, the in-flight Pod write tracker that stops a
// window close landing on top of a save nobody is awaiting.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:solidui/solidui.dart';

void main() {
  test('settle returns immediately when nothing is in flight', () async {
    expect(SolidPendingWrites.hasPending, isFalse);
    expect(await SolidPendingWrites.settle(), isTrue);
  });

  test('track returns the write result unchanged', () async {
    expect(await SolidPendingWrites.track(Future.value('written')), 'written');
  });

  test('settle waits for an unawaited write to finish', () async {
    final write = Completer<void>();
    var done = false;

    // Fire and forget, exactly as a star toggle or reorder does.
    SolidPendingWrites.track(
      write.future.whenComplete(() => done = true),
    ).ignore();

    expect(SolidPendingWrites.hasPending, isTrue);

    var settled = false;
    final pending = SolidPendingWrites.settle()..then((_) => settled = true);
    await Future<void>.delayed(Duration.zero);

    // The write is still running, so the close must not proceed.
    expect(settled, isFalse);
    expect(done, isFalse);

    write.complete();

    expect(await pending, isTrue);
    expect(done, isTrue);
    expect(SolidPendingWrites.hasPending, isFalse);
  });

  test('settle waits for several concurrent writes', () async {
    final first = Completer<void>();
    final second = Completer<void>();
    SolidPendingWrites.track(first.future).ignore();
    SolidPendingWrites.track(second.future).ignore();

    var settled = false;
    final pending = SolidPendingWrites.settle()..then((_) => settled = true);

    first.complete();
    await Future<void>.delayed(Duration.zero);
    // One still outstanding.
    expect(settled, isFalse);

    second.complete();
    expect(await pending, isTrue);
  });

  test('a failing write still clears, and the error still propagates',
      () async {
    final write = Completer<void>();
    final tracked = SolidPendingWrites.track(write.future);

    write.completeError(StateError('pod unreachable'));

    await expectLater(tracked, throwsStateError);
    expect(SolidPendingWrites.hasPending, isFalse);
    expect(await SolidPendingWrites.settle(), isTrue);
  });

  test('settle gives up rather than trapping the user in the app', () async {
    final wedged = Completer<void>();
    SolidPendingWrites.track(wedged.future).ignore();

    // A write that never returns must not block the close forever.
    expect(
      await SolidPendingWrites.settle(timeout: const Duration(seconds: 1)),
      isFalse,
    );

    // Leave the tracker clean for any later test.
    wedged.complete();
    await SolidPendingWrites.settle();
  });
}
