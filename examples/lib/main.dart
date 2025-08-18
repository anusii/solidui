/// Simple SolidUI Example Application
///
// Time-stamp: <Monday 2025-01-27 15:30:00 +1000 Tony Chen>
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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';
import 'package:solidui/solidui.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set minimum window size for desktop platforms
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

class SimpleExampleApp extends StatelessWidget {
  const SimpleExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

/// Main home page demonstrating basic SolidScaffold usage.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _webId;

  // Simple content for each page.

  final List<String> _pageContent = [
    'Welcome to the Home page!\n\n'
        'This is a simple demonstration of SolidScaffold.'
        '\n\nThe navigation automatically switches between a side rail '
        '(on wide screens) and a drawer menu (on narrow screens).',
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
        actions: [
          SolidAppBarAction(
            icon: Icons.refresh,
            onPressed: () => _showMessage('Refreshed'),
            tooltip: 'Refresh content',
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
          serverUri: 'https://demo-pod-server.example.com',
          displayText: 'Demo POD Server',
          tooltip:
              'Demo server for testing - Click to learn more about POD servers',
          isClickable: true,
        ),
        loginStatus: SolidLoginStatus(
          webId: _webId,
          onTap: _toggleLogin,
          loggedInText: 'Logged in',
          loggedOutText: 'Not logged in',
          loggedInTooltip: 'Click to log out from POD',
          loggedOutTooltip: 'Click to log in to your POD',
        ),
        securityKeyStatus: SolidSecurityKeyStatus(
          isKeySaved: _webId != null,
          onTap: () => _showMessage('Security key management'),
          tooltip: 'Manage your security keys for data encryption',
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
      child: _buildPageContent(),
    );
  }

  /// Build the main content area.

  Widget _buildPageContent() {
    return Padding(
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
                          '• Try resizing your browser window to see responsive navigation\n'
                          '• Click the menu items to switch between pages\n'
                          '• Use the login button to simulate POD connection\n'
                          '• Check the status bar for server and connection info',
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
}
