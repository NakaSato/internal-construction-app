# Flutter Architecture App - Project Structure

## Overview
This document outlines the organized structure of the Flutter Architecture App project following Feature-First architecture with Clean Architecture principles.

## Root Directory Structure

```
flutter-dev/
├── lib/                          # Main application code
├── test/                         # Test files organized by type
├── docs/                         # Documentation and summaries
├── assets/                       # Static assets (images, etc.)
├── android/                      # Android platform specific code
├── ios/                          # iOS platform specific code
├── web/                          # Web platform specific code
├── windows/                      # Windows platform specific code
├── linux/                        # Linux platform specific code
├── macos/                        # macOS platform specific code
└── pubspec.yaml                  # Project dependencies
```

## Lib Directory Structure

```
lib/
├── main.dart                     # Application entry point
├── core/                         # Core functionality shared across features
│   ├── config/                   # App configuration and constants
│   ├── di/                       # Dependency injection setup
│   ├── navigation/               # App routing and navigation
│   ├── network/                  # Network layer and HTTP client
│   ├── utils/                    # Utility functions and extensions
│   └── widgets/                  # Reusable UI components
├── features/                     # Feature modules (Feature-First architecture)
│   ├── authentication/           # User authentication feature
│   ├── authorization/            # User authorization and permissions
│   ├── calendar_management/      # Calendar management feature
│   ├── project_management/       # Project management feature
│   ├── work_calendar/            # Work calendar feature
│   ├── daily_reports/            # Daily reports feature
│   └── api_projects/             # API projects feature
└── demos/                        # Demo files and examples
    ├── calendar/                 # Calendar demo files
    ├── daily_reports/            # Daily reports demo files
    └── projects/                 # Project demo files
```

## Feature Structure (Example: Authentication)

Each feature follows Clean Architecture layering:

```
authentication/
├── application/                  # Application layer (BLoC/Cubit)
├── domain/                       # Domain layer (entities, repositories)
│   ├── entities/                 # Domain entities
│   └── repositories/             # Repository interfaces
├── infrastructure/               # Infrastructure layer (data sources)
│   ├── models/                   # Data models
│   ├── repositories/             # Repository implementations
│   └── services/                 # External services
└── presentation/                 # Presentation layer (UI)
    ├── screens/                  # UI screens
    └── viewmodel/                # View models (if needed)
```

## Test Directory Structure

```
test/
├── unit/                         # Unit tests
├── integration/                  # Integration tests
├── utils/                        # Test utilities and debug files
├── core/                         # Core functionality tests
├── features/                     # Feature-specific tests
└── test_helpers/                 # Test helper functions
```

## Documentation Structure

```
docs/
├── summaries/                    # Project development summaries
├── PROJECT_STRUCTURE.md          # This file
└── README.md                     # Main documentation
```

## Key Principles

### 1. Feature-First Architecture
- Each feature is self-contained in its own directory
- Features can be developed and tested independently
- Easy to scale and maintain

### 2. Clean Architecture Layers
- **Domain**: Business logic and entities
- **Application**: Use cases and application logic (BLoC/Cubit)
- **Infrastructure**: Data sources and external services
- **Presentation**: UI components and screens

### 3. Dependency Direction
- Dependencies point inward toward the domain layer
- Domain layer has no dependencies on external layers
- Infrastructure implements domain interfaces

### 4. Separation of Concerns
- Core functionality is shared across features
- Each layer has a specific responsibility
- UI is separated from business logic

## File Naming Conventions

- **Classes**: `PascalCase` (e.g., `UserRepository`)
- **Files**: `snake_case` (e.g., `user_repository.dart`)
- **Directories**: `snake_case` (e.g., `authentication/`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `API_BASE_URL`)

## Import Organization

1. Dart/Flutter packages
2. Third-party packages
3. Internal core imports
4. Internal feature imports
5. Relative imports

Example:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dio/dio.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/extensions.dart';

import '../../domain/entities/user.dart';
import '../../application/auth_bloc.dart';

import '../widgets/login_form.dart';
```

## Best Practices

1. Keep widgets "dumb" - move business logic to BLoCs/Cubits
2. Use dependency injection for loose coupling
3. Write tests for all business logic
4. Follow Flutter and Dart style guidelines
5. Use meaningful, descriptive names
6. Handle errors gracefully
7. Use environment variables for configuration
