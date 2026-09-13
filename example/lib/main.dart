/// A template app to begin a Solid Pod project.
///
// Time-stamp: <Thursday 2026-04-30 14:37:04 +1000 Graham Williams>
///
/// Copyright (C) 2024, Software Innovation Institute, ANU.
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

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';
import 'package:window_manager/window_manager.dart';

import 'package:demopod/app.dart';
import 'package:demopod/constants/app.dart';

/// Whether [error] is the benign user-cancellation of an AppAuth/OIDC web
/// authentication session — for example when the user dismisses the system
/// sign-in / end-session web sheet, or when the plugin runs a background
/// session check. It does not affect app state and is safe to ignore.

bool _isBenignAuthCancellation(Object error) {
  if (error.runtimeType.toString().contains('UserCancelled')) {
    return true;
  }
  final msg = error.toString();
  return msg.contains('org.openid.appauth') &&
      (msg.contains('Code=-3') ||
          msg.contains('WebAuthenticationSession') ||
          msg.contains('UserCancelled'));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress the benign AppAuth/OIDC web-session cancellation that the plugin
  // can raise as an uncaught async error (it otherwise surfaces as an
  // "Unhandled Exception" in the console even though the operation in progress
  // — e.g. granting a permission — has already succeeded). All other errors
  // fall through to the previously installed / default handler.

  final previousOnError = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    if (_isBenignAuthCancellation(error)) {
      return true;
    }
    return previousOnError?.call(error, stack) ?? false;
  };

  if (isDesktop) {
    await windowManager.ensureInitialized();

    // Show the window at the size it was last left at, and keep that size up
    // to date as it is resized. The user sets it, and turns remembering it on
    // or off, in the Window Size section of the settings dialogue.

    await SolidWindowSize.show(
      const WindowOptions(
        title: appTitle,
        minimumSize: Size(500, 800),
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      ),
    );
  }

  runApp(const App());
}
