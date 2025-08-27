/// Simple SolidUI Example Application
///
// Time-stamp: <Thursday 2025-08-21 16:10:42 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
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
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Tony Chen, Graham Williams

library;

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart' show getWebId, logoutPopup;
import 'package:solidui/solidui.dart';
import 'package:window_manager/window_manager.dart';

import 'package:solidui_simple_example/login/create_solid_login.dart';

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
  
  SimpleExampleApp({super.key, this.prefs});

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
  
  HomePage({super.key, this.prefs});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _webId;

  @override
  void initState() {
    super.initState();
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
        title: 'File Manager',
        icon: Icons.folder,
        child: _buildFileManagerPage(),
        tooltip: '''

**File Manager**: Manage your POD files.

Upload, download, browse, and organise files in your Solid POD storage.

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
      userName: _webId != null ? 'Demo User' : 'Not logged in',
      webId: _webId,
      showWebId: true,
      avatarIcon: Icons.account_circle,
    );

    return SolidScaffold(
      menu: menuItems,
      appBar: SolidAppBarConfig(
        title: 'SolidUI Example',
        versionConfig: const SolidVersionConfig(
          // Compare this version with that of solidui's CHANGELOG for
          // illustration purposes. Normally it should be this app's
          // CHANGELOG. 20250820 gjw
          changelogUrl: 'https://github.com/anusii/solidui/blob/main/'
              'CHANGELOG.md',
          showDate: true,
        ),
        actions: [
          SolidAppBarAction(
            icon: Icons.refresh,
            onPressed: () => _showMessage('Refreshed'),
            tooltip: '''

**Refresh:** Tap here to refresh all data and reload the latest information.

''',
          ),
          SolidAppBarAction(
            icon: Icons.search,
            onPressed: () => _showMessage('Search functionality'),
            tooltip: '''

**Search:** Tap here to search for content.

''',
          ),
        ],
        overflowItems: [
          SolidOverflowMenuItem(
            id: 'login',
            icon: _webId != null ? Icons.logout : Icons.login,
            label: _webId != null ? 'Logout' : 'Login',
            onSelected: _toggleLogin,
          ),
        ],
      ),
      statusBar: SolidStatusBarConfig(
        serverInfo: const SolidServerInfo(
          serverUri: 'https://pods.solidcommunity.au',
          displayText: 'Demo POD Server: pods.solidcommunity.au',
        ),
        loginStatus: SolidLoginStatus(
          webId: _webId,
          onTap: _toggleLogin,
          loggedInText: 'Logged in',
          loggedOutText: 'Not logged in',
        ),
        securityKeyStatus: SolidSecurityKeyStatus(
          title: 'SolidUI Example Security Keys',
          onKeyStatusChanged: (bool hasKey) {
            _showMessage(
                'Security key status changed: ${hasKey ? 'Saved' : 'Not saved'}');
          },
        ),
        showOnNarrowScreens: false,
      ),
      userInfo: userInfo,
      onLogout: _webId != null ? (context) => _logout() : null,
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
        © 2025 Software Innovation Institute, ANU
        ''',
        text: '''

This example demonstrates key SolidUI features:

🧭 **Responsive navigation** (rail ↔ drawer)

🎨 **Theme switching** (light/dark/system)

ℹ️ **Customisable About dialogues**

📋 **Version information display**

🔐 **Security key management**

📊 **Status bar integration**

👤 **User information display**

For more information, visit the [SolidUI GitHub repository](https://github.com/anusii/solidui).

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
                  'Welcome to the SolidUI Example!\n\n'
                  'This demonstrates SolidScaffold with child parameter features:\n\n'
                  '• Responsive navigation (rail ↔ drawer)\n'
                  '• Theme switching (🌙/☀️ button)\n'
                  '• Custom About dialogue (ℹ️ button)\n'
                  '• Version information display\n'
                  '• Status bar integration\n'
                  '• Security key management\n',
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
    return const SolidFile(
      basePath: 'solidui_example',
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

  /// Toggle login status.

  void _toggleLogin() {
    if (_webId != null) {
      _logout();
    } else {
      _showLoginDialog();
    }
  }

  /// Show login dialogue.

  void _showLoginDialog() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => createSolidLogin(
          context, 
          widget.prefs!,
        ),
      ),
    );
  }

  /// Logout user using SolidPod logout.

  Future<void> _logout() async {
    try {
      // Use logoutPopup to show logout confirmation and redirect to login.

      if (widget.prefs != null) {
        await logoutPopup(
          context, 
          createSolidLogin(context, widget.prefs!),
        );
        
        // Check if user is still logged in after popup.

        try {
          final webId = await getWebId();
          if (mounted) {
            setState(() {
              _webId = webId;
            });
            if (webId == null) {
              _showMessage('Logged out successfully');
            }
          }
        } catch (e) {
          // Logout was successful.

          if (mounted) {
            setState(() {
              _webId = null;
            });
            _showMessage('Logged out successfully');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Logout failed: $e');
      }
    }
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
