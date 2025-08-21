/// Simple SolidUI Example Application
///
// Time-stamp: <Thursday 2025-08-21 13:16:28 +1000 Graham Williams>
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

import 'package:solidui/solidui.dart';
import 'package:window_manager/window_manager.dart';

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

  runApp(const SimpleExampleApp());
}

/// Simple example app demonstrating SolidScaffold basic usage.

class SimpleExampleApp extends StatefulWidget {
  const SimpleExampleApp({super.key});

  @override
  State<SimpleExampleApp> createState() => _SimpleExampleAppState();
}

class _SimpleExampleAppState extends State<SimpleExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      switch (_themeMode) {
        case ThemeMode.system:
          _themeMode = ThemeMode.light;
          break;
        case ThemeMode.light:
          _themeMode = ThemeMode.dark;
          break;
        case ThemeMode.dark:
          _themeMode = ThemeMode.system;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Turn off debug banner for now.

      debugShowCheckedModeBanner: false,
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
      themeMode: _themeMode,
      home: HomePage(
        currentThemeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

/// Main home page demonstrating SolidScaffold with theme and About features.

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.currentThemeMode,
    required this.onToggleTheme,
  });

  final ThemeMode currentThemeMode;
  final VoidCallback onToggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _webId;

  // Simple content for each page.

  List<String> get _pageContent => [
        'Welcome to the SolidUI Example!\n\n'
            'This demonstrates SolidScaffold with theme toggle and About features:\n\n'
            '• Responsive navigation (rail ↔ drawer)\n'
            '• Theme switching (🌙/☀️ button)\n'
            '• Custom About dialogue (ℹ️ button)\n'
            '• Version information display\n'
            '• Status bar integration\n'
            '• Security key management\n\n'
            'Try clicking the theme toggle button in the top-right!\n'
            'Current theme: ${_getThemeModeText()}',
        'About page\n\nThis example shows how easy it is to use SolidScaffold:\n\n'
            '1. Define your menu items\n'
            '2. Set up your content\n'
            '3. Let SolidScaffold handle the rest!\n\n'
            'The navigation is fully responsive and includes POD server '
            'integration.',
        'Settings page\n\nHere you would typically include:\n\n'
            '• User preferences\n'
            '• Application settings\n'
            '• Account management\n'
            '• Data synchronisation options\n\n'
            'The status bar below shows your connection status and server '
            'information.',
      ];

  // Build the widget.

  @override
  Widget build(BuildContext context) {
    // Create simple menu items.

    final menuItems = [
      const SolidMenuItem(
        title: 'Home',
        icon: Icons.home,
        tooltip: 'Home page',
      ),
      const SolidMenuItem(
        title: 'About',
        icon: Icons.info,
        tooltip: 'About this application',
      ),
      const SolidMenuItem(
        title: 'Settings',
        icon: Icons.settings,
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
        title: menuItems[_selectedIndex].title,
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
      selectedIndex: _selectedIndex,
      onMenuSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      themeToggle: SolidThemeToggleConfig(
        enabled: true,
        currentThemeMode: widget.currentThemeMode,
        onToggleTheme: widget.onToggleTheme,
        showInAppBarActions: true,
        hideOnVeryNarrowScreen: false,
      ),
      aboutConfig: const SolidAboutConfig(
        applicationName: 'SolidUI Example',
        applicationIcon: Icon(
          Icons.widgets,
          size: 64,
          color: Colors.blue,
        ),
        children: [
          Text(
            'This example demonstrates key SolidUI features:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text('🧭 Responsive navigation (rail ↔ drawer)'),
          Text('🎨 Theme switching (light/dark/system)'),
          Text('ℹ️ Customisable About dialogues'),
          Text('📋 Version information display'),
          Text('🔐 Security key management'),
          Text('📊 Status bar integration'),
          Text('👤 User information display'),
          SizedBox(height: 16),
        ],
      ),
      child: _buildPageContent(),
    );
  }

  /// Build the main content area.

  Widget _buildPageContent() {
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
                  _getPageIcon(),
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  _pageContent[_selectedIndex],
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                if (_selectedIndex == 0) // Show additional info on home page.
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
                          '• View the status bar for server and connection info'
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

  /// Get icon for current page.

  IconData _getPageIcon() {
    switch (_selectedIndex) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.info;
      case 2:
        return Icons.settings;
      default:
        return Icons.home;
    }
  }

  /// Toggle login status.

  void _toggleLogin() {
    setState(() {
      _webId = _webId == null
          ? 'https://demo-user.example-pod.com/profile/card#me'
          : null;
    });
    _showMessage(_webId != null ? 'Logged in successfully' : 'Logged out');
  }

  /// Logout user.

  void _logout() {
    setState(() {
      _webId = null;
    });
    _showMessage('Logged out successfully');
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

  /// Get theme mode text for display.

  String _getThemeModeText() {
    switch (widget.currentThemeMode) {
      case ThemeMode.light:
        return 'Light Mode ☀️';
      case ThemeMode.dark:
        return 'Dark Mode 🌙';
      case ThemeMode.system:
        return 'System Mode 🖥️';
    }
  }
}
