# GoogleBottomBar Component

A beautiful and customizable bottom navigation bar for Flutter applications, built using the Salomon Bottom Bar package with Google-style design.

## Features

- ✨ Material Design 3 styling
- 🎨 Customizable colors and appearance
- 📱 Responsive design with smooth animations
- 🔧 Easy to integrate and configure
- 🎯 5 pre-configured navigation items
- 🎗️ Integrated with custom AppHeader component

## Components

### GoogleBottomBar
The main bottom navigation component with 5 navigation items:

1. **Dashboard** - Main overview screen
2. **Featured** - Featured partners and restaurants
3. **Calendar** - Work calendar and scheduling
4. **Location** - Location tracking features
5. **Profile** - User profile and settings

### AppHeader
A comprehensive header component featuring:

- **Left Side**: User profile with avatar and name
- **Right Side**: Notifications, search, and menu actions
- **Customizable**: Badge counts, colors, and actions
- **Interactive**: Profile tap navigation and action callbacks

### SimpleAppHeader
A simplified header variant for specific screens:

- **Clean Design**: Just title and optional back button
- **Minimal Actions**: Custom action buttons support
- **Consistent Styling**: Matches the main header design

## Installation

Make sure you have the required dependency in your `pubspec.yaml`:

```yaml
dependencies:
  salomon_bottom_bar: ^3.3.2
```

## Usage

### Basic GoogleBottomBar Implementation

```dart
import 'package:flutter/material.dart';
import 'core/widgets/google_bottom_bar.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YourPageContent(), // Your page content here
      bottomNavigationBar: GoogleBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
```

### AppHeader with User Profile

```dart
import 'package:flutter/material.dart';
import 'core/widgets/app_header.dart';

Scaffold(
  appBar: AppHeader(
    user: currentUser,
    title: 'Dashboard',
    showNotificationBadge: true,
    notificationCount: 3,
    onProfileTap: () {
      // Navigate to profile screen
      Navigator.pushNamed(context, '/profile');
    },
    actions: [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () => _openSettings(),
      ),
    ],
  ),
  body: YourContent(),
)
```

### SimpleAppHeader for Sub-screens

```dart
Scaffold(
  appBar: SimpleAppHeader(
    title: 'Settings',
    showBackButton: true,
    actions: [
      IconButton(
        icon: const Icon(Icons.save),
        onPressed: () => _saveSettings(),
      ),
    ],
  ),
  body: SettingsContent(),
)
```

### Custom Styling

```dart
GoogleBottomBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  backgroundColor: Colors.white,
  selectedItemColor: Colors.blue,
  unselectedItemColor: Colors.grey,
  margin: EdgeInsets.all(20),
)
```

## Customization Options

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `currentIndex` | `int` | Currently selected tab index | Required |
| `onTap` | `ValueChanged<int>` | Callback when tab is tapped | Required |
| `backgroundColor` | `Color?` | Background color of the bar | `theme.colorScheme.surface` |
| `selectedItemColor` | `Color?` | Color of selected item | `theme.colorScheme.primary` |
| `unselectedItemColor` | `Color?` | Color of unselected items | `theme.colorScheme.onSurfaceVariant` |
| `margin` | `EdgeInsets?` | Margin around the bar | `EdgeInsets.all(16)` |

## Demo

Run the demo to see the GoogleBottomBar in action:

```bash
flutter run -t lib/demo_main.dart
```

## Integration with Features

The GoogleBottomBar is designed to work seamlessly with the app's feature-based architecture:

- **Dashboard**: Overview and main navigation
- **Calendar**: Integration with `work_calendar` feature
- **Location**: Integration with `location_tracking` feature  
- **Images**: Integration with `image_upload` feature
- **Profile**: User authentication and settings

## Architecture Compliance

This component follows the project's architecture guidelines:

- ✅ Feature-First organization
- ✅ Clean Architecture principles
- ✅ Proper separation of concerns
- ✅ Material Design 3 compliance
- ✅ Responsive design patterns

## Files Structure

```
lib/core/widgets/
├── google_bottom_bar.dart          # Main component
├── google_bottom_bar_demo.dart     # Demo implementation
├── main_screen.dart                # Example with multiple pages
└── widgets.dart                    # Export file
```

## Dependencies

- `flutter/material.dart` - Material Design components
- `salomon_bottom_bar` - Beautiful bottom navigation bar package

---

**Note**: This component is part of the Flutter Architecture App and follows the established coding standards and architectural patterns.
