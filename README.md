# Flutter Architecture App

A comprehensive Flutter application demonstrating Feature-First architecture with Clean Architecture principles. This project includes authentication, project management, calendar integration, daily reports, image upload, and location tracking features.

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
    ├── project_management/         # Project management feature
    ├── calendar_management/        # Calendar management feature
    ├── daily_reports/             # Daily reports feature
    ├── image_upload/              # Image upload feature
    ├── location_tracking/         # Location tracking feature
    └── work_calendar/            # Work calendar feature
```

## 🚀 Features

- ✅ **Enhanced Authentication** - Modern login/register with improved error handling
- 📊 **Project Management** - Enhanced project list with status tracking and progress visualization
- 📅 **Calendar Integration** - Interactive calendar with project deadlines and event management
- 📋 **Daily Reports** - Comprehensive field reports management system
- 🔄 **Image Upload** - Camera and gallery image handling with compression
- 📍 **Location Tracking** - Real-time location services with background tracking
- 🎨 **Modern UI/UX** - Material 3 design with glassmorphism effects and smooth animations

## 🛠️ Tech Stack

- **Framework**: Flutter 3.32.2+
- **State Management**: BLoC/Cubit pattern
- **Navigation**: GoRouter with authentication guards
- **Dependency Injection**: get_it + injectable
- **Secure Storage**: flutter_secure_storage
- **Network**: Dio with comprehensive error handling
- **Calendar**: table_calendar + Syncfusion Flutter Calendar
- **Architecture**: Feature-First + Clean Architecture
- **UI Components**: Material 3 with custom theming

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

## 📚 Documentation

Comprehensive documentation is available in the [`docs/`](./docs/) directory:

- **[📖 Complete Overview](./docs/FLUTTER_ARCHITECTURE_APP_FINAL_SUMMARY.md)** - Full project summary and features
- **[🏠 Enhanced Project List](./docs/ENHANCED_PROJECT_LIST_SUMMARY.md)** - Project management implementation
- **[📅 Calendar Management](./docs/CALENDAR_MANAGEMENT_FINAL_SUMMARY.md)** - Calendar integration details
- **[📋 Daily Reports](./docs/DAILY_REPORTS_API_DEMO_SUMMARY.md)** - Reports management system
- **[🔧 API Error Handling](./docs/API_ERROR_HANDLING_SUMMARY.md)** - Error handling improvements
- **[🐛 Debug Guides](./docs/README.md)** - Troubleshooting and implementation guides

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for authentication services
- Open source community for excellent packages
