/// The application scaffold configuration.
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

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:demopod/constants/app.dart';
import 'package:demopod/home.dart';

final appScaffold = AppScaffold();

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final _scaffoldController = SolidScaffoldController();

  @override
  void dispose() {
    _scaffoldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SolidScaffold(
      controller: _scaffoldController,
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

        © 2024 Software Innovation Institute, the Australian National University

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
      themeToggle: const SolidThemeToggleConfig(
        enabled: true,
        showInAppBarActions: true,
      ),
      enableProfile: true,
      onLogout: (context) => SolidAuthHandler.instance.handleLogout(context),

      // SETTINGS.

      settingsWidget: IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () => _scaffoldController.navigateToSubpage(
          const _MySettings(),
        ),
        tooltip: 'Settings',
      ),

      child: const Home(title: appTitle),
    );
  }
}

class _MySettings extends StatelessWidget {
  const _MySettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Settings')),
      body: const Center(child: Text('This is a custom settings page.')),
    );
  }
}
