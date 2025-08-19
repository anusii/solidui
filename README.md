# SolidUI

-----

This is a **temporary** scratch repo for developing new UI for solidpod.

The widgets here will migrate to solidpod once fully tested.

-----

A UI library for building Solid applications with Flutter.

## Overview

SolidUI provides a collection of Flutter widgets and utilities tailored for
Solid applications, offering responsive navigation components, security key
management, and status bar widgets that integrate seamlessly with Solid POD
infrastructure.

## Features

### 🧭 Navigation Components

- **SolidScaffold** - Simplified unified scaffold component with automatic
  responsive layout switching
- **SolidNavBar** - Navigation rail for wide screens
- **SolidNavDrawer** - Navigation drawer for narrow screens


### 🔐 Security Management

- **SolidSecurityKeyManager** - Comprehensive security key management interface
- **SolidSecurityKeyService** - Service layer for security key operations
- **SolidSecurityKeyView** - Display component for security key information
- **SolidSecurityKeyCentralManager** - Centralised security key coordination

### 📊 Status Components

- **SolidStatusBar** - Responsive status bar with server information, login
  status, and custom items
- **SolidStatusBarModels** - Data models for status bar configuration

### 🎨 Theme & Styling

- **SolidThemeToggleConfig** - Configurable theme switching with light/dark mode support
- Integrated theme toggle in SolidScaffold with responsive behavior

### 🛠️ Utilities & Constants

- **NavigationConstants** - Predefined constants for consistent navigation, 
  status bar heights, and UI component sizing


## Quick Start

### Installation

Add SolidUI to your `pubspec.yaml`:

