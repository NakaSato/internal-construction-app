<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Flutter Architecture App - Copilot Instructions

## Project Overview
This is a medium-sized Flutter application following Feature-First architecture with Clean Architecture principles. The app includes authentication, image upload, work calendar features, and project management capabilities.

### Tech Stack
- **Frontend**: Flutter 3.x with Material Design 3
- **State Management**: BLoC/Cubit pattern with flutter_bloc
- **Routing**: go_router for declarative navigation
- **Architecture**: Clean Architecture + Feature-First organization
- **Backend Integration**: RESTful APIs with dio
- **Local Storage**: flutter_secure_storage for sensitive data

## Architecture Guidelines

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
- **Single Responsibility**: Each class/method should have one reason to change
- **Dependency Inversion**: Depend on abstractions, not concretions
- **Interface Segregation**: Create focused, specific interfaces
- **Open/Closed**: Open for extension, closed for modification
- **Clean Separation**: Clear boundaries between layers (domain, application, infrastructure, presentation)

### Widget Guidelines
- Keep widgets "dumb" - no business logic in widgets
- Extract complex UI into smaller, composable widgets
- Use const constructors wherever possible for performance
- Implement proper key usage for widget identity
- Follow Material Design 3 principles for consistent UI

## State Management Patterns

### BLoC/Cubit Usage
```dart
// Preferred: Use Cubit for simple state management
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

// Use BLoC for complex event-driven scenarios
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc(this._projectRepository) : super(ProjectInitial()) {
    on<ProjectLoadRequested>(_onLoadRequested);
    on<ProjectCreated>(_onProjectCreated);
  }
}
```

### State Classes
- Use sealed classes for state definitions when possible
- Include all necessary data in state objects
- Implement proper equality comparison (equatable)
- Use immutable data structures

## Code Quality Standards

### Naming Conventions
- **Classes**: `UpperCamelCase` (e.g., `UserRepository`, `AuthBloc`)
- **Variables/Methods**: `lowerCamelCase` (e.g., `userName`, `signIn()`)
- **Constants**: `lowerCamelCase` with descriptive names
- **Files**: `snake_case` (e.g., `user_repository.dart`)
- **Private members**: Prefix with underscore `_privateMethod()`

### Code Organization
```dart
// File structure template
class ExampleWidget extends StatelessWidget {
  // 1. Constructor and properties
  const ExampleWidget({
    super.key,
    required this.property,
    this.optionalProperty,
  });
  
  final String property;
  final String? optionalProperty;
  
  // 2. Build method
  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }
  
  // 3. Private helper methods
  Widget _buildContent(BuildContext context) {
    // Implementation
  }
  
  // 4. Static methods and constants
  static const String constantValue = 'value';
}
```

### Error Handling Patterns
```dart
// Repository pattern with proper error handling
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
}

class UserRepositoryImpl implements UserRepository {
  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      final response = await _apiClient.get('/users/$id');
      return Right(User.fromJson(response.data));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
```

## UI/UX Guidelines

### Material Design 3 Implementation
- Use `Theme.of(context).colorScheme` for consistent colors
- Implement proper elevation and surface tinting
- Follow Material 3 spacing guidelines (4dp grid system)
- Use semantic color roles (primary, secondary, surface, etc.)

### Responsive Design
```dart
// Use LayoutBuilder for responsive widgets
Widget _buildResponsiveLayout(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth > 768) {
        return _buildDesktopLayout();
      } else if (constraints.maxWidth > 480) {
        return _buildTabletLayout();
      } else {
        return _buildMobileLayout();
      }
    },
  );
}
```

### Animation Guidelines
- Use implicit animations (AnimatedContainer, AnimatedOpacity) when possible
- Implement custom animations with AnimationController for complex scenarios
- Follow Material motion guidelines for duration and curves
- Add meaningful transitions between screens

## Key Dependencies & Usage

### Essential Packages
```yaml
dependencies:
  flutter_bloc: ^8.1.3          # State management
  go_router: ^12.1.1            # Declarative routing
  dio: ^5.3.2                   # HTTP client
  flutter_secure_storage: ^9.0.0 # Secure local storage
  get_it: ^7.6.4                # Dependency injection
  equatable: ^2.0.5             # Value equality
  dartz: ^0.10.1                # Functional programming
  image_picker: ^1.0.4          # Image selection
  syncfusion_flutter_calendar: ^23.1.36 # Calendar UI
```

### Dependency Injection Setup
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

