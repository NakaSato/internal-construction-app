/// Environment configuration for different build environments
enum Environment { development, staging, production }

class EnvironmentConfig {
  static const Environment _currentEnvironment = Environment.development;

  static Environment get currentEnvironment => _currentEnvironment;

  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  static bool get isProduction => _currentEnvironment == Environment.production;

  // API Configuration
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return const String.fromEnvironment(
          'DEV_API_URL',
          defaultValue: 'https://dev-api.example.com',
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

  // Firebase Configuration
  static String get firebaseProjectId {
    switch (_currentEnvironment) {
      case Environment.development:
        return const String.fromEnvironment(
          'DEV_FIREBASE_PROJECT_ID',
          defaultValue: 'flutter-app-dev',
        );
      case Environment.staging:
        return const String.fromEnvironment(
          'STAGING_FIREBASE_PROJECT_ID',
          defaultValue: 'flutter-app-staging',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'PROD_FIREBASE_PROJECT_ID',
          defaultValue: 'flutter-app-prod',
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
