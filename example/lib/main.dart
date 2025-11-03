/// Simple SolidUI Example Application
///
// Time-stamp: <Monday 2025-09-01 14:40:06 +1000 Graham Williams>
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

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart' show getWebId;
import 'package:solidui/solidui.dart';
import 'package:window_manager/window_manager.dart';

import 'login/create_solid_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set minimum window size for desktop platforms.

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
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

  runApp(const SolidUIExampleApp());
}

/// Main SolidUI example app that handles login and main application.

class SolidUIExampleApp extends StatelessWidget {
  const SolidUIExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SolidUI Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const LoginWrapper(),
    );
  }
}

/// Wrapper that handles login state and navigation.

class LoginWrapper extends StatefulWidget {
  const LoginWrapper({super.key});

  @override
  State<LoginWrapper> createState() => _LoginWrapperState();
}

class _LoginWrapperState extends State<LoginWrapper> {
  SharedPreferences? _prefs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_prefs == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error loading application preferences'),
        ),
      );
    }

    return createSolidLogin(context, _prefs!);
  }
}

/// Simple example app demonstrating SolidScaffold basic usage.

class SimpleExampleApp extends StatefulWidget {
  final SharedPreferences? prefs;

  const SimpleExampleApp({super.key, this.prefs});

  @override
  State<SimpleExampleApp> createState() => _SimpleExampleAppState();
}

class _SimpleExampleAppState extends State<SimpleExampleApp> {
  @override
  Widget build(BuildContext context) {
    return SolidThemeApp(
      title: 'SolidUI Simple Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomePage(prefs: widget.prefs),
    );
  }
}

/// Main home page demonstrating SolidScaffold with theme and About features.

class HomePage extends StatefulWidget {
  final SharedPreferences? prefs;

  const HomePage({super.key, this.prefs});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _webId;

  @override
  void initState() {
    super.initState();

    // Configure the integrated authentication handler.

    SolidAuthHandler.instance.configure(
      SolidAuthConfig(
        loginPageBuilder: (context) => createSolidLogin(context, widget.prefs!),
        // defaultServerUrl: 'https://pods.dev.solidcommunity.au',
        defaultServerUrl: 'https://solid.dev.empwr.au',
        appTitle: 'SolidUI Example',
        appDirectory: 'solidui_example',
        appImage: const AssetImage('assets/images/app_image.jpg'),
        appLogo: const AssetImage('assets/images/app_icon.png'),
        appLink: 'https://github.com/anusii/solidui',
      ),
    );

    _loadUserInfo();
  }

  /// Load user information from Solid POD.

  Future<void> _loadUserInfo() async {
    try {
      final webId = await getWebId();
      if (mounted) {
        setState(() {
          _webId = webId;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _webId = null;
        });
      }
    }
  }

  // Build the widget.

