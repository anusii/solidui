# SolidUI Simple Example

A minimal example demonstrating how to use SolidNavigator from the SolidUI library.

## What This Example Shows

This simple application demonstrates:

- **Basic SolidNavigator setup** with 3 menu items
- **Responsive navigation** that switches between rail and drawer
- **AppBar integration** with action buttons and overflow menu
- **Status bar functionality** with POD server connection simulation
- **User management** with login/logout simulation

## Features

### 🧭 Navigation
- Home, About, and Settings pages
- Automatic responsive layout switching
- Clean, simple menu structure

### 📱 User Interface
- Material Design 3 theming
- Light and dark mode support
- Simple text-based content pages
- Responsive design

### 🔗 POD Integration
- Simulated POD server connection
- Login/logout functionality
- Status bar with connection information
- Security key management placeholder

## Running the Example

### Prerequisites
- Flutter SDK (3.10.0 or later)
- Dart SDK (3.0.0 or later)

### Steps
1. Navigate to the examples directory:
   ```bash
   cd solidui/examples
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Code Structure

### Key Implementation

The main implementation shows how simple it is to use SolidNavigator:

```dart
SolidNavigator(
  menu: [
    SolidMenuItem(title: 'Home', icon: Icons.home),
    SolidMenuItem(title: 'About', icon: Icons.info),
    SolidMenuItem(title: 'Settings', icon: Icons.settings),
  ],
  appBar: SolidAppBarConfig(
    title: 'Current Page Title',
    actions: [/* action buttons */],
  ),
  statusBar: SolidStatusBarConfig(
    serverInfo: SolidServerInfo(/* server info */),
    loginStatus: SolidLoginStatus(/* login status */),
  ),
  child: YourContent(),
)
```

### Menu Items
- **Home**: Welcome page with quick start guide
- **About**: Information about the application
- **Settings**: Configuration options placeholder

### Responsive Behavior
- **Wide screens (≥800px)**: Shows navigation rail on the left
- **Narrow screens (<800px)**: Shows hamburger menu with drawer

## Customisation

### Adding Menu Items
```dart
const SolidMenuItem(
  title: 'New Page',
  icon: Icons.new_icon,
  tooltip: 'Description of new page',
)
```

### Custom AppBar Actions
```dart
SolidAppBarAction(
  icon: Icons.custom_action,
  onPressed: () => doSomething(),
  tooltip: 'Custom action description',
)
```

### Status Bar Configuration
```dart
SolidStatusBarConfig(
  serverInfo: SolidServerInfo(
    serverUri: 'https://your-pod-server.com',
    displayText: 'Your POD Server',
  ),
  loginStatus: SolidLoginStatus(
    webId: userWebId,
    onTap: handleLogin,
  ),
)
```

## Learning Points

This example teaches:

1. **Minimal Setup**: How to get SolidNavigator running with just a few lines
2. **Menu Configuration**: How to define navigation menu items
3. **Content Management**: How to handle different page content
4. **State Management**: How to manage selected menu item state
5. **POD Integration**: How to simulate POD server connections

## Next Steps

After understanding this example:

1. **Explore Features**: Try resizing the window to see responsive behavior
2. **Modify Content**: Change the menu items or page content
3. **Add Functionality**: Implement real POD server integration
4. **Customise Styling**: Adjust themes and colours to match your design

This example provides the foundation for building more complex applications with SolidUI!
