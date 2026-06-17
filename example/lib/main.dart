/// A template app to begin a Solid Pod project.
///
// Time-stamp: <Thursday 2026-04-30 14:37:04 +1000 Graham Williams>
///
/// Copyright (C) 2024, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://opensource.org/license/gpl-3-0.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
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

    const windowOptions = WindowOptions(
      title: appTitle,
      minimumSize: Size(500, 800),
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const App());
}