  @override
  Widget build(BuildContext context) {
    // Create simple menu items.

    final menuItems = [
      SolidMenuItem(
        title: 'Home',
        icon: Icons.home,
        child: _buildHomePage(),
        tooltip: 'Home page',
      ),
      SolidMenuItem(
        title: 'Files',
        icon: Icons.folder,
        child: _buildFileManagerPage(),
        tooltip: '''

        **Files**: Tap here to directly manage your POD files as created for the
        app. You can upload, download, browse, and organise the files in your
        Solid POD storage through this tab.

        ''',
      ),
      SolidMenuItem(
        title: 'About',
        icon: Icons.info,
        child: _buildAboutPage(),
        tooltip: 'About this application',
      ),
      SolidMenuItem(
        title: 'Settings',
        icon: Icons.settings,
        child: _buildSettingsPage(),
        tooltip: 'Application settings',
      ),
    ];

    // Create user info.

    final userInfo = SolidNavUserInfo(
      webId: _webId,
      showWebId: true,
      avatarIcon: Icons.account_circle,
      versionConfig: const SolidVersionConfig(
        changelogUrl: 'https://github.com/anusii/solidui/blob/dev/'
            'CHANGELOG.md',
        showDate: true,
      ),
    );

    return SolidScaffold(
      menu: menuItems,
      appBar: SolidAppBarConfig(
        title: 'SolidUI Example',
        versionConfig: const SolidVersionConfig(
          // Compare this version with that of solidui's CHANGELOG for
          // illustrative purposes. Normally you will specifcy this app's
          // CHANGELOG.

          changelogUrl: 'https://github.com/anusii/solidui/blob/dev/'
              'CHANGELOG.md',
          showDate: true,
        ),
        actions: [
          SolidAppBarAction(
            icon: Icons.refresh,
            onPressed: () => _showMessage('Refreshed'),
            tooltip: '''

            **Refresh:** Tap here to refresh all data and reload the latest
            information. This option is a placeholder and when tapped will
            simply display a popup for illustrative purposes.

            ''',
          ),
          SolidAppBarAction(
            icon: Icons.search,
            onPressed: () => _showMessage('Search functionality'),
            tooltip: '''

            **Search:** Tap here to search for content. This option is a
            placeholder and when tapped will simply display a popup for
            illustrative purposes.

            ''',
          ),
        ],
        overflowItems: [],
      ),
      statusBar: SolidStatusBarConfig(
        serverInfo: _webId != null
            ? SolidServerInfo.fromWebId(
                _webId!,
                tooltip: '''

**WebID:** This is your complete WebID including both server and username
where your data is stored securely.

Tap to visit your server in the browser.

''',
              )
            : null,
        loginStatus: SolidLoginStatus(
          webId: _webId,
          loggedInText: 'Logged in',
          loggedOutText: 'Not logged in',
        ),
        securityKeyStatus: SolidSecurityKeyStatus(
          title: 'SolidUI Example Security Keys',
          onKeyStatusChanged: (bool hasKey) {
            // _showMessage('Security key status changed: '
            //     '${hasKey ? 'Saved' : 'Not saved'}');
          },
        ),
        showOnNarrowScreens: false,
      ),
      userInfo: userInfo,
      themeToggle: const SolidThemeToggleConfig(
        enabled: true,
        showInAppBarActions: true,
        showOnVeryNarrowScreen: false,
      ),
      aboutConfig: const SolidAboutConfig(
        applicationName: 'SolidUI Example',
        applicationIcon: Icon(
          Icons.widgets,
          size: 64,
          color: Colors.blue,
        ),
        applicationLegalese: '''

        © 2025 Software Innovation Institute, the Australian National University

        ''',
        text: '''

        This template app demonstrates the following key SolidUI features: 🧭
        Responsive navigation (rail ↔ drawer); 🎨 Theme switching
        (light/dark/system); ℹ️ Customisable About dialogues; 📋 Version
        information display; 🔐 Security key management; 📊 Status bar
        integration; 👤 User information display.

        For more information, visit the
        [SolidUI](https://github.com/anusii/solidui) GitHub repository and our
        [Australian Solid Community](https://solidcommunity.au) web site.

        ''',
      ),
    );
  }

  /// Build the home page content.

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.home,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  wordWrap('''
                  Welcome to the SolidUI Template App!

                  This template app serves to demonstrate the SolidScaffold()
                  widget which extends the standard Flutter Scaffold()
                  widget. It provides a left hand rail for selecting features,
                  an app bar with some standard buttons, and a status bar to
                  show current parameters. The Solid Scaffold adds parameters
                  for:

                  • **Responsive navigation** including the option to present as
                    a left hand rail or a menu drawer depending on screen width;

                  • **Theme switching** using the 🌙/☀️ button to choose light,
                    dark, or system colour themes.

                  • A **Custom About** dialogue invoked with the ℹ️ button to
                    provide information abut the app;

                  • A **Version** widget displays latest version information
                    with a link to the latest changelog, usually on github;

                  • An integration **Status Bar** can be used to display POD
                    connectivity information;

                  • Security key management

                  '''),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Start:',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Try resizing your window to see responsive navigation\n'
                        '• Click menu items to switch between pages\n'
                        '• Use the login button to simulate POD connection\n'
                        '• Check the version widget for changelog access\n'
                        '• View the status bar for server and connection info\n'
                        '• Click the theme toggle button (🌙/☀️) in the top-right\n'
                        '• Click the About button (ℹ️) to see custom app info\n',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build the file manager page content.

  Widget _buildFileManagerPage() {
    return SolidFile(
      basePath: 'solidui_example',
      currentPath: 'solidui_example',
      onBackPressed: () {
        _showMessage('Back to home folder');
      },
      onFileSelected: (fileName, filePath) {
        _showMessage('File selected: $fileName');
      },
      onDirectoryChanged: (path) {
        _showMessage('Directory changed: $path');
      },
      onImportCsv: (fileName, filePath) {
        _showMessage('CSV import: $fileName');
      },
    );
  }

  /// Build the about page content.

  Widget _buildAboutPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'About SolidUI\n\n'
                  'SolidUI simplifies building Solid applications:\n\n'
                  '1. Define your menu items with child widgets\n'
                  '2. Set up your SolidScaffold\n'
                  '3. Let SolidScaffold handle the rest!\n\n'
                  'The navigation is fully responsive and includes POD server '
                  'integration. Each menu item can now directly contain its '
                  'child widget for simplified development.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build the settings page content.

  Widget _buildSettingsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.settings,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Settings page\n\n'
                  'Here you would typically include:\n\n'
                  '• User preferences\n'
                  '• Application settings\n'
                  '• Account management\n'
                  '• Data synchronisation options\n\n'
                  'The status bar below shows your connection status and server '
                  'information. Each page is now independently defined in its '
                  'own widget for better organisation.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show a simple message.

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
