/// The application scaffold configuration.
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

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:demopod/constants/app.dart';
import 'package:demopod/home.dart';

const appScaffold = AppScaffold();

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return SolidScaffold(
      menu: const [
        SolidMenuItem(
          icon: Icons.home,
          title: 'Home',
          tooltip: '''

            **Home**

            Tap here to return to the main demonstrator page.

            ''',
          child: Home(),
        ),
        SolidMenuItem(
          icon: Icons.folder,
          title: 'Files',
          tooltip: '''

            **Files**

            Tap here to browse the files on your POD.

            ''',
          child: SolidFile(),
        ),
      ],
      appBar: SolidAppBarConfig(
        title: appTitle.split(' - ')[0],
        versionConfig: const SolidVersionConfig(
          changelogUrl: 'https://github.com/anusii/solidpod/blob/dev/'
              'CHANGELOG.md',
          showDate: true,
          showUpdateButton: true,
          downloadUrl: 'https://github.com/anusii/solidpod/releases/latest',
        ),
      ),
      statusBar: const SolidStatusBarConfig(
        serverInfo: SolidServerInfo(serverUri: SolidConfig.defaultServerUrl),
        loginStatus: SolidLoginStatus(),
        securityKeyStatus: SolidSecurityKeyStatus(),
      ),
      aboutConfig: SolidAboutConfig(
        applicationName: appTitle.split(' - ')[0],
        applicationIcon: Image.asset(
          'assets/images/demopod_logo.png',
          width: 64,
          height: 64,
        ),
        applicationLegalese: '''

        © 2024-2026 Software Innovation Institute, the Australian National University

        ''',
        text: '''

        DemoPod is a demonstrator application for the solidpod and solidui
        Flutter packages.

        It showcases various features including:

        📂 Reading and writing data files on your Solid POD;

        🔑 Security key management;

        🔐 ACL inheritance for resources;

        🤝 Permission management and sharing;

        🧭 Setup wizard demonstration;

        🎨 Theme switching (light/dark/system);

        🧭 Responsive navigation (rail ↔ drawer).

        For more information, visit the
        [SolidPod](https://github.com/anusii/solidpod) GitHub repository.

        ''',
      ),
      showNotifications: true,
      themeToggle: const SolidThemeToggleConfig(
        enabled: true,
        showInAppBarActions: true,
      ),
      enableProfile: true,
      enableOverflowMenu: true,
      onLogout: (context) => SolidAuthHandler.instance.handleLogout(context),
      child: const Home(),
    );
  }
}
