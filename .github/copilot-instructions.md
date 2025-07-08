<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Solar Project Management App - Copilot Instructions

## Project Overview
This is a comprehensive Flutter application for managing solar installation projects. It follows Feature-First architecture with Clean Architecture principles, providing a robust platform for project management, team collaboration, and real-time notifications.

### Application Features
- **Project Management**: Create, track, and manage solar installation projects
- **Team Collaboration**: Role-based access control and team coordination
- **Real-time Notifications**: Push notifications and in-app messaging
- **Work Calendar**: Schedule management and task tracking
- **Image Upload**: Document management and progress photos
- **Authentication**: Secure user authentication with role management
- **Dashboard Analytics**: Project statistics and progress tracking
- **Account Management**: Multi-account switching and user profiles

### Tech Stack
- **Frontend**: Flutter 3.24+ with Material Design 3
- **State Management**: BLoC/Cubit pattern with flutter_bloc ^8.1.3
- **Routing**: go_router ^12.1.1 for declarative navigation
- **Architecture**: Clean Architecture + Feature-First organization
- **Backend Integration**: RESTful APIs with dio ^5.3.2
- **Local Storage**: flutter_secure_storage ^9.0.0 for sensitive data
- **Dependency Injection**: get_it ^7.6.4 service locator pattern
- **Functional Programming**: dartz ^0.10.1 for Either types
- **Value Equality**: equatable ^2.0.5 for state comparison
- **Image Handling**: image_picker ^1.0.4 for media selection
- **Calendar UI**: syncfusion_flutter_calendar ^23.1.36
- **Testing**: flutter_test, mockito, bloc_test for comprehensive testing

## Architecture Guidelines

