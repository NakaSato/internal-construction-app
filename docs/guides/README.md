# Developer Guides

This section provides guides and best practices for developers working on the Flutter Architecture App.

## Coding Standards

### Naming Conventions

- **Classes**: `UpperCamelCase` (e.g., `UserRepository`, `AuthBloc`)
- **Variables/Methods**: `lowerCamelCase` (e.g., `userName`, `signIn()`)
- **Constants**: `lowerCamelCase` with descriptive names
- **Files**: `snake_case.dart` (e.g., `user_repository.dart`)
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

## Common Development Workflows

### Feature Development

1. **Create Feature Structure**:
   ```
   lib/features/new_feature/
   ├── domain/
   │   ├── entities/
   │   ├── repositories/
   │   └── usecases/
   ├── infrastructure/
   │   ├── datasources/
   │   ├── models/
   │   └── repositories/
   ├── application/
   │   ├── blocs/
   │   └── events/
   └── presentation/
       ├── screens/
       └── widgets/
   ```

2. **Define Domain Layer**:
   - Create entities
   - Define repository interfaces
   - Implement use cases

3. **Implement Infrastructure Layer**:
   - Create DTOs (Data Transfer Objects)
   - Implement repositories
   - Connect to external data sources

4. **Build Application Layer**:
   - Implement BLoCs/Cubits
   - Define events and states

5. **Create Presentation Layer**:
   - Build screens and widgets
   - Connect UI to BLoCs/Cubits

### Adding Dependencies

1. Update `pubspec.yaml`
2. Run `flutter pub get`
3. Register any services in the dependency injection container

## Performance Optimization

### Widget Optimization

- Use `const` constructors where possible
- Implement `shouldRepaint` in custom painters
- Use `RepaintBoundary` to isolate repaints

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

## Debugging Tips

### Flutter DevTools

1. Run `flutter run` with `--debug`
2. Open DevTools from the console link
3. Use the Inspector, Performance, and Memory tabs

### Common Issues

1. **Widget rebuilds too often**
   - Check BLoC/Cubit state emissions
   - Use `const` constructors
   - Implement `==` and `hashCode` for custom classes

2. **Memory leaks**
   - Dispose controllers and subscriptions
   - Cancel timers
   - Close streams

3. **Performance issues**
   - Use the Performance tab in DevTools
   - Look for jank frames
   - Optimize renderObject trees

## Code Generation

### Build Runner Commands

```bash
# Generate code
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch

# Delete conflicting outputs
flutter packages pub run build_runner build --delete-conflicting-outputs
```