```yaml
dependencies:
  solidui:
    git:
      url: https://github.com/anusii/solidui.git
      ref: main
```

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:solidui/solidui.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SolidScaffold(
        menu: [
          SolidMenuItem(
            title: 'Home',
            icon: Icons.home,
            tooltip: 'Navigate to home screen',
          ),
          SolidMenuItem(
            title: 'Settings',
            icon: Icons.settings,
            tooltip: 'Configure application settings',
          ),
        ],
        appBar: SolidAppBarConfig(
          title: 'My Solid App',
          actions: [
            SolidAppBarAction(
              icon: Icons.refresh,
              onPressed: () => print('Refresh'),
              tooltip: 'Refresh data',
            ),
          ],
        ),
        statusBar: SolidStatusBarConfig(
          serverInfo: SolidServerInfo(
            serverUri: 'https://your-pod-server.com',
            tooltip: 'Your Solid POD server',
          ),
        ),
        themeToggle: SolidThemeToggleConfig(
          enabled: true,
          currentThemeMode: ThemeMode.system,
          onToggleTheme: () {
            print('Theme toggled');
          },
        ),
        child: Center(
          child: Text('Welcome to your Solid application'),
        ),
      ),
    );
  }
}
```

## Components Reference

### SolidScaffold

The main navigation component that automatically switches between navigation
rail and drawer based on screen width.

**Key Features:**

- Responsive design (rail on wide screens, drawer on narrow screens)
- Integrated AppBar support with theme toggle
- Status bar integration
- User information display
- Logout functionality
- Built-in light/dark theme switching

**Parameters:**

- `menu` - List of menu items (required)
- `child` - Main content area (required)
- `appBar` - Optional AppBar configuration
- `statusBar` - Optional status bar configuration
- `userInfo` - Optional user information
- `onLogout` - Optional logout callback
- `themeToggle` - Optional theme toggle configuration
- `narrowScreenThreshold` - Width threshold for layout switching (default:
  NavigationConstants.narrowScreenThreshold)

### SolidAppBarConfig

Configuration for the application bar with responsive action buttons.

**Features:**

- Action buttons with responsive visibility
- Overflow menu for narrow screens
- Theme toggle integration
- Customisable tooltips

### SolidStatusBarConfig

Configuration for the bottom status bar showing server and user information.

**Features:**

- Server information display
- Login status indication
- Security key status
- Custom status items
- Responsive layout (narrow/medium/wide)

### Security Key Management

Comprehensive security key management for Solid applications:

```dart
SolidSecurityKeyManager(
  config: SolidSecurityKeyManagerConfig(
    onKeyStatusChanged: (hasKey) {
      // Handle key status changes
    },
  ),
)
```

## Responsive Design

SolidUI components automatically adapt to different screen sizes:

- **Wide screens (>800px)**: Navigation rail with full status bar
- **Medium screens (400-800px)**: Drawer navigation with compact status bar
- **Narrow screens (<400px)**: Drawer navigation with minimal status bar

## Theming

SolidUI components integrate with Flutter's theme system and support both light
and dark themes:

```dart
MaterialApp(
  theme: ThemeData.light(),
  darkTheme: ThemeData.dark(),
  themeMode: ThemeMode.system,
  home:
    YourSolidApp(),
)
```

## Advanced Usage

## Application Examples

### Basic Usage

#### Simplest Implementation

```dart
import 'package:flutter/material.dart';
import 'package:solidui/solidui.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SolidScaffold(
        menu: [
          SolidMenuItem(
            title: 'Home',
            icon: Icons.home,
            tooltip: 'Home page',
          ),
          SolidMenuItem(
            title: 'Settings',
            icon: Icons.settings,
            tooltip: 'Settings',
          ),
          SolidMenuItem(
            title: 'Profile',
            icon: Icons.person,
            tooltip: 'User profile',
          ),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
```

#### With AppBar Configuration

```dart
SolidScaffold(
  menu: [
    SolidMenuItem(title: 'Home', icon: Icons.home),
    SolidMenuItem(title: 'Settings', icon: Icons.settings),
  ],
  appBar: SolidAppBarConfig(
    title: 'My Application',
    actions: [
      SolidAppBarAction(
        icon: Icons.search,
        onPressed: () => print('Search'),
        tooltip: 'Search',
      ),
      SolidAppBarAction(
        icon: Icons.notifications,
        onPressed: () => print('Notifications'),
        tooltip: 'Notifications',
        hideOnNarrowScreen: true, // Hide on narrow screens
      ),
    ],
    overflowItems: [
      SolidOverflowMenuItem(
        id: 'help',
        icon: Icons.help,
        label: 'Help',
        onSelected: () => print('Help'),
      ),
    ],
  ),
  child: Center(
    child: Text('Main content area'),
  ),
)
```

#### With Status Bar

```dart
SolidScaffold(
  menu: [
    SolidMenuItem(title: 'Home', icon: Icons.home),
  ],
  statusBar: SolidStatusBarConfig(
    serverInfo: SolidServerInfo(
      serverUri: 'https://example.com',
      tooltip: 'Server status',
    ),
    loginStatus: SolidLoginStatus(
      webId: 'user@example.com',
      onTap: () => print('Login/Logout'),
      loggedInTooltip: 'Click to log out',
      loggedOutTooltip: 'Click to log in',
    ),
  ),
  child: Text('Content'),
)
```

#### Complete Configuration Example

```dart
class FullExampleApp extends StatefulWidget {
  @override
  _FullExampleAppState createState() => _FullExampleAppState();
}

class _FullExampleAppState extends State<FullExampleApp> {
  int _selectedIndex = 0;
  String? _webId;

  @override
  Widget build(BuildContext context) {
    return SolidScaffold(
      menu: [
        SolidMenuItem(
          title: 'Dashboard',
          icon: Icons.dashboard,
          tooltip: 'Dashboard',
          onTap: (context) {
            print('Switch to dashboard');
          },
        ),
        SolidMenuItem(
          title: 'Projects',
          icon: Icons.work,
          tooltip: 'Project management',
          color: Colors.blue,
        ),
        SolidMenuItem(
          title: 'Team',
          icon: Icons.people,
          tooltip: 'Team management',
        ),
        SolidMenuItem(
          title: 'About',
          icon: Icons.info,
          tooltip: 'About us',
          message: 'This is a sample application built using SolidScaffold',
          dialogTitle: 'About',
        ),
      ],
      appBar: SolidAppBarConfig(
        title: 'Project Management System',
        backgroundColor: Colors.blue[800],
        actions: [
          SolidAppBarAction(
            icon: Icons.search,
            onPressed: () => _showSearch(context),
            tooltip: 'Search',
          ),
          SolidAppBarAction(
            icon: Icons.notifications,
            onPressed: () => _showNotifications(context),
            tooltip: 'Notifications',
            hideOnNarrowScreen: true,
          ),
          SolidAppBarAction(
            icon: Icons.account_circle,
            onPressed: () => _showProfile(context),
            tooltip: 'User profile',
            hideOnVeryNarrowScreen: true,
          ),
        ],
        overflowItems: [
          SolidOverflowMenuItem(
            id: 'help',
            icon: Icons.help,
            label: 'Help',
            onSelected: () => _showHelp(context),
          ),
          SolidOverflowMenuItem(
            id: 'settings',
            icon: Icons.settings,
            label: 'Settings',
            onSelected: () => _showSettings(context),
          ),
        ],
      ),
      statusBar: SolidStatusBarConfig(
        serverInfo: SolidServerInfo(
          serverUri: 'https://api.example.com',
          displayText: 'API Server',
          tooltip: 'Click to access API documentation',
        ),
        loginStatus: SolidLoginStatus(
          webId: _webId,
          onTap: _toggleLogin,
          loggedInText: 'Logged In',
          loggedOutText: 'Not Logged In',
          loggedInTooltip: 'Click to log out',
          loggedOutTooltip: 'Click to log in',
        ),
        customItems: [
          SolidCustomStatusBarItem(
            id: 'version',
            widget: Text('v1.0.0'),
            priority: 1,
          ),
        ],
      ),
      userInfo: SolidNavUserInfo(
        userName: _webId != null ? 'User' : 'Not logged in',
        webId: _webId,
        showWebId: true,
      ),
      onLogout: _webId != null ? _logout : null,
      onShowAlert: _showAlert,
      themeToggle: SolidThemeToggleConfig(
        enabled: true,
        currentThemeMode: _currentThemeMode,
        onToggleTheme: _toggleTheme,
        showInAppBarActions: true,
        hideOnVeryNarrowScreen: true,
        tooltip: '''
**Theme Toggle**

Switch between light and dark modes for optimal viewing experience.

🌙 **Dark Mode**: Better for low-light environments

☀️ **Light Mode**: Better for bright environments

''',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewItem,
        tooltip: 'Add new project',
        child: Icon(Icons.add),
      ),
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'Welcome to Project Management System',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 10),
          Text(
            'Select from the menu on the left to get started',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search'),
        content: TextField(
          decoration: InputDecoration(hintText: 'Enter search keywords'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No new notifications')),
    );
  }

  void _showProfile(BuildContext context) {
    print('Show user profile');
  }

  void _showHelp(BuildContext context) {
    print('Show help');
  }

  void _showSettings(BuildContext context) {
    print('Show settings');
  }

  void _toggleLogin() {
    setState(() {
      _webId = _webId == null ? 'user@example.com' : null;
    });
  }

  void _logout(BuildContext context) {
    setState(() {
      _webId = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out')),
    );
  }

  void _showAlert(BuildContext context, String message, String? title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: title != null ? Text(title) : null,
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addNewItem() {
    print('Add new project');
  }
}
```

## Key Features

### Responsive Design
- Automatically switches layout based on screen width
- Customisable narrow screen threshold

### Simplified Menu Configuration
- Only requires defining a `SolidMenuItem` list
- Supports icons, titles, tooltips, colours, etc.

### Optional AppBar
- Supports action button lists
- Automatically handles overflow menu
- Responsive button show/hide

### Optional Status Bar
- Displays server information, login status, etc.
- Supports custom status items
- Responsive layout

### User Information Support
- Displays user information in drawer
- Supports logout functionality

### Theme Toggle Integration
- Built-in light/dark mode switching
- Responsive placement (AppBar actions or overflow menu)
- Customisable icons, tooltips, and behaviour
- Automatic theme state indication

## Parameter Reference

### SolidScaffold Main Parameters

- `menu`: List of menu items (required)
- `child`: Main content area (required)
- `appBar`: AppBar configuration (optional)
- `statusBar`: Status bar configuration (optional)
- `userInfo`: User information configuration (optional)
- `onLogout`: Logout callback (optional)
- `onShowAlert`: Alert dialogue callback (optional)
- `narrowScreenThreshold`: Narrow screen threshold (default 800)
- `backgroundColor`: Background colour (optional)
- `floatingActionButton`: Floating action button (optional)
- `initialIndex`: Initial selected menu index (default 0)
- `themeToggle`: Theme toggle configuration (optional)

### SolidMenuItem Parameters

- `title`: Menu title (required)
- `icon`: Menu icon (required)
- `color`: Icon colour (optional)
- `content`: Content component (optional)
- `tooltip`: Tooltip (optional)
- `message`: Message dialogue content (optional)
- `dialogTitle`: Dialogue title (optional)
- `onTap`: Tap callback (optional)

### SolidThemeToggleConfig Parameters

- `enabled`: Whether theme toggle is enabled (default true)
- `currentThemeMode`: Current theme mode for state indication (required)
- `onToggleTheme`: Theme toggle callback (optional)
- `showInAppBarActions`: Show in AppBar actions vs overflow menu (default true)
- `lightModeIcon`: Custom light mode icon (optional, defaults to Icons.light_mode)
- `darkModeIcon`: Custom dark mode icon (optional, defaults to Icons.dark_mode)
- `tooltip`: Custom tooltip text (optional, auto-generated if not provided)
- `label`: Label for overflow menu (default 'Toggle Theme')
- `hideOnNarrowScreen`: Hide on narrow screens (default false)
- `hideOnVeryNarrowScreen`: Hide on very narrow screens (default true)

The new `SolidScaffold` component greatly simplifies navigation usage, allowing you to create feature-rich responsive navigation interfaces with built-in theme switching and minimal code.

## Development Status

SolidUI is currently in active development as part of the Solid ecosystem 
projects.

## Licence

Copyright (C) 2025, Software Innovation Institute, ANU.

Licensed under the MIT License. See [LICENSE](LICENSE) for details.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Authors

- Tony Chen

---

For more information about Solid and PODs,
visit [solidproject.org](https://solidproject.org).
