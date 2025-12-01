# My App - SolidUI Template Application

A template application demonstrating the recommended structure for SolidUI
applications.

## Application Structure

This template follows the standard SolidUI application structure:

```
lib/
├── main.dart              # Main entry point for the application
├── app.dart               # App() widget with SolidThemeApp and SolidLogin
├── app_scaffold.dart      # AppScaffold() configuration with menu, appBar, statusBar, etc.
├── home.dart              # Home() page widget
├── constants/
│   └── app.dart          # Application-wide constants (e.g., appTitle)
└── utils/
    └── is_desktop.dart   # Utility to check if running on desktop platform
```

## Key Components

### main.dart
- Application entry point
- Initialises Flutter bindings
- Configures window manager for desktop platforms
- Launches the App() widget

### app.dart
- Implements the root App widget
- Configures SolidThemeApp with theme settings
- Sets up SolidLogin wrapper around the app scaffold

### app_scaffold.dart
- Defines the SolidScaffold configuration
- Configures menu items with navigation
- Sets up app bar with actions and version info
- Configures status bar with server info and security key management
- Defines About dialog content
- Enables theme toggle functionality

### home.dart
- Implements the Home page widget
- Displays welcome content and feature overview

## Configuration

- **Domain**: com.example
- **App Name**: myapp
- **Bundle Identifier**: com.example.myapp (macOS)

## What This Template Demonstrates

This application demonstrates:

- **Modular application structure** following best practices
- **SolidScaffold setup** with comprehensive configuration
- **Responsive navigation** that switches between rail and drawer
- **Theme switching** with light/dark/system modes
- **Custom About dialogue** with rich application information
- **Version management** with changelog integration
- **AppBar integration** with action buttons and overflow menu
- **Status bar functionality** with POD server connection
- **Security key management** integration
- **File browser** for Solid POD file management

### Additional Examples

This package also includes:

- **subpage_navigation_example.dart**: Demonstrates the `bodyOverride` feature for
  navigating to detail pages (subpages) that are not in the main navigation menu.
  This is useful for applications like NotePod where you need to navigate from a
  list view to individual items whilst maintaining the SolidScaffold frame.

## Running the Application

### Prerequisites

- Flutter SDK (3.10.0 or later)
- Dart SDK (3.0.0 or later)

### Steps

1. Navigate to the example directory:

    ```bash
    cd solidui/example
    ```

2. Create a new Flutter project:

    ```bash
    flutter create .
    ```

3. Install dependencies:

    ```bash
    flutter pub get
    ```

4. Run the application:

    ```bash
    flutter run -d macos  # For macOS
    flutter run -d linux  # For Linux
    flutter run -d windows  # For Windows
    ```

## Customising for Your Application

To use this template as a starting point for your own application:

1. **Update application name and domain**:
   - Modify `pubspec.yaml` (name, description)
   - Update `macos/Runner/Configs/AppInfo.xcconfig` (PRODUCT_NAME, 
     PRODUCT_BUNDLE_IDENTIFIER)
   - Update `macos/Runner/Info.plist` (CFBundleURLName, CFBundleURLSchemes)

2. **Update constants**:
   - Edit `lib/constants/app.dart` to change the app title

3. **Customize the home page**:
   - Modify `lib/home.dart` to display your content

4. **Configure the scaffold**:
   - Edit `lib/app_scaffold.dart` to add/remove menu items
   - Update app bar actions, status bar configuration, and About dialog

5. **Update theme and branding**:
   - Edit `lib/app.dart` to change color scheme and theme
   - Replace `assets/images/app_icon.png` and `assets/images/app_image.jpg`

## License

Licensed under the MIT License. See LICENSE file for details.

Copyright © 2025 Software Innovation Institute, ANU
