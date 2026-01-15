/// The application scaffold configuration.
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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'constants/app.dart';
import 'home.dart';
import 'screens/sample_page.dart';

final _scaffoldController = SolidScaffoldController();

const appScaffold = AppScaffold();

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SolidScaffold(
      controller: _scaffoldController,

      // MENU.

      menu: const [
        SolidMenuItem(
          icon: Icons.home,
          title: 'Home',
          tooltip: '''

            **Home:** Tap here to return to the main page for the app.

            ''',
          child: Home(title: appTitle),
        ),
        SolidMenuItem(
          icon: Icons.folder,
          title: 'Files',
          tooltip: '''

            **Files:** Tap here to browse the files on your POD.

            ''',
          child: SolidFile(),
        ),
      ],

      // APP BAR.

      appBar: SolidAppBarConfig(
        title: appTitle.split('-')[0],

        // VERSION WIDGET.

        versionConfig: SolidVersionConfig(
          changelogUrl: 'https://github.com/anusii/solidui/blob/dev/'
              'CHANGELOG.md',
          showDate: true,
          userTextStyle: TextStyle(
            color: theme.colorScheme.onSurface,
          ),
        ),

        actions: [
          SolidAppBarAction(
            icon: Icons.folder,
            onPressed: () => _scaffoldController.navigateToSubpage(
              const SolidFile(),
            ),
            tooltip: 'Files',
          ),
          SolidAppBarAction(
            icon: Icons.article,
            onPressed: () => _scaffoldController.navigateToSubpage(
              const SamplePage(),
            ),
            tooltip: 'Sample Page',
          ),
        ],
      ),

      // STATUS BAR.

      statusBar: const SolidStatusBarConfig(
        serverInfo: SolidServerInfo(serverUri: SolidConfig.defaultServerUrl),
        loginStatus: SolidLoginStatus(),
        securityKeyStatus: SolidSecurityKeyStatus(),
      ),

      // ABOUT.

      aboutConfig: SolidAboutConfig(
        applicationName: appTitle.split(' - ')[0],
        applicationIcon: Image.asset(
          'assets/images/app_icon.png',
          width: 64,
          height: 64,
        ),
        applicationLegalese: '''

        © 2025 Software Innovation Institute, the Australian National University

        ''',
        text: '''

        This template app demonstrates the following key SolidUI features:
        
        🧭 Responsive navigation (rail ↔ drawer);
        
        🎨 Theme switching (light/dark/system);
        
        ℹ️ Customisable About dialogues;
        
        📋 Version information display;
        
        🔐 Security key management;
        
        📊 Status bar integration;
        
        👤 User information display.

        For more information, visit the
        [SolidUI](https://github.com/anusii/solidui) GitHub repository and our
        [Australian Solid Community](https://solidcommunity.au) web site.

        ''',
      ),

      // THEME DARK/LIGHT Mode.

      themeToggle: const SolidThemeToggleConfig(
        enabled: true,
        showInAppBarActions: true,
      ),

      hideNavRail: false,

      // LOGOUT.

      onLogout: (context) => SolidAuthHandler.instance.handleLogout(context),

      child: const Home(title: appTitle),
    );
  }
}
