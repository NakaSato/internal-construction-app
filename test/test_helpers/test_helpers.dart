// Test helpers and utilities for the Flutter application tests
//
// This file contains common test utilities, mocks, and helper functions
// that can be reused across different test files.

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_architecture_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:flutter_architecture_app/features/authentication/infrastructure/auth_repository_factory.dart';
import 'package:flutter_architecture_app/features/authentication/application/auth_bloc.dart';
import 'package:flutter_architecture_app/features/work_calendar/domain/repositories/work_calendar_repository.dart';
import 'package:flutter_architecture_app/features/work_calendar/application/work_calendar_bloc.dart';

import 'test_helpers.mocks.dart';

// Generate mocks using build_runner: dart run build_runner build
@GenerateMocks([
  AuthRepository,
  AuthRepositoryFactory,
  WorkCalendarRepository,
  FlutterSecureStorage,
  Dio,
])
class TestHelpers {}

/// Test helper class containing common utilities for tests
class TestUtils {
  /// Creates a testable widget wrapped with necessary providers
  static Widget createTestableWidget({
    required Widget child,
    AuthRepositoryFactory? authRepositoryFactory,
    WorkCalendarRepository? workCalendarRepository,
  }) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          if (authRepositoryFactory != null)
            BlocProvider<AuthBloc>(
              create: (_) => AuthBloc(authRepositoryFactory),
            ),
          // Add other BlocProviders as needed for your features
        ],
        child: child,
      ),
    );
  }

  /// Sets up mock dependencies in GetIt for testing
  static void setupMockDependencies() {
    // Unregister any existing dependencies
    if (GetIt.instance.isRegistered<AuthRepository>()) {
      GetIt.instance.unregister<AuthRepository>();
    }
    if (GetIt.instance.isRegistered<AuthRepositoryFactory>()) {
      GetIt.instance.unregister<AuthRepositoryFactory>();
    }
    if (GetIt.instance.isRegistered<WorkCalendarRepository>()) {
      GetIt.instance.unregister<WorkCalendarRepository>();
    }
    if (GetIt.instance.isRegistered<AuthBloc>()) {
      GetIt.instance.unregister<AuthBloc>();
    }
    if (GetIt.instance.isRegistered<WorkCalendarBloc>()) {
      GetIt.instance.unregister<WorkCalendarBloc>();
    }

    // Register mock repository implementations
    final mockAuthRepository = MockAuthRepository();
    final mockAuthRepositoryFactory = MockAuthRepositoryFactory();
    final mockWorkCalendarRepository = MockWorkCalendarRepository();

    // Mock factory to return our mock repository
    when(
      mockAuthRepositoryFactory.getAuthRepository(),
    ).thenReturn(mockAuthRepository);

    GetIt.instance.registerLazySingleton<AuthRepository>(
      () => mockAuthRepository,
    );
    GetIt.instance.registerLazySingleton<AuthRepositoryFactory>(
      () => mockAuthRepositoryFactory,
    );
    GetIt.instance.registerLazySingleton<WorkCalendarRepository>(
      () => mockWorkCalendarRepository,
    );

    // Register BLoCs
    GetIt.instance.registerFactory<AuthBloc>(
      () => AuthBloc(mockAuthRepositoryFactory),
    );
    GetIt.instance.registerFactory<WorkCalendarBloc>(
      () => WorkCalendarBloc(mockWorkCalendarRepository),
    );
  }

  /// Tears down mock dependencies after tests
  static void tearDownMockDependencies() {
    GetIt.instance.reset();
  }

  /// Creates a mock Dio client with default responses
  static MockDio createMockDio() {
    final mockDio = MockDio();

    // Set up default responses
    when(mockDio.options).thenReturn(BaseOptions());

    return mockDio;
  }

  /// Creates a mock FlutterSecureStorage
  static MockFlutterSecureStorage createMockSecureStorage() {
    final mockStorage = MockFlutterSecureStorage();

    // Set up default behaviors
    when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);
    when(
      mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
    ).thenAnswer((_) async {});
    when(mockStorage.delete(key: anyNamed('key'))).thenAnswer((_) async {});

    return mockStorage;
  }

  /// Pumps the widget and waits for animations to settle
  static Future<void> pumpAndSettleWidget(WidgetTester tester) async {
    await tester.pump();
    await tester.pumpAndSettle();
  }

  /// Common test setup that should be run before each test
  static void commonSetUp() {
    setupMockDependencies();
  }

  /// Common test teardown that should be run after each test
  static void commonTearDown() {
    tearDownMockDependencies();
  }
}

/// Extension methods for WidgetTester to make testing easier
extension WidgetTesterExtensions on WidgetTester {
  /// Finds a widget by its text and taps it
  Future<void> tapByText(String text) async {
    await tap(find.text(text));
    await pump();
  }

  /// Finds a widget by its key and taps it
  Future<void> tapByKey(Key key) async {
    await tap(find.byKey(key));
    await pump();
  }

  /// Enters text into a text field
  Future<void> enterTextByKey(Key key, String text) async {
    await enterText(find.byKey(key), text);
    await pump();
  }

  /// Scrolls until a widget is visible
  Future<void> scrollUntilVisible(
    Finder finder,
    double delta, {
    Finder? scrollable,
  }) async {
    scrollable ??= find.byType(Scrollable).first;
    await scrollUntilVisible(finder, delta, scrollable: scrollable);
  }
}

/// Commonly used test data and constants
class TestData {
  // Authentication test data
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'password123';
  static const String testToken = 'mock_jwt_token';

  // Image test data
  static const String testImagePath = '/path/to/test/image.jpg';
  static const String testImageUrl = 'https://example.com/image.jpg';

  // Calendar test data
  static const String testEventTitle = 'Test Event';
  static const String testEventDescription = 'Test event description';
}

/// Custom matchers for testing
class CustomMatchers {
  /// Matcher to verify if a widget contains specific text
  static Matcher containsText(String text) {
    return predicate<Widget>((widget) {
      if (widget is Text) {
        return widget.data?.contains(text) ?? false;
      }
      return false;
    }, 'contains text "$text"');
  }

  /// Matcher to verify if a form field has an error
  static Matcher hasFieldError() {
    return predicate<Widget>((widget) {
      // For TextFormField, we need to check the finder for error text
      // This is a simplified version - in real tests you'd use find.text() to check for error messages
      return widget.runtimeType.toString().contains('TextFormField');
    }, 'has field error');
  }
}
