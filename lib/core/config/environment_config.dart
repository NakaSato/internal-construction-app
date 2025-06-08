import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for different build environments
enum Environment { development, staging, production }

class EnvironmentConfig {
  static const Environment _currentEnvironment = Environment.development;

  static Environment get currentEnvironment => _currentEnvironment;

  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  static bool get isProduction => _currentEnvironment == Environment.production;

  // API Configuration - Now reads from .env file
  static String get apiBaseUrl {
    // First try to get from .env file
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }

    // Fallback to compile-time environment variables
    switch (_currentEnvironment) {
      case Environment.development:
        return const String.fromEnvironment(
          'DEV_API_URL',
          defaultValue: 'http://localhost:5002',
        );
      case Environment.staging:
        return const String.fromEnvironment(
          'STAGING_API_URL',
          defaultValue: 'https://staging-api.example.com',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'PROD_API_URL',
          defaultValue: 'https://api.example.com',
        );
    }
  }

  // Feature Flags
  static bool get enableDebugMode => isDevelopment;
  static bool get enableAnalytics => isProduction;
  static bool get enableCrashReporting => !isDevelopment;

  // Private constructor to prevent instantiation
  EnvironmentConfig._();
}
