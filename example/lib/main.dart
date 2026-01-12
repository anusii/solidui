/// SolidUI Template Application
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
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
/// Authors: Tony Chen, Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart' show KeyManager, setAppDirName;
import 'package:solidui/solidui.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'app_scaffold.dart';
import 'constants/app.dart';
import 'utils/is_desktop.dart';

/// Main entry point for the [MyApp] application.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // CRITICAL: Set app directory name BEFORE any Pod operations
  await setAppDirName('myapp');

  // Configure SolidAuthHandler with app-specific settings
  SolidAuthHandler.instance.configure(
    SolidAuthConfig(
      appTitle: appTitle,
      appDirectory: 'myapp',
      defaultServerUrl: 'https://pods.solidcommunity.au',
      appImage: const AssetImage('assets/images/app_image.jpg'),
      appLogo: const AssetImage('assets/images/app_icon.jpg'),
      loginSuccessWidget: appScaffold,
      onSecurityKeyReset: () async {
        await KeyManager.clear();
        debugPrint('MyApp: Security key cleared on logout');
      },
    ),
  );

  // Set window options for desktop platforms (Windows, Linux, macOS).

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