### Feature-First Organization
```
lib/
├── app.dart                    # Main app wrapper with focus/navigation listeners
├── main.dart                   # App entry point and dependency setup
├── core/                       # Shared utilities and widgets
│   ├── constants/              # App-wide constants
│   ├── error/                  # Error handling and failure types
│   ├── network/                # API client configuration
│   ├── theme/                  # Material 3 theme configuration
│   ├── utils/                  # Helper utilities
│   └── widgets/                # Reusable UI components
│       ├── app_header.dart     # Common app header with notifications
│       ├── app_bottom_bar.dart # Custom bottom navigation
│       └── dashboard/          # Dashboard-specific components
├── features/
│   ├── authentication/
│   │   ├── domain/
│   │   │   ├── entities/       # Core business objects
│   │   │   ├── repositories/   # Abstract repository interfaces
│   │   │   └── usecases/       # Business logic use cases
│   │   ├── infrastructure/
│   │   │   ├── datasources/    # Remote and local data sources
│   │   │   ├── models/         # Data transfer objects
│   │   │   └── repositories/   # Repository implementations
│   │   ├── application/
│   │   │   ├── blocs/          # Complex state management
│   │   │   ├── cubits/         # Simple state management
│   │   │   └── events/         # Event definitions
│   │   └── presentation/
│   │       ├── screens/        # Full screen widgets
│   │       ├── widgets/        # Feature-specific components
│   │       └── pages/          # Page-level components
│   ├── projects/               # Project management feature
│   ├── notifications/          # Real-time notifications
│   ├── calendar/               # Work scheduling
│   └── profile/                # User profile and settings
└── shared/                     # Cross-feature shared code
    ├── dependency_injection/   # Service locator setup
    └── routing/                # App routing configuration
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
- Prefer StatelessWidget over StatefulWidget when possible
- Break down large widgets into smaller, focused components
- Use responsive design patterns for different screen sizes

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
- Consider performance impact of animations on lower-end devices
- Use appropriate easing curves for natural motion
- Keep animation durations reasonable (200-300ms for UI feedback)

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

## Testing Best Practices

### Widget Testing Patterns
```dart
// Test with BLoC providers
testWidgets('should display project list when loaded', (tester) async {
  final mockProjectBloc = MockProjectBloc();
  
  when(() => mockProjectBloc.state).thenReturn(
    ProjectLoaded(projects: [mockProject]),
  );
  
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<ProjectBloc>.value(
        value: mockProjectBloc,
        child: const ProjectListScreen(),
      ),
    ),
  );
  
  expect(find.byType(ProjectCard), findsOneWidget);
  expect(find.text(mockProject.name), findsOneWidget);
});
```

### BLoC Testing
```dart
// Test BLoC events and states
blocTest<ProjectBloc, ProjectState>(
  'should emit ProjectLoaded when ProjectLoadRequested is added',
  build: () => ProjectBloc(mockRepository),
  act: (bloc) => bloc.add(ProjectLoadRequested()),
  expect: () => [
    ProjectLoading(),
    ProjectLoaded(projects: mockProjects),
  ],
  verify: () {
    verify(() => mockRepository.getProjects()).called(1);
  },
);
```

### Integration Testing
```dart
// End-to-end user flows
testWidgets('complete project creation flow', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Navigate to project creation
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  
  // Fill form
  await tester.enterText(find.byKey(Key('project_name_field')), 'Test Project');
  await tester.enterText(find.byKey(Key('project_description_field')), 'Description');
  
  // Submit
  await tester.tap(find.byKey(Key('create_project_button')));
  await tester.pumpAndSettle();
  
  // Verify success
  expect(find.text('Project created successfully'), findsOneWidget);
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

### Performance Best Practices
- **Minimize rebuilds**: Use BlocSelector and BlocBuilder appropriately
- **Optimize images**: Use cached_network_image for remote images
- **Lazy loading**: Implement pagination for large datasets
- **Memory management**: Dispose controllers and close streams
- **Widget optimization**: Use RepaintBoundary for expensive widgets
- **Build optimization**: Use const constructors and widgets
- **State optimization**: Keep state classes lightweight and immutable

### Build Optimization
```dart
// Good: Using const constructor
const Card(
  child: ListTile(
    title: Text('Static Content'),
  ),
);

// Good: Separating dynamic content
class DynamicCard extends StatelessWidget {
  const DynamicCard({super.key, required this.data});
  
  final String data;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(data), // Only this rebuilds when data changes
        trailing: const Icon(Icons.arrow_forward), // This stays const
      ),
    );
  }
}
```

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

## Quick Reference

### Essential Commands
```bash
# Flutter Development
flutter create --template app --platforms android,ios my_app
flutter pub get
flutter pub upgrade --major-versions
flutter analyze
flutter test --coverage
flutter build apk --release
flutter build ios --release

# Code Generation
flutter packages pub run build_runner build
flutter packages pub run build_runner watch
flutter packages pub run build_runner build --delete-conflicting-outputs

# Code Quality
dart analyze
dart format .
flutter test --coverage
dart run import_sorter:main
```

### Common Patterns Quick Reference
```dart
// BLoC Event Pattern
abstract class ProjectEvent extends Equatable {
  const ProjectEvent();
  @override
  List<Object> get props => [];
}

// Repository Pattern
abstract class ProjectRepository {
  Future<Either<Failure, List<Project>>> getProjects();
  Future<Either<Failure, Project>> createProject(CreateProjectParams params);
}

// Use Case Pattern
class GetProjectsUseCase {
  const GetProjectsUseCase(this._repository);
  final ProjectRepository _repository;
  
  Future<Either<Failure, List<Project>>> call() => _repository.getProjects();
}
```

### Material 3 Color Usage
```dart
// Use semantic colors from theme
final colors = Theme.of(context).colorScheme;
Container(
  color: colors.surface,
  child: Text(
    'Content',
    style: TextStyle(color: colors.onSurface),
  ),
)
```

### Remember
- **Code Quality**: Prioritize readability, maintainability, and testability
- **Performance**: Use const constructors, lazy loading, and proper disposal
- **Architecture**: Maintain clean separation between layers
- **Testing**: Write comprehensive unit, widget, and integration tests
- **User Experience**: Handle loading states, errors, and empty states gracefully
- **Security**: Never hardcode sensitive data, use secure storage appropriately

When in doubt, favor **explicit over implicit** and **simple over complex**.

## Navigation & Routing Best Practices

### Go Router Configuration
```dart
// Define routes with proper type safety
final GoRouter router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/projects/:id',
      name: 'project-detail',
      builder: (context, state) {
        final projectId = state.pathParameters['id']!;
        return ProjectDetailScreen(projectId: projectId);
      },
    ),
  ],
  redirect: (context, state) {
    final isLoggedIn = context.read<AuthCubit>().state is AuthAuthenticated;
    if (!isLoggedIn && state.matchedLocation != '/login') {
      return '/login';
    }
    return null;
  },
);
```

### Navigation Patterns
- Use named routes for better maintainability
- Implement proper deep linking support
- Handle navigation guards for authentication
- Use context.go() for navigation replacement
- Use context.push() for navigation stack addition
- Implement proper back button handling

## Solar Project Specific Patterns

### Project Status Management
```dart
enum ProjectStatus {
  planning,
  approved,
  inProgress,
  completed,
  onHold,
  cancelled;

  String get displayName {
    switch (this) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.approved:
        return 'Approved';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case ProjectStatus.planning:
        return Colors.orange;
      case ProjectStatus.approved:
        return Colors.blue;
      case ProjectStatus.inProgress:
        return Colors.green;
      case ProjectStatus.completed:
        return Colors.teal;
      case ProjectStatus.onHold:
        return Colors.amber;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }
}
```

### Real-time Data Patterns
```dart
// Stream-based real-time updates
class ProjectStreamRepository {
  Stream<List<Project>> watchProjects() {
    return _projectStream.map((data) => 
      data.map((json) => Project.fromJson(json)).toList()
    );
  }
  
  Stream<Project> watchProject(String id) {
    return _projectStream
        .map((data) => data.firstWhere((p) => p['id'] == id))
        .map((json) => Project.fromJson(json));
  }
}
```

### Role-Based Access Control
```dart
enum UserRole {
  admin,
  projectManager,
  technician,
  viewer;

  bool canEditProject() {
    return this == admin || this == projectManager;
  }

  bool canViewFinancials() {
    return this == admin || this == projectManager;
  }

  bool canManageTeam() {
    return this == admin;
  }
}
```

## Data Refresh & Synchronization

### App Focus & Navigation Listeners
```dart
// Implement in app.dart for global state management
class _AppWrapperState extends State<AppWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Trigger data refresh when app comes to foreground
      context.read<ProjectBloc>().add(ProjectRefreshRequested());
      context.read<NotificationCubit>().refreshNotifications();
    }
  }
}
```

### Account Switch Data Refresh
```dart
// Handle account switching with proper data refresh
class AccountSwitchHandler {
  static Future<void> switchAccount(String accountId) async {
    // Clear current data
    await _clearCachedData();
    
    // Switch account context
    await _authService.switchAccount(accountId);
    
    // Refresh all relevant data
    _projectBloc.add(ProjectLoadRequested());
    _notificationCubit.refreshNotifications();
    _profileCubit.loadProfile();
  }
}
```

## Development Workflow

### Code Quality Checklist
- [ ] Follow naming conventions consistently
- [ ] Use const constructors where possible
- [ ] Implement proper error handling
- [ ] Add meaningful comments for complex logic
- [ ] Ensure null safety compliance
- [ ] Test critical user flows
- [ ] Optimize for performance
- [ ] Follow Material Design 3 guidelines

### Git Workflow
```bash
# Feature development
git checkout -b feature/project-management
git add .
git commit -m "feat: add project creation functionality"
git push origin feature/project-management

# Code review and merge
# Create PR, get approval, merge to main
```

### Debugging Tips
- Use `debugPrint()` for development logging
- Implement proper logging with different levels
- Use Flutter Inspector for widget debugging
- Profile performance with DevTools
- Test on different screen sizes and orientations
- Validate accessibility with screen readers

### Environment Configuration
```dart
// Environment-specific configurations
abstract class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.example.com',
  );
  
  static const bool isDebug = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: false,
  );
}
```
