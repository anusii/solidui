/// Keep the external login browser window in front of the app window.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.
//
// Time-stamp: <Wednesday 2026-09-16 10:00:00 +1000 Tony Chen>
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
/// Authors: Tony Chen

library;

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;

import 'package:universal_io/io.dart' show Platform, Process;
import 'package:window_manager/window_manager.dart';

import 'package:solidui/src/utils/is_desktop.dart';

/// Puts the browser that runs the Solid login — or logout — in front of the
/// app window.
///
/// On desktop the Solid-OIDC flow hands the login and end-session pages to the
/// user's default browser (`package:oidc` → `url_launcher` → `NSWorkspace.open()` on macOS),
/// so the page lives in a window that belongs to another application. No
/// desktop platform lets one application pin another application's window on
/// top, so instead of trying to raise that window directly we make sure
/// nothing of ours sits in front of it:
///
/// * our own window gives up the foreground and is ordered to the back, and
/// * the default browser is activated with `open -b <bundle id>`, which lifts
///   its windows above every other application and follows the browser to the
///   space it is on — the macOS case where the login page landed in a window
///   that stayed hidden behind everything else. We only ever activate a
///   browser LaunchServices names as the https handler and that is already
///   running, so no second browser is started on top of the login page.
///
/// Both of those are macOS specific. Windows and Linux already foreground the
/// browser as they launch it, so there we only make sure the app window is not
/// pinned on top of it.
///
/// The browser is only launched part way through the handshake (after the
/// WebID and discovery-document lookups), so [start] retries a few times
/// rather than acting once. Call [stop] when the handshake returns; it cancels
/// any pending attempt and brings the app window back to the front.
///
/// Every step is best effort: failures are logged and ignored, and on the web
/// and on mobile — where the flow never leaves the app — all of this is a
/// no-op.

class SolidLoginBrowserFocus {
  // A static-only helper; there is a single app window to manage.

  SolidLoginBrowserFocus._();

  /// Delays after [start] at which we try to put the browser in front. The
  /// first attempt covers a prewarmed OIDC manager, the later ones a server
  /// that is slow to answer the discovery request.

  static const _attemptDelays = <Duration>[
    Duration(milliseconds: 600),
    Duration(milliseconds: 1800),
    Duration(milliseconds: 4000),
  ];

  static final _pending = <Timer>[];

  static bool _ordered = false;

  /// Begins handing the foreground over to the login browser. Safe to call
  /// more than once: an earlier series of attempts is cancelled first.

  static void start() {
    if (!isDesktop) return;

    _cancelPending();
    for (final delay in _attemptDelays) {
      _pending.add(Timer(delay, () => unawaited(_raiseBrowser())));
    }
  }

  /// Ends the handover. Pending attempts are dropped and, when we did move
  /// the app window out of the way, it is raised again so the user is not
  /// left looking at the browser after the login has finished.

  static void stop() {
    _cancelPending();
    if (!_ordered) return;

    _ordered = false;
    unawaited(_raiseApp());
  }

  static void _cancelPending() {
    for (final timer in _pending) {
      timer.cancel();
    }
    _pending.clear();
  }

  // window_manager force-unwraps its window handle, so an app that never
  // called ensureInitialized() in main() would crash on the first call. It is
  // idempotent, so simply making it part of our own setup is enough.

  static var _initialised = false;

  static Future<void> _ensureWindowManager() async {
    if (_initialised) return;
    await windowManager.ensureInitialized();
    _initialised = true;
  }

  static Future<void> _raiseBrowser() async {
    try {
      await _ensureWindowManager();

      // Never compete with the browser for the foreground: an app that was
      // pinned on top would otherwise cover the login page.

      if (await windowManager.isAlwaysOnTop()) {
        await windowManager.setAlwaysOnTop(false);
      }

      // Order our own window behind the browser, on macOS only: the Windows
      // implementation of blur() foregrounds whichever window happens to come
      // next in the Z-order, which could just as easily drop another app on
      // top of the login page, and on Linux it does nothing at all. Both of
      // those already hand the foreground to the browser as it is launched.

      if (Platform.isMacOS) {
        await windowManager.blur();
        _ordered = true;
      }
    } on Object catch (e) {
      debugPrint('SolidLoginBrowserFocus: could not lower the app window: $e');
    }

    if (Platform.isMacOS) await _activateMacosBrowser();
  }