## Testing Strategy

### Test Structure
```
test/
├── unit/
│   ├── domain/
│   │   ├── entities/
│   │   └── usecases/
│   ├── infrastructure/
│   └── application/
├── widget/
├── integration/
└── helpers/
    ├── test_helper.dart
    └── mock_dependencies.dart
```

### Testing Patterns
```dart
// Unit test example
group('SignInUseCase', () {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;
  
  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });
  
  test('should return user when sign in is successful', () async {
    // Arrange
    const email = 'test@example.com';
    const password = 'password';
    const user = User(id: '1', email: email);
    
    when(() => mockRepository.signIn(email, password))
        .thenAnswer((_) async => const Right(user));
    
    // Act
    final result = await useCase(SignInParams(email, password));
    
    // Assert
    expect(result, const Right(user));
    verify(() => mockRepository.signIn(email, password)).called(1);
  });
});

// Widget test example
testWidgets('AuthScreen should show loading indicator when signing in', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<AuthBloc>(
        create: (_) => mockAuthBloc,
        child: const AuthScreen(),
      ),
    ),
  );
  
  when(() => mockAuthBloc.state).thenReturn(AuthLoading());
  
  await tester.pump();
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## Security & Performance

### Security Best Practices
- **Never hardcode** API keys, tokens, or sensitive data
- Use **flutter_secure_storage** for authentication tokens
- **Validate all inputs** on both client and server sides
- Implement **proper certificate pinning** for production
- **Obfuscate** sensitive business logic in release builds
- Use **biometric authentication** when appropriate

### Performance Optimization
- Use **const constructors** for immutable widgets
- Implement **lazy loading** for large datasets
- **Cache images** and API responses appropriately
- Use **ListView.builder** for long lists
- **Dispose** controllers and subscriptions properly
- Implement **pagination** for large data sets

### Memory Management
```dart
// Proper disposal pattern
class ExampleWidget extends StatefulWidget {
  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  late final TextEditingController _controller;
  late final StreamSubscription _subscription;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _subscription = someStream.listen(_handleData);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }
}
```

## API Integration Patterns

### Repository Implementation
```dart
class ProjectRepositoryImpl implements ProjectRepository {
  const ProjectRepositoryImpl(this._apiClient, this._localDataSource);
  
  final ApiClient _apiClient;
  final ProjectLocalDataSource _localDataSource;
  
  @override
  Future<Either<Failure, List<Project>>> getProjects() async {
    try {
      // Try cache first
      final cachedProjects = await _localDataSource.getProjects();
      if (cachedProjects.isNotEmpty) {
        return Right(cachedProjects);
      }
      
      // Fetch from network
      final response = await _apiClient.get('/projects');
      final projects = (response.data as List)
          .map((json) => Project.fromJson(json))
          .toList();
      
      // Cache the results
      await _localDataSource.saveProjects(projects);
      
      return Right(projects);
    } on DioException catch (e) {
      return Left(NetworkFailure.fromDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
```

## Common Patterns & Anti-Patterns

### ✅ Good Practices
- Use dependency injection for testability
- Implement proper error handling with Either<Failure, Success>
- Create reusable, composable widgets
- Follow consistent naming conventions
- Write comprehensive tests
- Use proper state management patterns
- Implement loading states and error handling in UI

### ❌ Anti-Patterns to Avoid
- Don't put business logic in widgets
- Don't use BuildContext across async boundaries
- Avoid deeply nested widget trees
- Don't ignore null safety warnings
- Don't use magic numbers or strings
- Avoid tightly coupled code
- Don't skip error handling

## Code Generation & Automation

### Useful Code Generation
```dart
// JSON serialization with json_annotation
@JsonSerializable()
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.name,
  });
  
  final String id;
  final String email;
  final String? name;
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  @override
  List<Object?> get props => [id, email, name];
}
```

### Build Runner Commands
```bash
# Generate code
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch

# Delete conflicting outputs
flutter packages pub run build_runner build --delete-conflicting-outputs
```

---

## Quick Reference Commands

### Flutter Commands
```bash
flutter create --template app --platforms android,ios my_app
flutter pub get
flutter pub upgrade
flutter analyze
flutter test
flutter build apk --release
flutter build ios --release
```

### Code Analysis
```bash
dart analyze
dart format .
flutter test --coverage
```

Remember: Always prioritize code readability, maintainability, and testability. When in doubt, favor explicit over implicit, and simple over complex.
