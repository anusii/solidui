/// Prompt to save unsaved edits when the desktop window is closed.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.
//
// Time-stamp: <Saturday 2026-08-08 10:00:00 +1000 Graham Williams>
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

import 'package:window_manager/window_manager.dart';

import 'package:solidui/src/utils/is_desktop.dart';
import 'package:solidui/src/utils/solid_pending_writes.dart';

/// Resolves whether it is safe to proceed with closing the window: `true` once
/// any unsaved changes have been saved or discarded, `false` if the user chose
/// to keep editing, which aborts the close.
///
/// An implementation MUST NOT return `true` until any save it started has
/// completed. The window is destroyed the moment every resolver returns `true`,
/// so a fire-and-forget write would be killed mid-flight and the edit lost.
typedef UnsavedChangesResolver = Future<bool> Function();

/// Routes the desktop window-close button through the app so an editor with
/// unsaved changes can prompt to save, discard, or keep editing, instead of
/// the edit being silently lost.
///
/// Without this, closing the window quits immediately and anything typed into
/// an open editor and not yet saved is gone.
///
/// Two steps to adopt:
///
/// 1. Call [enable] once in `main()`, after `windowManager.ensureInitialized()`
///    and before `runApp`. It is a no-op off desktop, so it needs no guard:
///
/// ```dart
/// await windowManager.ensureInitialized();
/// await SolidWindowCloseGuard.enable();
/// ```
///
/// 2. In each editor that holds unsaved state, [register] a resolver on mount
///    and [unregister] it on dispose:
///
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   SolidWindowCloseGuard.register(_resolveUnsavedOnWindowClose);
/// }
///
/// @override
/// void dispose() {
///   SolidWindowCloseGuard.unregister(_resolveUnsavedOnWindowClose);
///   super.dispose();
/// }
/// ```
///
/// Nothing needs to change in the app's root widget: the listener is held by
/// this class, not by a [State], so a `StatelessWidget` root is fine.

class SolidWindowCloseGuard with WindowListener {
  SolidWindowCloseGuard._();

  static final SolidWindowCloseGuard _instance = SolidWindowCloseGuard._();

  static final List<UnsavedChangesResolver> _resolvers = [];

  /// Prevents the window closing on its own and installs the listener that
  /// runs the registered resolvers first. A no-op when not on desktop.
  ///
  /// Requires `windowManager.ensureInitialized()` to have been awaited.

  static Future<void> enable() async {
    if (!isDesktop) return;
    await windowManager.setPreventClose(true);
    windowManager.addListener(_instance);
  }

  /// Registers [resolver], to be consulted before the window closes.

  static void register(UnsavedChangesResolver resolver) =>
      _resolvers.add(resolver);

  /// Removes [resolver]. Call from the editor's `dispose`.

  static void unregister(UnsavedChangesResolver resolver) =>
      _resolvers.remove(resolver);

  /// Runs each registered resolver, most-recently-registered first so the
  /// editor on top is asked about first, stopping as soon as one reports
  /// "keep editing". Returns whether the close should proceed.

  static Future<bool> resolveAll() async {
    // Iterate a copy: a resolver may unregister itself as it completes.
    for (final resolver in _resolvers.reversed.toList()) {
      if (!await resolver()) return false;
    }
    return true;
  }

  @override
  void onWindowClose() async {
    if (!await resolveAll()) return;
    // Editors have saved or discarded, but a write started earlier from a
    // synchronous callback (a star toggle, a reorder) may still be running
    // and nobody is holding it. Let those finish before the process goes.
    await SolidPendingWrites.settle();
    await windowManager.destroy();
  }
}
