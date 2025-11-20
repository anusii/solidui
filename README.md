<!-- markdownlint-disable MD033 MD045 MD013 -->

# SolidUI

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

[![GitHub License](https://img.shields.io/github/license/anusii/solidui)](https://raw.githubusercontent.com/anusii/solidui/dev/LICENSE)
[![GitHub Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/anusii/solidui/master/pubspec.yaml&query=$.version&label=version&logo=github)](https://github.com/anusii/solidui/blob/dev/CHANGELOG.md)
[![Pub Version](https://img.shields.io/pub/v/solidui?label=pub.dev&labelColor=333940&logo=flutter)](https://pub.dev/packages/solidui)
[![GitHub Last Updated](https://img.shields.io/github/last-commit/anusii/solidui?label=last%20updated)](https://github.com/anusii/solidui/commits/dev/)
[![GitHub Commit Activity (dev)](https://img.shields.io/github/commit-activity/w/anusii/solidui/dev)](https://github.com/anusii/solidui/commits/dev/)
[![GitHub Issues](https://img.shields.io/github/issues/anusii/solidui)](https://github.com/anusii/solidui/issues)

A comprehensive UI library for building Solid applications with
Flutter. SolidUI provides responsive navigation components, file
management capabilities, security key handling, and authentication
features specifically designed for Solid POD applications.

## Table of Contents

- [Installation](#installation)
- [Requirements](#requirements)
- [SolidScaffold](#solidscaffold)
- [SolidFile](#solidfile)
- [Authentication and Login Detection](#authentication-and-login-detection)
- [Security Key Management](#security-key-management)
- [API Reference](#api-reference)
- [Examples](#examples)

## Installation

Add SolidUI to your `pubspec.yaml`:

```shell
dart pub add solidui
```

## Features

- **SolidLogin** widget supports authentication against a Solid server.

Default style:

<div align="center">
 <img
 src="https://raw.githubusercontent.com/anusii/solidui/main/assets/screenshots/solid_login.png"
 alt="Solid Login" width="400">
</div>

Optional version and visit link:

<div align="center">
 <img
 src="https://raw.githubusercontent.com/anusii/solidui/main/assets/screenshots/podnotes_login.png"
 alt="Solid Login" width="400">
</div>

Changing the image, logo, login text, colour scheme:

<div align="center">
 <img
 src="https://raw.githubusercontent.com/anusii/solidui/main/assets/screenshots/tomy_login.png"
 alt="KeyPod Login" width="400">
</div>

Change the image, logo, login text, button style, colour scheme:

<div align="center">
 <img
 src="https://raw.githubusercontent.com/anusii/solidui/main/assets/screenshots/keypod_login.png"
 alt="KeyPod Login" width="400">
</div>

Fine tune to suit the theme of the app:

<div align="center">
 <img
 src="https://raw.githubusercontent.com/anusii/solidui/main/assets/screenshots/innerpod_login.png"
 alt="KeyPod Login" width="400">
</div>

- `SolidPopupLogin` widget supports authentication within an
  application. The widget will trigger authentication if a user action
  requires authenticated access.

- [changeKeyPopup](#change-security-key-example) widget supports
  changing the security key (used to make your data private through
  encryption):

<div align="center">
 <img
 src="https://raw.githubusercontent.com/anusii/solidui/main/assets/screenshots/change_security_key.png"
 alt="KeyPod Login" width="400">
</div>

- readPod() function reads file content
  (either encrypted or plaintext) from a Pod.

- writePod() function writes content
  (either encrypted or plaintext) to a file in a Pod.

- GrantPermissionUi widget supports
  permission granting/revoking for resources:
  - For defining specific access mode types or recipient types, use
    optional parameters `accessModeList` and `recipientTypeList`.

Granting permission (currently ublished in solidpod):
<div align="center">
 <img
 src="https://raw.githubusercontent.com/anusii/solidui/main/assets/screenshots/grant_permission.png"
 alt="KeyPod Login" width="400">
</div>

Revoking permission:
<div align="center">
 <img
 src="https://raw.githubusercontent.com/anusii/solidui/main/assets/screenshots/revoke_permission.png"
 alt="KeyPod Login" width="400">
</div>

- SharedResourcesUi widget displays
  resources shared with a Pod by others (currently published in
  solidpod):

<div align="center">
 <img
 src="https://raw.githubusercontent.com/anusii/solidui/main/assets/screenshots/view_permission.png"
 alt="KeyPod Login" width="400">
</div>

## Requirements

- Flutter SDK: `>=3.2.3 <4.0.0`
- Dart: Compatible with Flutter requirements

### Dependencies

SolidUI requires the following dependencies:

- `solidpod`: Solid POD integration
- `flutter_markdown`: Markdown rendering support
- `file_picker`: File selection functionality
- `shared_preferences`: Local storage for settings
- `package_info_plus`: Application metadata access
- `url_launcher`: URL launching capabilities
- `markdown_tooltip`: Markdown-enabled tooltips
- `rdflib`: RDF data handling
- `gap`: Spacing utilities
- `path`: Path manipulation
- `version_widget`: Version display widget

## Quick Start to Create an App

To create a new Solid-based app using `solidui` named `myapp` and
published by `example.com` begin with:

```bash
flutter create --template solidui --domain com.example myapp
```

This will create a template app which we also included here under the
`example/` directory. The app consists of several files within the
`lib/` directory.  `main.dart` is the main entry point to the app. Its
task in our framework is to initialise the application and then launch
the app itself.  `app.dart` implements the `App()` which is typically
where we instantiate a `SolidLogin()`, often as the `child:` of a
`SolidThemeApp()`.  The `SolidLogin()` provides the login page for the
app. After logging in the `AppScaffold()`, as the `child:` of the
`SolidLogin()`, is instantiated to contain the main functionality of
the app.  `app_scaffold.dart` implements the `AppScaffold()` widget
which builds a `SolidScaffold()` to set up the framework for a typical
Solid app. The child is the `Home()` widget. `home.dart` implements
the `Home()` widget as the main app functionality. Constants are
defined in `constants/app.dart` and utilities such as desktop platform
detection are in `utils/is_desktop.dart`.

## SolidScaffold

The `SolidScaffold()` is the primary widget for building Solid
applications with responsive navigation, an app bar, status bar, and
integrated functionality. A `SolidScaffold()` automatically adapts its
layout based on screen size, providing an optimal user experience
across different devices.

### Responsive Navigation Behaviour

`SolidScaffold()` intelligently switches between different navigation
modes based on the screen width:

- **Wide screens (≥800px)**: Display a vertical navigation rail
  `SolidNavBar()` on the left side;
- **Narrow screens (<800px)**: Replace the navigation rail with a
  collapsible navigation drawer `SolidNavDrawer()` accessible via a
  hamburger menu;
- **Custom threshold**: The breakpoint can be customised using the
  `narrowScreenThreshold` parameter with a value of 0 turning off the
  hamburger menu and a large value effectively turning off the
  vertical navigation rail.

A responsive behaviour ensures that your application provides an
optimal navigation experience whether users are on desktop computers,
tablets, or mobile devices, running the app natively or through a
browser. The transition between navigation modes is seamless and
automatic.

### Constructor Parameters

```dart
SolidScaffold({
  Key? key,

  // Navigation
  List<SolidMenuItem>? menu,
  Widget? child,
  int initialIndex = 0,
  void Function(int)? onMenuSelected,
  int? selectedIndex,

  // Scaffold Compatibility
  Widget? body,
  PreferredSizeWidget? scaffoldAppBar,
  Widget? drawer,
  Widget? endDrawer,
  Widget? bottomNavigationBar,
  Widget? bottomSheet,
  List<Widget>? persistentFooterButtons,
  bool? resizeToAvoidBottomInset,

  // SolidUI Components
  dynamic appBar,
  SolidStatusBarConfig? statusBar,
  SolidNavUserInfo? userInfo,
  SolidThemeToggleConfig? themeToggle,
  SolidAboutConfig? aboutConfig,

  // Callbacks
  void Function(BuildContext)? onLogout,
  void Function(BuildContext, String, String?)? onShowAlert,

  // Layout Configuration
  double narrowScreenThreshold = NavigationConstants.narrowScreenThreshold,
  Color? backgroundColor,

  // Floating Action Button
  Widget? floatingActionButton,
  FloatingActionButtonLocation? floatingActionButtonLocation,
  FloatingActionButtonAnimator? floatingActionButtonAnimator,

  // Drawer Configuration
  DrawerCallback? onDrawerChanged,
  DrawerCallback? onEndDrawerChanged,
  DragStartBehavior drawerDragStartBehavior = DragStartBehavior.start,
  bool drawerEnableOpenDragGesture = true,
  bool endDrawerEnableOpenDragGesture = true,
  Color? drawerScrimColor,
  double? drawerEdgeDragWidth,

  // Other Properties
  bool primary = true,
  bool extendBody = false,
  bool extendBodyBehindAppBar = false,
  String? restorationId,
})
```

### Menu Items

```dart
class SolidMenuItem {
  final String title;                       // Required: Menu display title
  final IconData icon;                      // Required: Menu icon
  final Color? color;                       // Optional: Icon colour
  final Widget? child;                      // Optional: Content widget when selected
  final String? tooltip;                    // Optional: Tooltip message (Markdown)
  final String? message;                    // Optional: Dialogue message content
  final String? dialogTitle;                // Optional: Dialogue title
  final void Function(BuildContext)? onTap; // Optional: Tap callback
}
```

### App Bar Configuration

The app bar provides application title, action buttons, and overflow
menu items. Action buttons automatically move to an overflow menu on
smaller screens to maintain usability.

```dart
class SolidAppBarConfig {
  final String title;                         // App bar title
  final List<SolidAppBarAction>? actions;     // Action buttons
  final List<SolidOverflowMenuItem>? overflowItems; // Overflow menu items
  final Color? backgroundColor;               // Background colour
  final SolidVersionConfig? versionConfig;    // Version display configuration
}
```

**App Bar Responsive Features:**

- **Action overflow**: Buttons automatically move to overflow menu
  when screen width decreases
- **Visibility control**: Individual actions can be configured to hide
  on narrow or very narrow screens
- **Theme integration**: Theme toggle and about buttons automatically
  adapt their placement
- **Version display**: Version information adjusts its display format
  based on available space

```dart
class SolidAppBarAction {
  final IconData icon;               // Required: Button icon
  final VoidCallback onPressed;      // Required: Press callback
  final String? tooltip;             // Optional: Tooltip message
  final Color? color;                // Optional: Icon colour
  final bool showOnNarrowScreen;     // Narrow screens (default: true)
  final bool showOnVeryNarrowScreen; // Very narrow screens (default: true)
}

class SolidOverflowMenuItem {
  final String id;                   // Required: Unique identifier
  final IconData icon;               // Required: Menu icon
  final String label;                // Required: Menu label
  final VoidCallback onSelected;     // Required: Selection callback
  final bool showInOverflow;         // Show in overflow menu (default: true)
}
```

### Status Bar Configuration

The status bar provides real-time information about server
connectivity, login status, and security key state. It adapts its
layout and content based on screen size.

```dart
class SolidStatusBarConfig {
  final SolidServerInfo? serverInfo;       // Server information display
  final SolidLoginStatus? loginStatus;     // Login status display
  final SolidSecurityKeyStatus? securityKeyStatus; // Security key status
  final List<SolidCustomStatusBarItem>? customItems; // Custom status items
  final bool showOnNarrowScreens;          // Narrow screens (default: true)
  final SolidStatusBarLayout layout;       // Layout configuration
}
```

**Status Bar Responsive Behaviour:**

- **Wide screens**: All status items displayed with full text and
  icons
- **Medium screens**: Condensed layout with essential information
- **Narrow screens**: Can be hidden entirely or show minimal status
  information
- **Custom items**: Support priority-based display for responsive
  layouts

```dart
class SolidServerInfo {
  final String serverUri;     // Required: Server URI
  final String? displayText;  // Optional: Custom display text
  final String? tooltip;      // Optional: Tooltip message
  final bool isClickable;     // Clickable to open in browser (default: true)
}

class SolidLoginStatus {
  final String? webId;             // Current WebID (null if not logged in)
  final VoidCallback onTap;        // Required: Tap callback
  final String? loggedInText;      // Custom logged in text
  final String? loggedOutText;     // Custom logged out text
  final String? loggedInTooltip;   // Logged in tooltip
  final String? loggedOutTooltip;  // Logged out tooltip
}
```

### Theme Toggle Configuration

```dart
class SolidThemeToggleConfig {
  final bool enabled; // Enable theme toggle (default: true)
  final IconData? lightModeIcon;     // Custom light mode icon
  final IconData? darkModeIcon;      // Custom dark mode icon
  final IconData? systemModeIcon;    // Custom system mode icon
  final VoidCallback? onToggleTheme; // Custom toggle callback
  final ThemeMode? currentThemeMode; // Current theme for external management
  final bool showInAppBarActions;    // Show in app bar actions (default: true)
  final String? tooltip;             // Custom tooltip
  final String label; // Overflow menu label (default: 'Toggle Theme')
  final bool showOnNarrowScreen;     // Show on narrow screens (default: true)
  final bool showOnVeryNarrowScreen; // Show on very narrow screens
                                     // (default: true)
}
```

### About Dialogue Configuration

```dart
class SolidAboutConfig {
  final bool enabled;                // Enable about button (default: true)
  final IconData? icon;              // Custom about icon
  final String? applicationName;     // Application name
                                     // (auto-detected if null)
  final String? applicationVersion;  // Application version
                                     // (auto-detected if null)
  final Widget? applicationIcon;     // Application icon widget
  final String? applicationLegalese; // Legal notice/copyright
  final String? text;                // Main content text (supports Markdown)
  final Widget? customContent;       // Custom dialogue content
  final List<Widget>? children;      // Additional child widgets
  final bool showOnNarrowScreen;     // Show on narrow screens (default: true)
  final bool showOnVeryNarrowScreen; // Show on very narrow screens
                                     // (default: false)
  final int priority;                // App bar action priority (default: 999)
  final String? tooltip;             // Custom tooltip
  final VoidCallback? onPressed;     // Custom press callback
}
```

### Navigation Components

**SolidNavBar**: Navigation rail for wide screens with vertical menu
layout. Provides always-visible navigation with icon and text labels,
suitable for desktop and tablet landscape orientations.

**SolidNavDrawer**: Navigation drawer for narrow screens with
collapsible menu. Slides in from the left side when triggered by the
hamburger menu button, maximising screen space on mobile devices.

**SolidNavUserInfo**: User information display in navigation
drawer. Shows user avatar, name, and optionally the WebID, appearing
at the top of the navigation drawer.

### Responsive Features

- **Automatic Layout Switching**: SolidScaffold monitors screen width
  and automatically switches between navigation rail and drawer modes
- **Threshold Customisation**: Default breakpoint is 800px, but can be
  customised via `narrowScreenThreshold`
- **Preserved State**: Navigation state and selected menu item are
  preserved during layout transitions
- **Touch-Friendly**: Navigation drawer includes swipe gestures and
  appropriate touch targets for mobile use
- **Accessibility**: Both navigation modes support proper focus
  management and screen reader accessibility

```dart
class SolidNavUserInfo {
  final String userName;              // Required: User display name
  final String? webId;                // Optional: User WebID
  final bool showWebId;               // Show WebID in drawer (default: false)
  final Widget? avatar;               // Custom avatar widget
  final IconData? avatarIcon;         // Avatar icon (if no custom widget)
  final double? avatarSize;           // Custom avatar size
  final SolidVersionConfig? versionConfig;  // Optional: Version display config
}
```

### Example Usage

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
            child: HomePage(),
            tooltip: 'Navigate to home screen',
          ),
          SolidMenuItem(
            title: 'Files',
            icon: Icons.folder,
            child: FilesPage(),
            tooltip: 'File management',
          ),
          SolidMenuItem(
            title: 'Settings',
            icon: Icons.settings,
            child: SettingsPage(),
            tooltip: 'Application settings',
          ),
        ],
        appBar: SolidAppBarConfig(
          title: 'My Solid App',
          actions: [
            SolidAppBarAction(
              icon: Icons.refresh,
              onPressed: () => print('Refresh'),
              tooltip: 'Refresh content',
            ),
          ],
        ),
        statusBar: SolidStatusBarConfig(
          serverInfo: SolidServerInfo(
            serverUri: 'https://solidcommunity.net',
          ),
          loginStatus: SolidLoginStatus(
            webId: currentWebId,
            onTap: () => handleLoginLogout(),
          ),
        ),
        themeToggle: SolidThemeToggleConfig(enabled: true),
        aboutConfig: SolidAboutConfig(
          applicationName: 'My Solid App',
          text: 'A demonstration of SolidUI capabilities.',
        ),
      ),
    );
  }
}
```

## SolidFile

Comprehensive file management widget for Solid POD integration with
upload, download, and browser functionality. SolidFile provides a
complete file management solution with responsive layout and automatic
configuration based on file paths.

### Responsive File Management

SolidFile adapts its layout based on screen size to provide optimal
file management experience:

- **Wide screen layout**: File browser and upload area displayed
  side-by-side for efficient workflow
- **Narrow screen layout**: Stacked vertical layout with file browser
  above upload controls
- **Auto-detection**: Automatically detects screen size and applies
  appropriate layout
- **Force override**: Use `forceWideScreen` parameter to override
  automatic detection

### Automatic Configuration

SolidFile can automatically configure upload settings and folder names
based on file paths:

- **Path-based configuration**: Automatically detects data types
  (blood pressure, medication, etc.) from folder names
- **Format detection**: Configures appropriate data formats and
  import/export options
- **Friendly naming**: Generates user-friendly folder names from
  technical paths
- **Manual override**: Disable with `autoConfig: false` for custom
  configurations

### Constructor Parameters of SolidFile

```dart
SolidFile({
  Key? key,

  // Required
  required String basePath,

  // File Browser Configuration
  String? currentPath,
  String? friendlyFolderName,
  bool showBackButton = true,
  String backButtonText = 'Back to Home Folder',
  bool? forceWideScreen,
  double? browserHeight,

  // File Operations Callbacks
  VoidCallback? onBackPressed,
  Function(String fileName, String filePath)? onFileSelected,
  Function(String fileName, String filePath)? onFileDownload,
  Function(String fileName, String filePath)? onFileDelete,
  Function(String path)? onDirectoryChanged,
  VoidCallback? onClosePreview,
  Function(String fileName, String filePath)? onImportCsv,

  // Upload Configuration
  bool showUpload = true,
  SolidFileUploadConfig? uploadConfig,
  SolidFileUploadCallbacks? uploadCallbacks,
  SolidFileUploadState? uploadState,
  bool autoConfig = true,

  // Browser Key for External Control
  GlobalKey<SolidFileBrowserState>? browserKey,
})
```

### Upload Configuration

```dart
class SolidFileUploadConfig {
  final bool showCsvButtons;            // Show CSV import/export buttons
                                        // (default: false)
  final bool showProfileButtons;        // Show Profile import/export buttons
                                        // (default: false)
  final bool showJsonButtons;           // Show JSON operations (default: true)
  final bool showPreviewButtons;        // Show file preview options
                                        // (default: true)
  final DataFormatConfig? formatConfig; // Data format configuration
  final String uploadButtonText;        // Upload button text
                                        // (default: 'Upload File')
  final String? uploadTooltip;          // Upload tooltip message
}

class SolidFileUploadCallbacks {
  final VoidCallback? onUpload;             // File upload callback
  final VoidCallback? onImportCsv;          // CSV import callback
  final VoidCallback? onExportCsv;          // CSV export callback
  final Function(String importType)? onImportSuccess; // Import success callback
  final VoidCallback? onImportProfile;      // Profile import callback
  final VoidCallback? onExportProfile;      // Profile export callback
  final VoidCallback? onVisualiseJson;      // JSON visualisation callback
  final VoidCallback? onSelectLocalJson;    // Local JSON selection callback
  final VoidCallback? onPreviewFile;        // File preview callback
  final VoidCallback? onConvertToJson;      // PDF to JSON conversion callback
}

class SolidFileUploadState {
  final bool isUploading;         // Upload in progress (default: false)
  final double uploadProgress;    // Upload progress 0.0-1.0 (default: 0.0)
  final String? uploadStatus;     // Upload status message
  final bool showPreview;         // Show file preview (default: false)
  final String? previewContent;   // Preview content
}
```

### Data Format Configuration

```dart
class DataFormatConfig {
  final String title;                 // Required: Format title
  final List<String> requiredFields;  // Required: List of required fields
  final List<String> optionalFields;  // Optional fields (default: [])
  final bool isJson;                  // JSON format flag (default: false)
  final String? description;          // Format description
}
```

### Example Usage of SolidFile

```dart
// Basic file management
SolidFile(
  basePath: 'myapp/data',
  currentPath: 'myapp/data/documents',
  onFileSelected: (fileName, filePath) {
    print('File selected: $fileName at $filePath');
  },
  onFileDownload: (fileName, filePath) {
    print('Download requested: $fileName');
  },
)

// With upload configuration
SolidFile(
  basePath: 'healthapp/data',
  currentPath: 'healthapp/data/bloodpressure',
  uploadConfig: SolidFileUploadConfig(
    showCsvButtons: true,
    showJsonButtons: true,
    formatConfig: DataFormatConfig(
      title: 'Blood Pressure Data',
      requiredFields: ['date', 'systolic', 'diastolic'],
      optionalFields: ['heartRate', 'notes'],
    ),
  ),
  uploadCallbacks: SolidFileUploadCallbacks(
    onImportCsv: () {
      // Handle CSV import
    },
    onExportCsv: () {
      // Handle CSV export
    },
    onUpload: () {
      // Handle file upload
    },
  ),
)

// Manual configuration (disable auto-config)
SolidFile(
  basePath: 'myapp/data',
  currentPath: 'myapp/data/custom',
  autoConfig: false,
  uploadConfig: SolidFileUploadConfig(
    showCsvButtons: false,
    showJsonButtons: true,
    uploadButtonText: 'Upload Custom File',
  ),
  friendlyFolderName: 'Custom Data',
)
```

## Login Example

A simple login screen to authenticate a user against a Solid server.
If your own home widget is called `MyHome()` then simply wrap this within
the `SolidLogin()` widget:

```dart
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Pod',
      home: const SolidLogin(
        child: Scaffold(body: MyHome()),
      ),
    );
  }
```

## Change Security Key Example

Wrap the `changeKeyPopup()` function within a button widget. Parameters
include the `BuildContext` and the widget that you need to return to
after changing the key.

```dart
ElevatedButton(
 onPressed: () {
  changeKeyPopup(context, ReturnPage());
 },
 child: const Text('Change Security Key on Pod')
)
```

## Authentication and Login Detection

SolidUI provides dynamic login status detection and management through
integration with the SolidPOD library.

### SolidDynamicLoginStatus

Automatically detects and updates login status based on actual Solid
POD authentication state.

```dart
class SolidDynamicLoginStatus extends StatefulWidget {
  final SolidStatusBarConfig baseConfig; // Required: Base status bar
                                         // configuration
  final VoidCallback? onTap;             // Login/logout tap handler
  final VoidCallback? onLogin; // Custom login handler for logged out state
  final String? loggedInText;            // Custom logged in text
  final String? loggedOutText;           // Custom logged out text
  final String? loggedInTooltip;         // Logged in tooltip
  final String? loggedOutTooltip;        // Logged out tooltip
}
```

### Example Usage of SolidDynamicLoginStatus

```dart
SolidDynamicLoginStatus(
  baseConfig: SolidStatusBarConfig(
    serverInfo: SolidServerInfo(
      serverUri: 'https://solidcommunity.net',
    ),
  ),
  onTap: () {
    // Handle login/logout based on current state
    if (isLoggedIn) {
      performLogout();
    } else {
      showLoginDialog();
    }
  },
  loggedInText: 'Connected',
  loggedOutText: 'Disconnected',
)
```

### Login Status Methods

The following methods are available for checking authentication
status:

- `getWebId()`: Returns the current WebID if logged in, null otherwise
- `checkLoggedIn()`: Verifies the current login status with the POD
  server

## Security Key Management

SolidUI provides comprehensive security key management for encryption
in Solid POD applications.

### SolidSecurityKeyService

Central service for managing security key operations and status.

```dart
class SolidSecurityKeyService extends ChangeNotifier {
  // Check if security key exists
  Future<bool> isKeySaved();
  // Fetch status with callback
  Future<bool> fetchKeySavedStatus([Function(bool)? onKeyStatusChanged]);
  // Force refresh of key status
  Future<void> refreshKeyStatus();
  // Refresh and notify
  Future<bool> refreshAndNotify([Function(bool)? onKeyStatusChanged]);
  // Check if security key is needed
  Future<bool> isSecurityKeyNeeded();
}
```

### SolidSecurityKeyStatus

Status bar component for displaying security key information.

```dart
class SolidSecurityKeyStatus {
  final bool? isKeySaved;                   // Current key status
  final VoidCallback? onTap;                // Tap callback
                                            // (null for automatic management)
  final Function(bool)? onKeyStatusChanged; // Status change callback
  final String? title;                      // Custom dialogue title
  final Widget? appWidget;                  // Custom app widget for dialogues
  final String? tooltip;                    // Custom tooltip message
}
```

### SolidSecurityKeyManager

Advanced component for custom security key management implementations.

```dart
class SolidSecurityKeyManagerConfig {
  final Widget appWidget;         // Required: App widget for change key popup
  final String? title;            // Custom manager title
  final bool showViewKeyButton;   // Show view key button (default: true)
  final bool showForgetKeyButton; // Show forget key button (default: true)
}

class SolidSecurityKeyManager extends StatefulWidget {
  final SolidSecurityKeyManagerConfig config; // Required: Manager configuration
  final Function(bool) onKeyStatusChanged; // Required: Status change callback
}
```

### Example Usage of SolidSecurityKeyStatus and SolidSecurityKeyManager

```dart
// Automatic security key management in status bar
SolidStatusBarConfig(
  securityKeyStatus: SolidSecurityKeyStatus(
    title: 'My App Security Keys',
    onKeyStatusChanged: (bool hasKey) {
      print('Security key status: ${hasKey ? "saved" : "not saved"}');
    },
    tooltip: 'Manage encryption keys',
  ),
)

// Manual security key management
SolidSecurityKeyManager(
  config: SolidSecurityKeyManagerConfig(
    appWidget: MyAppWidget(),
    title: 'Encryption Key Management',
    showViewKeyButton: true,
    showForgetKeyButton: true,
  ),
  onKeyStatusChanged: (hasKey) {
    setState(() {
      _securityKeyExists = hasKey;
    });
  },
)

// Using the security key service
final securityKeyService = SolidSecurityKeyService();

// Check current status
bool hasKey = await securityKeyService.isKeySaved();

// Listen for changes
securityKeyService.addListener(() {
  // Handle security key status changes
});

// Refresh status
await securityKeyService.refreshKeyStatus();
```

## API Reference

### Responsive Design System

SolidUI implements a comprehensive responsive design system that
automatically adapts to different screen sizes:

#### Screen Size Breakpoints

```dart
class NavigationConstants {
  // Navigation rail → drawer transition
  static const double narrowScreenThreshold = 800.0;
  // Very narrow screen threshold
  static const double veryNarrowScreenThreshold = 400.0;
  static const double statusBarHeight = 32.0; // Default status bar height
  static const double navRailWidth = 72.0; // Navigation rail width
  static const double navRailExtendedWidth = 256.0; // Extended navigation
  rail width
}
```

#### Responsive Behaviour Summary

| Screen Width (px) | Navigation | App Bar Actions | Status Bar | File Layout |
|------|------------|-----------------|-----------|-------------|
| ≥800 | SolidNavBar | All actions visible | Full status | Side-by-side |
| 400-799 | SolidNavDrawer | Selected actions + overflow | Compact | Stacked |
| <400 | Navigation Drawer | Essential actions only | Minimal/hidden | Stacked |

#### Automatic Adaptations

- **Navigation**: SolidNavBar automatically becomes SolidNavDrawer
  when screen width < 800px
- **App Bar**: Action buttons move to overflow menu based on
  `showOnNarrowScreen` and `showOnVeryNarrowScreen` settings
- **Status Bar**: Layout and visibility adapt based on
  `showOnNarrowScreens` configuration
- **File Management**: SolidFile switches between wide and narrow
  layouts automatically
- **Theme Controls**: Theme toggle and about buttons adjust their
  placement responsively

### File Operations

SolidUI includes comprehensive file operation utilities:

- `SolidFileOperations`: General file operations for Solid PODs
- `SolidFileUploadOperations`: Specialised upload operations
- `SolidFileDownloadOperations`: Download operation helpers
- `SolidFileDeleteOperations`: Delete operation helpers

### Theme Management

```dart
class SolidThemeNotifier extends ChangeNotifier {
  ThemeMode get themeMode; // Current theme mode
  Future<void> initialize(); // Initialise theme notifier
  Future<void> setThemeMode(ThemeMode mode); // Set theme mode
  void toggleTheme(); // Toggle between light/dark modes
}

class SolidThemeApp extends StatefulWidget {
  // MaterialApp wrapper with integrated theme management
}
```

## Examples

### Complete Application Example

```dart
import 'package:flutter/material.dart';
import 'package:solidui/solidui.dart';

class CompleteExampleApp extends StatefulWidget {
  @override
  _CompleteExampleAppState createState() => _CompleteExampleAppState();
}

class _CompleteExampleAppState extends State<CompleteExampleApp> {
  String? _webId;
  bool _isKeySaved = false;

  @override
  Widget build(BuildContext context) {
    return SolidThemeApp(
      title: 'Complete SolidUI Example',
      home: SolidScaffold(
        menu: [
          SolidMenuItem(
            title: 'Dashboard',
            icon: Icons.dashboard,
            child: DashboardPage(),
            tooltip: 'Application dashboard',
          ),
          SolidMenuItem(
            title: 'Files',
            icon: Icons.folder,
            child: SolidFile(
              basePath: 'myapp/data',
              currentPath: 'myapp/data',
              onFileSelected: (fileName, filePath) {
                print('File selected: $fileName');
              },
            ),
            tooltip: 'File management',
          ),
          SolidMenuItem(
            title: 'Settings',
            icon: Icons.settings,
            child: SettingsPage(),
            tooltip: 'Application settings',
          ),
        ],
        appBar: SolidAppBarConfig(
          title: 'My Solid Application',
          actions: [
            SolidAppBarAction(
              icon: Icons.refresh,
              onPressed: _handleRefresh,
              tooltip: 'Refresh data',
            ),
            SolidAppBarAction(
              icon: Icons.notifications,
              onPressed: _showNotifications,
              tooltip: 'View notifications',
              showOnVeryNarrowScreen: false,
            ),
          ],
          versionConfig: SolidVersionConfig(
            changelogUrl: 'https://github.com/myorg/myapp/'
                          'blob/main/CHANGELOG.md',
            showDate: true,
          ),
        ),
        statusBar: SolidStatusBarConfig(
          serverInfo: SolidServerInfo(
            serverUri: 'https://solidcommunity.net',
            tooltip: 'Connected to Solid Community server',
          ),
          loginStatus: SolidLoginStatus(
            webId: _webId,
            onTap: _handleLoginLogout,
            loggedInText: 'Authenticated',
            loggedOutText: 'Not Connected',
          ),
          securityKeyStatus: SolidSecurityKeyStatus(
            isKeySaved: _isKeySaved,
            title: 'Application Security Keys',
            onKeyStatusChanged: (hasKey) {
              setState(() {
                _isKeySaved = hasKey;
              });
            },
          ),
        ),
        userInfo: SolidNavUserInfo(
          userName: _webId != null ? 'User' : 'Not logged in',
          webId: _webId,
          showWebId: true,
        ),
        themeToggle: SolidThemeToggleConfig(
          enabled: true,
          tooltip: 'Switch between light and dark themes',
        ),
        aboutConfig: SolidAboutConfig(
          applicationName: 'My Solid Application',
          applicationIcon: Icon(Icons.apps, size: 64),
          applicationLegalese: '© 2025 My Organisation',
          text: '''
          A comprehensive Solid application built with SolidUI.

          This application demonstrates the complete capabilities of the
          SolidUI library, including responsive navigation, file management,
          and security features.
          ''',
        ),
        onLogout: _webId != null ? (context) => _handleLogout() : null,
      ),
    );
  }

  void _handleRefresh() {
    // Implement refresh logic
  }

  void _showNotifications() {
    // Implement notifications display
  }

  void _handleLoginLogout() {
    // Implement login/logout logic
  }

  void _handleLogout() {
    setState(() {
      _webId = null;
    });
  }
}
```

## Licence

Copyright (C) 2025, Software Innovation Institute, ANU.

Licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Authors

- Graham Williams
- Tony Chen

For more information about Solid and PODs, visit
[solidproject.org](https://solidproject.org).

## Additional information

The source code can be accessed via the [GitHub
repository](https://github.com/anusii/solidui).  You can also file
issues at [GitHub Issues](https://github.com/anusii/solidui/issues).
The authors of the package will respond to issues as best we can but.

<!-- markdownlint-disable MD036 -->
*Time-stamp: <Monday 2025-11-17 10:30:22 +1100 Graham Williams>*
<!-- markdownlint-enable MD036 -->

<!-- markdownlint-disable MD053 -->
[comment]: # (Local Variables:)
[comment]: # (time-stamp-line-limit: -8)
[comment]: # (End:)
<!-- markdownlint-enable MD053 -->
