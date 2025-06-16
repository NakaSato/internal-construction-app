# UI Guidelines

This section documents the UI design principles, components, and usage patterns in the Flutter Architecture App.

## Material Design 3

The app implements Material Design 3 (Material You) for a modern, consistent interface.

### Key Components

- Dynamic color system using `Theme.of(context).colorScheme`
- Updated components (Cards, Buttons, Text Fields)
- Consistent elevation and surface styling

## Theming

### Color Scheme

The app uses a consistent color scheme defined in:

```dart
// lib/core/theme/app_theme.dart
final lightColorScheme = ColorScheme(
  primary: Color(0xFF006C51),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF8BF8C7),
  // ...more colors
);

final darkColorScheme = ColorScheme(
  primary: Color(0xFF6EDBA9),
  onPrimary: Color(0xFF00382A),
  primaryContainer: Color(0xFF00513D),
  // ...more colors
);
```

### Typography

Text styles follow Material Design 3 guidelines:

```dart
// Example usage
Text(
  'Heading',
  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    fontWeight: FontWeight.bold,
  ),
)
```

## Component Library

### Cards

```dart
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: // Card content
  ),
)
```

### Buttons

```dart
// Elevated Button
ElevatedButton(
  onPressed: () {},
  child: Text('Primary Action'),
)

// Outlined Button
OutlinedButton(
  onPressed: () {},
  child: Text('Secondary Action'),
)

// Text Button
TextButton(
  onPressed: () {},
  child: Text('Tertiary Action'),
)
```

## Responsive Design

The app implements responsive design using:

1. **LayoutBuilder** for component-level responsiveness
2. **MediaQuery** for screen-level adaptations
3. **Flexible/Expanded** for proportional layouts

Example:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 768) {
      return _buildDesktopLayout();
    } else {
      return _buildMobileLayout();
    }
  },
)
```

## Animation Guidelines

- Use implicit animations (AnimatedContainer, AnimatedOpacity) for simple transitions
- Use explicit animations with AnimationController for complex scenarios
- Follow Material motion guidelines for duration and curves
