/// Remember the desktop window size between sessions.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.
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

import 'dart:async';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'package:solidui/src/utils/is_desktop.dart';

/// Opens the desktop window at the size it was last left at, and keeps that
/// size up to date as the user resizes it.
///
/// Call [show] from `main()` in place of `windowManager.waitUntilReadyToShow`,
/// after `windowManager.ensureInitialized()`:
///
/// ```dart
/// await windowManager.ensureInitialized();
/// await SolidWindowSize.show(
///   const WindowOptions(title: appTitle, minimumSize: Size(500, 800)),
/// );
/// ```
///
/// Everything else — saving the size as the window is resized, and the
/// Window Size section of the settings dialogue — follows from that one
/// call. On the web and on mobile every method here does nothing.

class SolidWindowSize {
  SolidWindowSize._();

  /// The preference the window width is remembered in.

  static const String widthPref = 'solidui.windowWidth';

  /// The preference the window height is remembered in.

  static const String heightPref = 'solidui.windowHeight';

  /// Whether the size the user leaves the window at is remembered. When off,
  /// the window opens at whatever size was last set through the settings
  /// dialogue, however the user resizes it in between.

  static const String rememberPref = 'solidui.rememberWindowSize';

  /// The smallest window that will ever be saved or restored. A window that
  /// is minimised or mid-transition can report a size of no use to anybody,
  /// and saving it would leave the app opening too small to use.

  static const double minimumDimension = 100;

  static final _SolidWindowSizeObserver _observer = _SolidWindowSizeObserver();

  static bool _watching = false;

  /// Show the window at its remembered size, then keep that size up to date.
  ///
  /// [options] is the app's own window configuration — title, minimum size
  /// and so on. Its `size` is replaced by the remembered one when there is
  /// one to restore. Until then no size is passed at all, so each platform
  /// keeps the default set in its own runner (`linux/my_application.cc`,
  /// `windows/runner/main.cpp`), which stays the app's default.

  static Future<void> show(WindowOptions options) async {
    if (!isDesktop) return;

    final Size? size = await saved();

    await windowManager.waitUntilReadyToShow(
      size == null ? options : _withSize(options, size),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );

    watch();
  }

  /// Start saving the size as the window is resized.
  ///
  /// Called by [show], so an app has no reason to call it itself.

  static void watch() {
    if (!isDesktop || _watching) return;
    _watching = true;
    windowManager.addListener(_observer);
  }

  /// The size the window is at now, or null when off the desktop.

  static Future<Size?> current() async =>
      isDesktop ? windowManager.getSize() : null;

  /// The remembered size, or null while there is none to restore.

  static Future<Size?> saved() async {
    final prefs = await SharedPreferences.getInstance();
    final double? width = prefs.getDouble(widthPref);
    final double? height = prefs.getDouble(heightPref);

    if (width == null || height == null) return null;

    return Size(width, height);
  }

  /// Remember the size the window is at now.
  ///
  /// 20260913 gjw Called as the window is resized, and not only as the app
  /// closes, because on the Linux desktop the app-lifecycle callbacks are not
  /// reliably delivered on a window close. A size saved only on the way out is
  /// a size lost whenever the app is closed by any other means.

  static Future<void> save() async {
    if (!isDesktop) return;
    if (!await remembering()) return;

    final Size size = await windowManager.getSize();
    if (size.width < minimumDimension || size.height < minimumDimension) return;

    await _store(size);
  }

  /// Resize the window to [size] now, and remember it.
  ///
  /// Returns false, changing nothing, for a size too small to be usable.

  static Future<bool> resize(Size size) async {
    if (size.width < minimumDimension || size.height < minimumDimension) {
      return false;
    }

    if (isDesktop) await windowManager.setSize(size);
    await _store(size);

    return true;
  }

  /// Whether the size the user leaves the window at is remembered.

  static Future<bool> remembering() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(rememberPref) ?? true;
  }

  /// Turn remembering the size on or off.

  static Future<void> setRemembering(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(rememberPref, value);
  }

  /// Forget the remembered size, so the next start opens at the app's own
  /// default. The window on screen is left as it is.

  static Future<void> forget() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(widthPref);
    await prefs.remove(heightPref);
  }

  static Future<void> _store(Size size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(widthPref, size.width);
    await prefs.setDouble(heightPref, size.height);
  }

  /// [options] with its size replaced, there being no copyWith on
  /// WindowOptions.

  static WindowOptions _withSize(WindowOptions options, Size size) =>
      WindowOptions(
        size: size,
        center: options.center,
        minimumSize: options.minimumSize,
        maximumSize: options.maximumSize,
        alwaysOnTop: options.alwaysOnTop,
        fullScreen: options.fullScreen,
        backgroundColor: options.backgroundColor,
        skipTaskbar: options.skipTaskbar,
        title: options.title,
        titleBarStyle: options.titleBarStyle,
        windowButtonVisibility: options.windowButtonVisibility,
      );
}

/// Saves the window size once the user stops dragging its edge.
///
/// A resize arrives for every frame of the drag, so the save waits for the
/// dragging to stop rather than writing to the preferences hundreds of times.

class _SolidWindowSizeObserver extends WindowListener {
  Timer? _settle;

  @override
  void onWindowResize() {
    _settle?.cancel();
    _settle = Timer(
      const Duration(seconds: 1),
      SolidWindowSize.save,
    );
  }
}
