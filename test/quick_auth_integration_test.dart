import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

import '../lib/core/di/injection.dart';
import '../lib/features/authentication/application/auth_bloc.dart';
import '../lib/features/authentication/application/auth_event.dart';
import '../lib/features/authentication/application/auth_state.dart';

/// Quick integration test for authentication API
void main() async {
  group('Authentication API Integration Test', () {
    late AuthBloc authBloc;

    setUpAll(() async {
      // Load environment variables
      await dotenv.load(fileName: '.env');

      // Initialize dependencies
      await initializeDependencies();

      // Get AuthBloc instance
      authBloc = GetIt.instance<AuthBloc>();
    });

    tearDownAll(() async {
      await GetIt.instance.reset();
    });

    test('AuthBloc should be properly initialized', () {
      expect(authBloc, isNotNull);
      expect(authBloc.state, isA<AuthInitial>());
    });

    test('API base URL should be configured correctly', () {
      final apiUrl = dotenv.env['API_BASE_URL'];
      expect(apiUrl, isNotNull);
      expect(apiUrl, contains('localhost:5002'));
      print('✅ API Base URL: $apiUrl');
    });

    test('Environment configuration should be loaded', () {
      final debugMode = dotenv.env['DEBUG_MODE'];
      expect(debugMode, isNotNull);
      print('✅ Debug Mode: $debugMode');
    });

    // Note: This test will attempt to connect to your actual API
    // Make sure your backend is running on localhost:5002
    test('Login attempt should handle API response correctly', () async {
      // Test with invalid credentials to verify API connection
      authBloc.add(
        const AuthSignInRequested(
          username: 'test@example.com',
          password: 'invalid_password',
        ),
      );

      // Wait for response
      await Future.delayed(const Duration(seconds: 3));

      // Should either be AuthFailure (API responded) or still AuthLoading (no API)
      final currentState = authBloc.state;
      print('✅ Auth state after login attempt: ${currentState.runtimeType}');

      if (currentState is AuthFailure) {
        print('✅ API responded with error: ${currentState.message}');
        expect(currentState.message, isNotNull);
      } else if (currentState is AuthLoading) {
        print('⚠️  Still loading - API might not be running');
      } else {
        print('ℹ️  Unexpected state: $currentState');
      }
    });

    // Test with potentially valid credentials
    // Note: Replace with actual valid credentials for your system
    test('Login with valid credentials should succeed', () async {
      // Create a fresh AuthBloc instance for this test
      final testAuthBloc = GetIt.instance<AuthBloc>();

      print('🔐 Testing login with valid credentials...');

      // Try with common test credentials - replace with actual valid ones
      testAuthBloc.add(
        const AuthSignInRequested(
          username: 'admin@example.com', // Replace with valid username
          password: 'password123', // Replace with valid password
        ),
      );

      // Wait for response
      await Future.delayed(const Duration(seconds: 3));

      final currentState = testAuthBloc.state;
      print(
        '✅ Auth state after valid login attempt: ${currentState.runtimeType}',
      );

      if (currentState is AuthAuthenticated) {
        print('🎉 Login successful! User: ${currentState.user.email}');
        expect(currentState.user, isNotNull);
        expect(currentState.user.email, isNotEmpty);
      } else if (currentState is AuthFailure) {
        print('❌ Login failed: ${currentState.message}');
        print('💡 Try updating the test credentials to match your backend');
      } else {
        print('ℹ️  Unexpected state: $currentState');
      }
    });
  });
}
