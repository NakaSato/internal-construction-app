# Setup Documentation

This section provides instructions for setting up the development environment for the Flutter Architecture App.

## Prerequisites

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Android Studio / VS Code with Flutter plugins
- Git

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd flutter-dev
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

## Project Configuration

### Environment Configuration

The app supports different environments (development, staging, production). Configuration files are located in:

```
lib/core/config/
```

### API Configuration

API endpoints and configuration are managed through:

```
lib/core/api/
```

## IDE Setup

### VS Code

Recommended extensions:
- Dart
- Flutter
- Flutter Widget Snippets
- bloc

### Android Studio

Recommended plugins:
- Dart
- Flutter
- Flutter Bloc

## Troubleshooting

Common setup issues:

1. **Flutter SDK not found**
   - Ensure Flutter is in your PATH
   - Run `flutter doctor` to diagnose issues

2. **Dependency conflicts**
   - Try running `flutter clean` followed by `flutter pub get`

3. **Build failures**
   - Check for breaking changes in dependencies
   - Review the error logs in the terminal
