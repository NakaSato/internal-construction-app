# flutter_architecture_app

# Flutter Architecture App

A comprehensive Flutter application demonstrating Feature-First architecture with Clean Architecture principles. This project includes authentication, image upload, location tracking, and work calendar features.

## 🏗️ Architecture

This project follows **Feature-First architecture** with **Clean Architecture** principles:

```
lib/
├── core/                           # Shared core functionality
│   ├── config/                     # App configuration
│   ├── di/                         # Dependency injection
│   ├── navigation/                 # Navigation setup
│   ├── network/                    # Network layer
│   ├── utils/                      # Utilities and extensions
│   └── widgets/                    # Reusable UI components
└── features/                       # Feature modules
    ├── authentication/             # Authentication feature
    │   ├── application/            # BLoC/business logic
    │   ├── domain/                 # Entities and repositories
    │   ├── infrastructure/         # Data sources and implementations
    │   └── presentation/           # UI screens and widgets
    ├── image_upload/              # Image upload feature
    ├── location_tracking/         # Location tracking feature
    └── work_calendar/            # Work calendar feature
```

## 🚀 Features

- ✅ **Authentication** - Sign in, sign up, password reset
- 🔄 **Image Upload** - Camera and gallery image handling
- 📍 **Location Tracking** - Real-time location services
- 📅 **Work Calendar** - Calendar management and scheduling

## 🛠️ Tech Stack

- **Framework**: Flutter 3.27.0+
- **State Management**: BLoC/Cubit
- **Navigation**: GoRouter
- **Dependency Injection**: get_it + injectable
- **Authentication**: Firebase Auth
- **Secure Storage**: flutter_secure_storage
- **Network**: Dio
- **Calendar**: Syncfusion Flutter Calendar
- **Architecture**: Feature-First + Clean Architecture

## 📋 Prerequisites

- Flutter SDK (3.27.0 or higher)
- Dart SDK (3.6.0 or higher)
- Firebase project (for authentication)
- VS Code or Android Studio
- iOS Simulator / Android Emulator or physical device

## 🔧 Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd flutter-dev
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate dependency injection**:
   ```bash
   dart run build_runner build
   ```

4. **Firebase Setup**:
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add your app to the Firebase project
   - Download configuration files:
     - `google-services.json` for Android (place in `android/app/`)
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
   - Update `lib/firebase_options.dart` with your Firebase configuration

5. **Environment Configuration**:
   ```bash
   cp .env.example .env
   # Update .env with your configuration values
   ```

## 🏃‍♂️ Running the App

### Development
```bash
flutter run
```

### VS Code Tasks
The project includes VS Code tasks for common operations:
- **Run Flutter App**: `Cmd+Shift+P` → `Tasks: Run Task` → `Run Flutter App`

### Available Platforms
- ✅ Android
- ✅ iOS
- ✅ macOS
- ✅ Web
- ✅ Windows
- ✅ Linux

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## 🏗️ Architecture Details

### Core Layer
- **Config**: App constants, themes, environment configuration
- **DI**: Dependency injection setup using get_it and injectable
- **Navigation**: Centralized routing with GoRouter
- **Network**: HTTP client with interceptors and error handling
- **Utils**: Common utilities, extensions, and helper functions
- **Widgets**: Reusable UI components

### Feature Layers
Each feature follows internal layering:

1. **Domain**: Business entities and repository interfaces
2. **Application**: BLoCs, Cubits, and use cases
3. **Infrastructure**: Repository implementations and data sources
4. **Presentation**: UI screens, widgets, and user interactions

### State Management
- **BLoC Pattern**: For complex state management
- **Cubit**: For simpler state scenarios
- **Riverpod**: Alternative state management (where applicable)

### Navigation
- **GoRouter**: Declarative routing with type safety
- **Route Guards**: Authentication-based navigation
- **Deep Linking**: Support for web and mobile deep links

## 📁 Project Structure

```
flutter-dev/
├── android/                       # Android-specific files
├── ios/                          # iOS-specific files
├── lib/                          # Main application code
├── macos/                        # macOS-specific files
├── test/                         # Test files
├── web/                          # Web-specific files
├── windows/                      # Windows-specific files
├── linux/                        # Linux-specific files
├── .env.example                  # Environment template
├── .gitignore                    # Git ignore rules
├── analysis_options.yaml         # Dart analysis options
├── pubspec.yaml                  # Dependencies and metadata
└── README.md                     # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📝 Code Style

This project follows:
- [Flutter Style Guide](https://docs.flutter.dev/development/tools/formatting)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Custom linting rules in `analysis_options.yaml`

## 🐛 Known Issues

- Firebase configuration requires manual setup
- Some deprecated APIs need updating (see flutter analyze output)
- Location services require platform-specific permissions

## 📖 Documentation

- [Architecture Guide](docs/architecture.md)
- [Feature Development](docs/features.md)
- [Testing Guide](docs/testing.md)
- [Deployment Guide](docs/deployment.md)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for authentication services
- Open source community for excellent packages
