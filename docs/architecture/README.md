# Architecture Documentation

This section provides information about the architectural design of the Flutter Architecture App.

## Overview

The Flutter Architecture App follows a Feature-First Clean Architecture approach, which organizes code by features rather than technical layers.

## Contents

- [Overview](./overview.md) - Overview of the architectural approach
- [Clean Architecture](./clean_architecture.md) - Explanation of Clean Architecture implementation
- [Feature-First Organization](./feature_first.md) - Guide to Feature-First organization
- [Dependency Injection](./dependency_injection.md) - Dependency injection patterns using get_it
- [Project Structure](/docs/detailed_project_structure.md) - Detailed project structure showing files and folders

## Key Architecture Concepts

### Feature-First Organization
```
lib/features/
├── authentication/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   ├── infrastructure/
│   │   ├── datasources/
│   │   ├── models/
│   │   └── repositories/
│   ├── application/
│   │   ├── blocs/
│   │   ├── cubits/
│   │   └── events/
│   └── presentation/
│       ├── screens/
│       ├── widgets/
│       └── pages/
```

### Core Principles
- **Single Responsibility**: Each class/method has one reason to change
- **Dependency Inversion**: Dependencies point inward, with outer layers depending on abstractions
- **Interface Segregation**: Create focused, specific interfaces
- **Open/Closed**: Open for extension, closed for modification
- **Clear Boundaries**: Distinct separation between layers (domain, application, infrastructure, presentation)

### Key Design Decisions

1. **Domain Layer**: Contains business logic and entities, independent of any external framework
2. **Application Layer**: Contains use cases and application-specific logic, using BLoC/Cubit pattern
3. **Infrastructure Layer**: Contains implementations of repositories and external services
4. **Presentation Layer**: Contains UI components, built with Flutter widgets and Material Design 3