  static Future<void> _raiseApp() async {
    try {
      await _ensureWindowManager();
      await windowManager.show();
      await windowManager.focus();
    } on Object catch (e) {
      debugPrint('SolidLoginBrowserFocus: could not raise the app window: $e');
    }
  }

  // Activates the application registered as the handler for https, which is
  // the browser url_launcher has just opened the login page in.

  static Future<void> _activateMacosBrowser() async {
    final bundleId = await _macosDefaultBrowser();

    // We could not say which browser holds the login page.

    if (bundleId == null) return;

    // It is not running, so it cannot be holding the login page either, and
    // activating it would start a browser the user never asked for.

    if (!await _isRunning(bundleId)) return;

    try {
      await Process.run('/usr/bin/open', ['-b', bundleId]);
    } on Object catch (e) {
      debugPrint('SolidLoginBrowserFocus: could not activate $bundleId: $e');
    }
  }

  // Strips the nested LSHandlerPreferredVersions dictionary, which repeats
  // the role key with a placeholder value, out of an LSHandlers entry.

  static final _nestedVersions = RegExp(
    r'LSHandlerPreferredVersions\s*=\s*\{[^}]*\};',
  );

  static final _httpsScheme = RegExp(r'LSHandlerURLScheme\s*=\s*"?https"?;');

  static final _handlerRole = RegExp(
    r'LSHandlerRole(?:All|Viewer)\s*=\s*"?([\w.-]+)"?;',
  );

  static final _modified = RegExp(r'LSHandlerModificationDate\s*=\s*(\d+);');

  // The https handler recorded by LaunchServices, e.g. com.brave.browser, or
  // null when it cannot be established — which is the answer whenever the
  // preferences are unreadable (a sandboxed build cannot read another
  // application's domain) or the user has never picked a browser. Deliberately
  // no fallback: an unidentified browser is one we leave alone.
  //
  // The dump holds one entry per scheme or content type. The keys within an
  // entry are not in a guaranteed order, so we look for the entry carrying the
  // https scheme and read the role key out of that same entry. The list can
  // also hold more than one https entry — a stale one left by a browser the
  // user has since moved away from — so the most recently modified entry wins
  // rather than the first one encountered.

  static Future<String?> _macosDefaultBrowser() async {
    try {
      final result = await Process.run('/usr/bin/defaults', [
        'read',
        'com.apple.LaunchServices/com.apple.launchservices.secure',
        'LSHandlers',
      ]);
      if (result.exitCode != 0) return null;

      final entries =
          '${result.stdout}'.replaceAll(_nestedVersions, '').split('},');

      String? browser;
      var newest = -1;

      for (final entry in entries) {
        if (!_httpsScheme.hasMatch(entry)) continue;

        final role = _handlerRole.firstMatch(entry);
        if (role == null) continue;

        final modified =
            int.tryParse(_modified.firstMatch(entry)?.group(1) ?? '') ?? 0;
        if (modified < newest) continue;

        browser = role.group(1);
        newest = modified;
      }

      return browser;
    } on Object catch (e) {
      debugPrint('SolidLoginBrowserFocus: no default browser found: $e');
      return null;
    }
  }

  // Whether an application with this bundle id is already running. The ids
  // LaunchServices records in its preferences are lower-cased, while the ones
  // the running applications report keep their original spelling, so the
  // comparison has to ignore case.

  static Future<bool> _isRunning(String bundleId) async {
    try {
      final result = await Process.run('/usr/bin/lsappinfo', ['list']);
      if (result.exitCode != 0) return false;

      return RegExp(
        'bundleID\\s*=\\s*"${RegExp.escape(bundleId)}"',
        caseSensitive: false,
      ).hasMatch('${result.stdout}');
    } on Object catch (e) {
      debugPrint('SolidLoginBrowserFocus: could not list applications: $e');
      return false;
    }
  }
}
