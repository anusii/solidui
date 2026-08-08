/// Prompt to save unsaved edits when the desktop window is closed.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Saturday 2026-08-08 10:00:00 +1000 Graham Williams>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
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
