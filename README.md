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

A comprehensive UI library for building
[Solid](https://solidproject.org) based applications with
[Flutter](https://flutter.dev). [SolidUI](https://pub.dev/packages/solidui)
provides a convenient
[Scaffold](https://api.flutter.dev/flutter/material/Scaffold-class.html)
replacement called
[SolidScaffold](https://pub.dev/documentation/solidui/latest/solidui/SolidScaffold-class.html)
to wrap the app. It also provides responsive navigation components,
file management capabilities, security key handling, and
authentication features specifically designed for Solid applications
interacting with a user's personal online data store (Pods).

See the [AU Solid Community](https://solidcommunity.au) page for apps
utilising the solidui package.

## Table of Contents

- [Installation](#installation)
- [Features](#features)
- [Requirements](#requirements)
- [Quick Start to Create an App](#quick-start-to-create-an-app)
- [SolidScaffold](#solidscaffold)
- [Appearance Preferences](#appearance-preferences)
- [SolidFile](#solidfile)
- [Login Example](#login-example)
- [Change Security Key Example](#change-security-key-example)
- [Grant Permission UI Example](#grant-permission-ui-example)
- [View Permission UI Example](#view-permission-ui-example)
- [Authentication and Login Detection](#authentication-and-login-detection)
- [Security Key Management](#security-key-management)
- [Profile Management](#profile-management)
- [Theme Management](#theme-management)
- [API Reference](#api-reference)
- [Examples](#examples)
- [Licence](#licence)
- [Authors](#authors)
- [Additional information](#additional-information)

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

- `SolidFile` widget provides a complete file management solution for
  browsing, uploading, downloading, and deleting files in a POD.
  Underlying POD reads and writes are handled by
  [`solidpod`](https://pub.dev/packages/solidpod)'s `readPod()` and
  `writePod()` functions, which are also available directly if you need
  lower-level access.

- `GrantPermissionUi` widget supports
  permission granting/revoking for resources:
  - For defining specific access mode types or recipient types, use
    optional parameters `accessModeList` and `recipientTypeList`.

Granting permission:
<div align="center">
 <img
 src="https://raw.githubusercontent.com/anusii/solidui/main/assets/screenshots/grant_permission.png"
 alt="Grant Permission" width="400">
</div>

Revoking permission:
<div align="center">
 <img
 src="https://raw.githubusercontent.com/anusii/solidui/main/assets/screenshots/revoke_permission.png"
 alt="Revoke Permission" width="400">
</div>

- SharedResourcesUi widget displays
  resources shared with a Pod by others:

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
- `flutter_markdown_plus`: Markdown rendering support
- `flutter_form_builder`: Form building and validation
- `form_builder_validators`: Form field validators
- `file_picker`: File selection functionality
- `shared_preferences`: Local storage for settings
- `package_info_plus`: Application metadata access
- `url_launcher`: URL launching capabilities
- `markdown_tooltip`: Markdown-enabled tooltips
- `rdflib`: RDF data handling
- `gap`: Spacing utilities
- `path`: Path manipulation
- `version_widget`: Version display widget
- `pdf`: PDF generation support
- `printing`: Print and PDF preview functionality
- `share_plus`: Cross-platform file and content sharing
- `loading_indicator`: Animated loading indicators
- `universal_io`: Cross-platform IO utilities

## Quick Start to Create an App

To create a new Solid-based app using `solidui` named `myapp` and
published by `example.com` begin with:

```bash
flutter create --template solidui --domain com.example myapp
```

A demonstrator example application (DemoPod) is available in the
[example](example/) folder of this repository. DemoPod showcases the
suite of functionality provided by `solidpod` and `solidui`,
including reading and writing encrypted data, ACL inheritance,
permission management, large file transfers, and more.

A standalone file browser application is available in the
[FilePod](https://github.com/anusii/filepod) repository. FilePod
demonstrates building a complete Solid app using `SolidScaffold`,
`SolidFile`, and the broader `solidui` framework.

Both applications consist of several files within their `lib/`
directory.  `main.dart` is the main entry point to the app. Its task
in our framework is to initialise the application and then launch the
app itself. `home.dart` implements the `Home()` widget as the main
app functionality. Constants are defined in `constants/app.dart` and
utilities such as desktop platform detection are in
`utils/is_desktop.dart`.

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
- **Narrow screens (<800px)**: By default, main menu items appear in a
  bottom navigation bar (`SolidNavBottomBar`). Login and security key
  actions stay in the collapsible navigation drawer `SolidNavDrawer()`
  (hamburger menu). Set `menuInBottomBar: false` on `SolidScaffold` to
  keep all menu items in the drawer instead, or let users choose via
  **About → Menu**;
- **Custom threshold**: The breakpoint can be customised using the
  `narrowScreenThreshold` parameter with a value of 0 turning off the
  hamburger menu and a large value effectively turning off the
  vertical navigation rail.

A responsive behaviour ensures that your application provides an
optimal navigation experience whether users are on desktop computers,
tablets, or mobile devices, running the app natively or through a
browser. The transition between navigation modes is seamless and
automatic.

### Subpage Navigation

SolidScaffold supports navigation to subpages that are not in the main
navigation menu. This is useful for applications that need to display
detail pages (e.g. individual notes in NotePod) whilst maintaining the
SolidScaffold frame.

**Recommended approach using SolidScaffoldController** (no StatefulWidget
needed):

```dart
final controller = SolidScaffoldController();

final appScaffold = SolidScaffold(
  controller: controller,
  menu: [...],
  appBar: SolidAppBarConfig(
    actions: [
      SolidAppBarAction(
        icon: Icons.settings,
        onPressed: () => controller.navigateToSubpage(SettingsPage()),
      ),
    ],
  ),
);
```

**Alternative approach using bodyOverride** (requires setState):

```dart
class _MyAppState extends State<MyApp> {
  Widget? _subpage;

  @override
  Widget build(BuildContext context) {
    return SolidScaffold(
      menu: [...],
      bodyOverride: _subpage,
      onClearBodyOverride: () => setState(() => _subpage = null),
    );
  }
}
```

### Constructor Parameters

```dart
SolidScaffold({
  Key? key,

  // Navigation
  List<SolidMenuItem>? menu,
  Widget? child,
  Widget? bodyOverride,
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

### Appearance Preferences

SolidUI stores user appearance preferences via `SolidPreferencesNotifier`
and `SolidPreferencesConfig`. These preferences persist across sessions
using `shared_preferences`. The `SolidPreferencesDialog` provides a UI
for configuring AppBar layout.

#### AppBar Layout Preferences

AppBar action buttons can be customised via the AppBar Layout Preferences
dialogue (typically opened from the AppBar Layout Preferences button in the
About Dialogue):

- **Button order**: Drag to reorder buttons. Order is saved and used
  across screen sizes.
- **Visibility**: Use the eye icon to show or hide individual buttons.
  Hidden buttons are not shown in the AppBar or overflow menu.
- **Overflow behaviour**: Use the menu icon to choose whether a button
  appears in the AppBar or only in the overflow menu on narrow screens.
  Buttons in the overflow menu are accessible via the "more" (⋮) icon.

Preferences are stored per application and persist across restarts.

#### Theme Mode Configuration

`SolidThemeModeConfig` controls which theme modes appear in the theme
toggle cycle and how switching behaves:

| Option | Default | Description |
| -------- | --------- | ------------- |
| `lightModeEnabled` | `true` | Include Light mode in the toggle cycle. When enabled, users can switch to a light theme optimised for bright viewing conditions. |
| `darkModeEnabled` | `true` | Include Dark mode in the toggle cycle. When enabled, users can switch to a dark theme for low-light viewing. |
| `systemModeEnabled` | `true` | Include System mode in the toggle cycle. When enabled, the app follows the device's light/dark setting. |
| `smartToggle` | `true` | When all three modes are enabled: in System mode, tapping the theme toggle switches to the opposite of the current system brightness (e.g. light → dark), then toggles between Light and Dark. When `false`, the toggle cycles mechanically: System → Light → Dark → System. |

At least one of `lightModeEnabled`, `darkModeEnabled`, or
`systemModeEnabled` must be `true`.

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

`SolidLogin` is the full-page login widget. Wrap your home widget in it
and it handles session restore, OIDC login, and POD initialisation
automatically.

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'My Pod',
    home: SolidLogin(
      clientId: 'https://your-domain/client-profile.jsonld',
      redirectUris: [
        'https://your-domain/redirect.html', // web
        'com.example.app://redirect',        // Android / iOS
        'http://localhost:4400/redirect',    // Windows / Linux / macOS
      ],
      postLogoutRedirectUris: [             // optional, defaults to redirectUris selection
        'https://your-domain/redirect.html',
        'com.example.app://redirect',
        'http://localhost:4400/redirect',
      ],
      child: const Scaffold(body: MyHome()),
    ),
  );
}
```

`redirectUris` and `postLogoutRedirectUris` take a list of URIs, one per
platform. At runtime `SolidLogin` picks the entry that matches the current
platform. See the
[solidpod authentication docs](https://pub.dev/packages/solidpod) for the
per-platform URI format and the fixed-port requirement for desktop.

### SolidLogin Constructor Parameters

```dart
SolidLogin({
  // Required
  required Widget child,                    // Widget shown after successful login
  required String clientId,                 // URL of the app's client ID document
  List<String> redirectUris = const [],     // OAuth redirect URIs (one per platform)

  // Authentication
  List<String> postLogoutRedirectUris = const [], // Redirect URIs after logout (optional)
  bool autoLogin = false,           // Silently restore saved session on startup
  bool required = false,            // false adds a CONTINUE button (no-auth path)

  // Appearance
  AssetImage image,                 // Left-panel / background image
  AssetImage logo,                  // Logo shown in the login panel
  String title = 'Log in to your Solid Pod', // Header text
  String webID,                     // Pre-filled server/WebID field value
  String link = 'https://solidproject.org', // URL opened by the info button

  // Button styles
  LoginButtonStyle loginButtonStyle,
  RegisterButtonStyle registerButtonStyle,
  ContinueButtonStyle continueButtonStyle,
  InfoButtonStyle infoButtonStyle,
  ChangeKeyButtonStyle changeKeyButtonStyle,

  // Theme & notifications
  SolidLoginTheme themeConfig,      // Light/dark colour scheme for the panel
  SnackbarConfig snackbarConfig,    // Snackbar style for login notifications

  // POD setup
  String appDirectory = '',         // App-specific subdirectory name in the POD
  List customFolderPathList = [],   // Extra folders to create under data/
})
```

**`autoLogin`** - when `true`, `SolidLogin` silently calls
`tryRestoreSession()` on startup and navigates directly to `child` if a
valid persisted session is found. Falls back to the login page if no
session exists or the user has opted out of "Stay signed in".

### SolidPopupLogin

`SolidPopupLogin` triggers the OIDC login flow inline within an already-
running app. Useful when a user action requires authentication but the
app wasn't launched from a `SolidLogin` screen.

```dart
// Navigate to the popup login when unauthenticated access is attempted.
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SolidPopupLogin(
      webId: 'https://pods.solidcommunity.au', // optional, pre-fills the field
    ),
  ),
);
```

```dart
SolidPopupLogin({
  String webId,  // Pre-filled WebID/server URI (optional)
})
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

## Grant Permission UI Example

The `GrantPermissionUi` widget provides a full-featured page for
granting, editing, and revoking access permissions on resources stored
in a Solid POD. Wrap it inside a navigation action to reach the
permission management page.  The titleData parameter, if provides,
adds support for switch between file url, filename and file title.

### Basic usage to grant/revoke/change permissions for any resource

This allows the user to select the resource, before inspecting their permissions
and granting, revoking or editing permissions.

```dart
ElevatedButton(
  child: const Text('Add/Delete Permissions'),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const GrantPermissionUi(
        child: ReturnPage(),
      ),
    ),
  ),
)
```

### Grant/revoke/change permissions for a specific file

```dart
ElevatedButton(
  child: const Text('Add/Delete Permissions to a Specific File'),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const GrantPermissionUi(
        resourceNames: ['my-data-file.ttl'],
        child: ReturnPage(),
      ),
    ),
  ),
)
```

### Grant/revoke/change permissions for a specific directory

```dart
ElevatedButton(
  child: const Text('Add/Delete Permissions to a Specific Directory'),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const GrantPermissionUi(
        resourceNames: ['parentDir/'],
        child: ReturnPage(),
        isFile: false,
      ),
    ),
  ),
)
```

### Grant/revoke/change permissions for an externally owned resource

When the user has *control* access to a resource owned by someone else:

```dart
ElevatedButton(
  child: const Text('Add/Delete Permissions to an External File'),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GrantPermissionUi(
        resourceNames: const ['my-data-file.ttl'],
        isExternalRes: true,
        ownerWebId: ownerWebId,
        granterWebId: granterWebId,
        child: ReturnPage(),
      ),
    ),
  ),
)
```

### Grant permissions for multiple user owned resources

When the user wants to apply the same grant permission operation on
a list of resources:

```dart
ElevatedButton(
  child: const Text('Add/Delete Permissions for Multiple Files'),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GrantPermissionUi(
        resourceNames: const ['my-data-file1.ttl', 'my-data-file2.ttl', 'my-data-file3.ttl'],
        ownerWebId: ownerWebId,
        granterWebId: granterWebId,
        child: ReturnPage(),
      ),
    ),
  ),
)
```

## View Permission UI Example

The `SharedResourcesUi` widget displays the resources that have been
shared with the current user's POD by others.

### View all shared resources

```dart
ElevatedButton(
  child: const Text('View Resources your WebID have access to'),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SharedResourcesUi(
        child: ReturnPage(),
      ),
    ),
  ),
)
```

### View a specific shared resource

```dart
ElevatedButton(
  child: const Text('View access to specific Resource'),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SharedResourcesUi(
        fileName: 'my-data-file.ttl',
        sourceWebId:
            'https://pods.solidcommunity.au/john-doe/profile/card#me',
        child: ReturnPage(),
      ),
    ),
  ),
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
    if (getWebId() != null) {
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

## Profile Management

SolidUI provides widgets for displaying and editing a user's Solid profile
(avatar and display name), backed by `SolidProfileNotifier` and
`SolidProfileService`.

### SolidProfileAvatar

Displays a circular avatar sourced from the user's POD profile. Listens
to `solidProfileNotifier` and rebuilds automatically when the avatar
changes.

```dart
// Simple display avatar (40 px default)
const SolidProfileAvatar()

// Larger tappable avatar with edit badge (e.g. on a profile page)
SolidProfileAvatar(
  size: 80,
  showEditBadge: true,
  onTap: () => SolidProfileEditor.show(context),
)
```

```dart
SolidProfileAvatar({
  double size = 40,              // Diameter of the avatar circle
  VoidCallback? onTap,           // Tap callback (e.g. to open editor)
  bool showEditBadge = false,    // Overlay a camera/edit badge icon
  IconData placeholderIcon = Icons.person, // Icon shown when no image
})
```

### SolidProfileEditor

A full-page editor for the user's avatar and display name. Opens as a
modal page and saves changes back to the POD.

```dart
// Navigate to the profile editor page
SolidProfileEditor.show(context);

// Or embed it directly in a route
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const SolidProfileEditor()),
);
```

### SolidProfileService & SolidProfileNotifier

`SolidProfileService` handles loading and saving avatar/display-name
data from the POD. `solidProfileNotifier` (a global `ChangeNotifier`) is
updated whenever the profile changes and is listened to by
`SolidProfileAvatar` and `SolidNavUserInfo`.

```dart
// Load the current user's profile from their POD
await SolidProfileService.loadProfile();

// Listen for profile changes
solidProfileNotifier.addListener(() {
  final bytes = solidProfileNotifier.avatarBytes;
  final name  = solidProfileNotifier.displayName;
});
```

## Theme Management

`SolidThemeApp` is a `MaterialApp` wrapper that integrates SolidUI's
theme persistence. Use it instead of plain `MaterialApp` to get automatic
light/dark/system mode switching that persists across restarts.

```dart
void main() {
  runApp(
    SolidThemeApp(
      title: 'My Solid App',
      home: SolidLogin(
        clientId: 'https://your-domain/client-profile.jsonld',
        redirectUris: [
          'https://your-domain/redirect.html', // web
          'com.example.app://redirect',        // Android / iOS
          'http://localhost:4400/redirect',    // Windows / Linux / macOS
        ],
        child: const MyHome(),
      ),
    ),
  );
}
```

```dart
class SolidThemeNotifier extends ChangeNotifier {
  ThemeMode get themeMode;                   // Current theme mode
  Future<void> initialize();                 // Load persisted preference
  Future<void> setThemeMode(ThemeMode mode); // Persist and apply a mode
  void toggleTheme();                        // Cycle to the next mode
}
```

The global `solidThemeNotifier` instance is pre-created by solidui — add
a listener or call `solidThemeNotifier.setThemeMode(ThemeMode.dark)` from
anywhere in your app. `SolidThemeToggleConfig` (in `SolidScaffold`)
controls which modes appear in the toggle cycle — see
[Appearance Preferences](#appearance-preferences) for details.

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
  static const double navRailExtendedWidth = 256.0; // Extended navigation rail width
}
```

#### Responsive Behaviour Summary

| Screen Width (px) | Navigation | App Bar Actions | Status Bar | File Layout |
| ------ | ------------ | ----------------- | ----------- | ------------- |
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

Copyright (C) 2025–2026, Software Innovation Institute, ANU.

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
The authors of the package will respond to issues as best we can.

<!-- markdownlint-disable MD036 -->
*Time-stamp: <Monday 2026-01-19 16:52:46 +1100 Graham Williams>*
<!-- markdownlint-enable MD036 -->

<!-- markdownlint-disable MD053 -->
[comment]: # (Local Variables:)
[comment]: # (time-stamp-line-limit: -8)
[comment]: # (End:)
<!-- markdownlint-enable MD053 -->
