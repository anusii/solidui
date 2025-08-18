# SolidUI Simple Example

A minimal example demonstrating how to use SolidScaffold from the SolidUI 
library.

## What This Example Shows

This simple application demonstrates:

- **Basic SolidScaffold setup** with 3 menu items
- **Responsive navigation** that switches between rail and drawer
- **AppBar integration** with action buttons and overflow menu
- **Status bar functionality** with POD server connection simulation

## Running the Example

### Prerequisites
- Flutter SDK (3.10.0 or later)
- Dart SDK (3.0.0 or later)

### Steps
1. Navigate to the examples directory:
   ```bash
   cd solidui/examples
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
   flutter run
   ```

## Code Structure

### Key Implementation

The main implementation shows how simple it is to use SolidScaffold:

```dart
SolidScaffold(
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
