import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for different build environments
enum Environment { development, production }

class EnvironmentConfig {
  /// Gets the current environment from .env file or falls back to development
  static Environment get currentEnvironment {
    final envString = dotenv.env['API_ENVIRONMENT']?.toLowerCase();

    // Log the environment mapping in debug mode
    if (kDebugMode) {
      debugPrint('🌍 Environment Mapping:');
      debugPrint(
        '  - API_ENVIRONMENT from .env: ${dotenv.env['API_ENVIRONMENT'] ?? 'NOT SET'}',
      );
      debugPrint('  - Normalized value: ${envString ?? 'null'}');
    }

    final environment = switch (envString) {
      'production' || 'prod' => Environment.production,
      'development' || 'dev' || 'local' => Environment.development,
      _ => Environment.development,
    };

    if (kDebugMode) {
      debugPrint('  - Mapped to: $environment');
      debugPrint(
        '  - Using ${environment == Environment.development ? 'DEVELOPMENT' : 'PRODUCTION'} configuration',
      );
    }

    return environment;
  }

  static bool get isDevelopment =>
      currentEnvironment == Environment.development;
  static bool get isProduction => currentEnvironment == Environment.production;

  // API Configuration - Now reads from .env file
  static String get apiBaseUrl {
    // First try to get from .env file
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('🌐 Using API_BASE_URL from .env: $envUrl');
      }
      return envUrl;
    }

    // Fallback to compile-time environment variables
    final fallbackUrl = switch (currentEnvironment) {
      Environment.development => const String.fromEnvironment(
        'DEV_API_URL',
        defaultValue: 'http://localhost:8080',
      ),
      Environment.production => const String.fromEnvironment(
        'PROD_API_URL',
        defaultValue: 'https://api.example.com',
      ),
    };

    if (kDebugMode) {
      debugPrint(
        '🌐 Using fallback API URL for ${currentEnvironment.name}: $fallbackUrl',
      );
    }

    return fallbackUrl;
  }

  // Feature Flags
  static bool get enableDebugMode => isDevelopment;
  static bool get enableAnalytics => isProduction;
  static bool get enableCrashReporting => !isDevelopment;

  // Private constructor to prevent instantiation
  EnvironmentConfig._();
}
