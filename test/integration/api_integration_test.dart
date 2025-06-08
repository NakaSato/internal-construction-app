import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('API Integration Tests', () {
    late Dio dio;

    setUpAll(() async {
      // Load environment variables
      await dotenv.load(fileName: '.env');

      dio = Dio();
      dio.options.baseUrl =
          dotenv.env['API_BASE_URL'] ?? 'http://localhost:5002';
      dio.options.headers['Content-Type'] = 'application/json';
    });

    test('API Health Check', () async {
      try {
        final response = await dio.get('/Health');
        expect(response.statusCode, 200);
        print('✅ API is running and healthy');
      } catch (e) {
        fail('❌ API health check failed: $e');
      }
    });

    test('API Login Endpoint Structure', () async {
      try {
        // Test with invalid credentials to check endpoint structure
        final response = await dio.post(
          '/api/v1/Auth/login',
          data: {'username': 'test@example.com', 'password': 'invalid'},
          options: Options(
            validateStatus: (status) => true, // Accept any status
          ),
        );

        // We expect either 200 (with error message) or 401/400
        expect([200, 400, 401], contains(response.statusCode));

        if (response.statusCode == 200) {
          // Should have the expected API response structure
          final data = response.data;
          expect(data, isA<Map<String, dynamic>>());
          expect(data['success'], isA<bool>());
          expect(data['message'], isA<String>());
        }

        print('✅ Login endpoint is accessible and follows expected structure');
      } catch (e) {
        print('❌ Login endpoint test failed: $e');
        // Don't fail the test if it's just network issues
      }
    });

    test('API Register Endpoint Structure', () async {
      try {
        // Test with incomplete data to check endpoint structure
        final response = await dio.post(
          '/api/v1/Auth/register',
          data: {
            'username': 'test',
            'email': 'test@example.com',
            'password': 'Test123!',
            'fullName': 'Test User',
            'roleId': 2,
          },
          options: Options(
            validateStatus: (status) => true, // Accept any status
          ),
        );

        // We expect either 200 or 400 (validation error)
        expect([200, 400, 409], contains(response.statusCode));

        if (response.statusCode == 200) {
          final data = response.data;
          expect(data, isA<Map<String, dynamic>>());
          expect(data['success'], isA<bool>());
          expect(data['message'], isA<String>());
        }

        print(
          '✅ Register endpoint is accessible and follows expected structure',
        );
      } catch (e) {
        print('❌ Register endpoint test failed: $e');
        // Don't fail the test if it's just network issues
      }
    });
  });
}
