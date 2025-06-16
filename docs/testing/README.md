# Testing Documentation

This section documents the testing strategies, approaches, and best practices for the Flutter Architecture App.

## Testing Strategy

The project follows a comprehensive testing strategy that includes:

1. **Unit Tests**: For business logic, usecases, and repositories
2. **Widget Tests**: For UI components and interactions
3. **Integration Tests**: For feature workflows and API integration

## Test Structure

Tests are organized in a structure that mirrors the application code:

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

## Unit Testing

### Domain Layer Testing

```dart
// Example unit test for a use case
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
```

## Widget Testing

```dart
// Example widget test
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

## Integration Testing

Integration tests verify that different parts of the application work together as expected:

```dart
// Example integration test
testWidgets('User can log in and see projects', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Enter credentials
  await tester.enterText(find.byKey(Key('email-field')), 'user@example.com');
  await tester.enterText(find.byKey(Key('password-field')), 'password');
  
  // Tap the login button
  await tester.tap(find.byKey(Key('login-button')));
  await tester.pumpAndSettle();
  
  // Verify navigation to projects screen
  expect(find.text('Projects'), findsOneWidget);
});
```

## Mock Dependencies

Mocks are created using the `mocktail` package:

```dart
class MockAuthRepository extends Mock implements AuthRepository {}
```

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/domain/usecases/sign_in_use_case_test.dart
```

## Test Coverage

Aim for high test coverage, especially in:
- Domain layer (Entities, Use Cases)
- Application layer (BLoCs/Cubits)
- Infrastructure layer (Repository implementations)

Monitor coverage using:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Best Practices

1. **Use AAA pattern**: Arrange, Act, Assert
2. **Test edge cases**: Handle errors, empty states, boundary values
3. **Keep tests independent**: Tests should not depend on each other
4. **Mock external dependencies**: API calls, databases, current time
5. **Focus on behavior**: Test what the code does, not how it's implemented
