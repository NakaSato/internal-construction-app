# Architecture Overview

This document provides an overview of the Flutter Architecture App's architectural approach, which combines Clean Architecture with a Feature-First organization.

## Architecture Principles

The architecture is built on the following key principles:

1. **Separation of Concerns**: Each layer has a distinct responsibility
2. **Dependency Rule**: Dependencies only point inward
3. **Testability**: All components are designed to be easily testable
4. **Independence**: The domain layer is independent of frameworks and UI

## Architectural Layers

### Domain Layer

The innermost layer that contains business logic and rules.

- **Entities**: Core business objects
- **Repositories** (interfaces): Define data access contracts
- **Use Cases**: Encapsulate business rules

### Application Layer

Orchestrates the flow of data and manages application state.

- **BLoCs/Cubits**: Handle state management
- **Events**: Define triggers for state changes
- **States**: Represent UI states

### Infrastructure Layer

Implements interfaces defined in the domain layer.

- **Repositories** (implementations): Implement data access
- **Data Sources**: Connect to external systems (APIs, databases)
- **Models**: DTOs for data translation

### Presentation Layer

Responsible for UI and user interaction.

- **Screens**: Full application screens
- **Widgets**: Reusable UI components
- **Pages**: Routable screen components

## Feature-First Organization

The code is organized primarily by features, not by technical layers:

```
lib/
├── core/              # Shared core functionality
│   ├── config/        # App configuration
│   ├── api/           # API client setup
│   ├── theme/         # App theming
│   ├── navigation/    # Routing system
│   ├── utils/         # Utilities and helpers
│   └── widgets/       # Shared widgets
│
├── features/          # Feature modules
│   ├── authentication/
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   ├── application/
│   │   └── presentation/
│   │
│   ├── project_management/
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   ├── application/
│   │   └── presentation/
│   │
│   └── calendar_management/
│       ├── domain/
│       ├── infrastructure/
│       ├── application/
│       └── presentation/
│
└── main.dart          # Application entry point
```

## Dependency Injection

Dependency injection is managed using the `get_it` package:

```dart
// Service locator pattern with get_it
final getIt = GetIt.instance;

void setupDependencies() {
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  
  // Use cases
  getIt.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(getIt()),
  );
  
  // BLoCs/Cubits
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(getIt()),
  );
}
```

## Navigation

Routing is managed using go_router for declarative navigation:

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'projects',
          builder: (context, state) => const ProjectListScreen(),
        ),
        GoRoute(
          path: 'projects/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProjectDetailScreen(projectId: id);
          },
        ),
      ],
    ),
  ],
);
```

## State Management

The app uses the BLoC/Cubit pattern for state management:

```dart
// Cubit example
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(AuthInitial());
  
  final AuthRepository _authRepository;
  
  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

// BLoC example
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc(this._projectRepository) : super(ProjectInitial()) {
    on<ProjectLoadRequested>(_onLoadRequested);
    on<ProjectCreated>(_onProjectCreated);
  }
  
  // Event handlers...
}
```

## Benefits of This Architecture

1. **Modularity**: Features can be developed independently
2. **Testability**: Each layer can be tested in isolation
3. **Scalability**: Easy to add new features without modifying existing code
4. **Maintainability**: Clear separation of concerns makes code easier to understand
5. **Flexibility**: Implementation details can change without affecting business logic
