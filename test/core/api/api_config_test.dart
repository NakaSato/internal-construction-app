import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../lib/core/api/api_config.dart';

void main() {
  group('API Environment Configuration Tests', () {
    setUpAll(() async {
      // Load test environment variables
      await dotenv.load(fileName: ".env");
      ApiConfig.initializeEnvironment();
    });

    test('should initialize with correct environment from .env', () {
      // Should read from .env file: API_ENVIRONMENT=production
      expect(ApiConfig.currentEnvironment, equals(ApiEnvironment.production));
    });

    test('should use production URL by default', () {
      final url = ApiConfig.configuredBaseUrl;
      expect(url, equals('https://solar-projects-api.azurewebsites.net'));
    });

    test('should allow environment switching', () {
      // Test switching to development
      ApiConfig.setEnvironment(ApiEnvironment.development);
      expect(ApiConfig.currentEnvironment, equals(ApiEnvironment.development));
      expect(ApiConfig.isDevelopment, isTrue);
      expect(ApiConfig.isProduction, isFalse);

      // Test switching back to production
      ApiConfig.setEnvironment(ApiEnvironment.production);
      expect(ApiConfig.currentEnvironment, equals(ApiEnvironment.production));
      expect(ApiConfig.isProduction, isTrue);
    });

    test('should return correct environment URLs', () {
      expect(
        ApiConfig.getEnvironmentUrl(ApiEnvironment.development),
        equals('https://dev-solar-projects-api.azurewebsites.net'),
      );
      expect(
        ApiConfig.getEnvironmentUrl(ApiEnvironment.production),
        equals('https://solar-projects-api.azurewebsites.net'),
      );
      expect(
        ApiConfig.getEnvironmentUrl(ApiEnvironment.local),
        equals('http://localhost:3000'),
      );
    });

    test('should build correct full URLs', () {
      ApiConfig.setEnvironment(ApiEnvironment.production);
      final fullUrl = ApiConfig.fullUrl('/api/v1/auth/login');
      expect(
        fullUrl,
        equals(
          'https://solar-projects-api.azurewebsites.net/api/v1/auth/login',
        ),
      );
    });

    test('should build endpoints with parameters', () {
      final endpoint = ApiConfig.buildEndpoint('/api/v1/projects/{id}/tasks', {
        'id': '123',
      });
      expect(endpoint, equals('/api/v1/projects/123/tasks'));
    });

    test('should provide environment display names', () {
      final displayNames = ApiConfig.environmentDisplayNames;
      expect(displayNames[ApiEnvironment.development], equals('Development'));
      expect(displayNames[ApiEnvironment.production], equals('Production'));
      expect(displayNames[ApiEnvironment.local], equals('Local Development'));
    });

    test('should provide config summary', () {
      ApiConfig.setEnvironment(ApiEnvironment.development);
      final summary = ApiConfig.configSummary;

      expect(summary['environment'], equals('Development'));
      expect(summary['isDevelopment'], isTrue);
      expect(summary['isProduction'], isFalse);
      expect(summary['baseUrl'], isNotEmpty);
    });
  });
}
