import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment configuration reading from .env file only
/// All app configuration is managed through the .env file
enum Environment { development, production, local }

class EnvironmentConfig {
  // Private constructor to prevent instantiation
  EnvironmentConfig._();

  // =============================================================================
  // ENVIRONMENT DETECTION
  // =============================================================================

  /// Gets the current environment from .env file
  static Environment get currentEnvironment {
    final envString = dotenv.env['API_ENVIRONMENT']?.toLowerCase();

    if (kDebugMode) {
      debugPrint('🌍 Environment Configuration:');
      debugPrint('  - API_ENVIRONMENT: ${dotenv.env['API_ENVIRONMENT'] ?? 'NOT SET'}');
      debugPrint('  - Normalized: ${envString ?? 'null'}');
    }

    final environment = switch (envString) {
      'production' || 'prod' => Environment.production,
      'development' || 'dev' => Environment.development,
      'local' => Environment.local,
      _ => Environment.development, // Default fallback
    };

    if (kDebugMode) {
      debugPrint('  - Resolved to: $environment');
    }

    return environment;
  }

  static bool get isDevelopment => currentEnvironment == Environment.development;
  static bool get isProduction => currentEnvironment == Environment.production;
  static bool get isLocal => currentEnvironment == Environment.local;

  // =============================================================================
  // API CONFIGURATION
  // =============================================================================

  /// Primary API base URL from .env
  static String get apiBaseUrl {
    final url = dotenv.env['API_BASE_URL'] ?? _getEnvironmentSpecificUrl();

    if (kDebugMode) {
      debugPrint('🌐 API Configuration:');
      debugPrint('  - Base URL: $url');
    }

    return url;
  }

  /// Get environment-specific URL as fallback
  static String _getEnvironmentSpecificUrl() {
    return switch (currentEnvironment) {
      Environment.production => dotenv.env['API_BASE_URL_PRODUCTION'] ?? 'https://api-icms.gridtokenx.com',
      Environment.development => dotenv.env['API_BASE_URL_DEVELOPMENT'] ?? 'http://localhost:5001',
      Environment.local => dotenv.env['API_BASE_URL_LOCAL'] ?? 'http://localhost:5001',
    };
  }

  /// WebSocket URL configuration
  static String get websocketUrl {
    final wsUrl = dotenv.env['WEBSOCKET_URL'] ?? _getEnvironmentSpecificWebSocketUrl();

    if (kDebugMode) {
      debugPrint('🔌 WebSocket Configuration:');
      debugPrint('  - WebSocket URL: $wsUrl');
    }

    return wsUrl;
  }

  /// Get environment-specific WebSocket URL as fallback
  static String _getEnvironmentSpecificWebSocketUrl() {
    return switch (currentEnvironment) {
      Environment.production => dotenv.env['WEBSOCKET_URL_PRODUCTION'] ?? 'wss://api-icms.gridtokenx.com/notificationHub',
      Environment.development => dotenv.env['WEBSOCKET_URL_DEVELOPMENT'] ?? 'ws://localhost:5001/notificationHub',
      Environment.local => dotenv.env['WEBSOCKET_URL_LOCAL'] ?? 'ws://localhost:5001/notificationHub',
    };
  }

  /// API timeout configurations
  static int get connectTimeoutMs => int.tryParse(dotenv.env['API_CONNECT_TIMEOUT'] ?? '') ?? 30000;
  static int get receiveTimeoutMs => int.tryParse(dotenv.env['API_RECEIVE_TIMEOUT'] ?? '') ?? 30000;
  static int get sendTimeoutMs => int.tryParse(dotenv.env['API_SEND_TIMEOUT'] ?? '') ?? 30000;

  // =============================================================================
  // AUTHENTICATION CONFIGURATION
  // =============================================================================

  static int get jwtExpiryBufferMinutes => int.tryParse(dotenv.env['JWT_EXPIRY_BUFFER_MINUTES'] ?? '') ?? 5;
  static bool get authTokenRefreshEnabled => _getBoolValue('AUTH_TOKEN_REFRESH_ENABLED', true);

  // =============================================================================
  // DEBUG & DEVELOPMENT CONFIGURATION
  // =============================================================================

  static bool get debugMode => _getBoolValue('DEBUG_MODE', kDebugMode);
  static String get logLevel => dotenv.env['LOG_LEVEL'] ?? 'debug';
  static bool get enableApiLogging => _getBoolValue('ENABLE_API_LOGGING', kDebugMode);
  static bool get enableNetworkLogging => _getBoolValue('ENABLE_NETWORK_LOGGING', kDebugMode);

  // =============================================================================
  // FEATURE FLAGS
  // =============================================================================

  static bool get enableMockData => _getBoolValue('ENABLE_MOCK_DATA', false);
  static bool get enableOfflineMode => _getBoolValue('ENABLE_OFFLINE_MODE', false);
  static bool get enableAnalytics => _getBoolValue('ENABLE_ANALYTICS', isProduction);
  static bool get enableCrashReporting => _getBoolValue('ENABLE_CRASH_REPORTING', isProduction);

  // =============================================================================
  // UI/UX CONFIGURATION
  // =============================================================================

  static String get defaultTheme => dotenv.env['DEFAULT_THEME'] ?? 'light';
  static bool get enableDarkMode => _getBoolValue('ENABLE_DARK_MODE', true);
  static bool get enableSystemTheme => _getBoolValue('ENABLE_SYSTEM_THEME', true);
  static bool get enableAnimations => _getBoolValue('ENABLE_ANIMATIONS', true);
  static int get animationDurationMs => int.tryParse(dotenv.env['ANIMATION_DURATION_MS'] ?? '') ?? 300;

  // =============================================================================
  // DOCUMENTATION & SUPPORT URLS
  // =============================================================================

  static String get swaggerUrl => dotenv.env['SWAGGER_URL'] ?? 'http://localhost:5001/swagger/v1/swagger.json';
  static String get apiDocsUrl => dotenv.env['API_DOCS_URL'] ?? 'https://api-icms.gridtokenx.com/swagger';
  static String get supportEmail => dotenv.env['SUPPORT_EMAIL'] ?? 'support@gridtokenx.com';
  static String get termsUrl => dotenv.env['TERMS_URL'] ?? 'https://gridtokenx.com/terms';
  static String get privacyUrl => dotenv.env['PRIVACY_URL'] ?? 'https://gridtokenx.com/privacy';

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Helper method to parse boolean values from .env
  static bool _getBoolValue(String key, bool defaultValue) {
    final value = dotenv.env[key]?.toLowerCase();
    return switch (value) {
      'true' || '1' || 'yes' || 'on' => true,
      'false' || '0' || 'no' || 'off' => false,
      _ => defaultValue,
    };
  }

  /// Get all configuration as a map for debugging
  static Map<String, dynamic> getAllConfig() {
    return {
      'environment': {
        'current': currentEnvironment.name,
        'isDevelopment': isDevelopment,
        'isProduction': isProduction,
        'isLocal': isLocal,
      },
      'api': {
        'baseUrl': apiBaseUrl,
        'connectTimeoutMs': connectTimeoutMs,
        'receiveTimeoutMs': receiveTimeoutMs,
        'sendTimeoutMs': sendTimeoutMs,
      },
      'auth': {'jwtExpiryBufferMinutes': jwtExpiryBufferMinutes, 'tokenRefreshEnabled': authTokenRefreshEnabled},
      'debug': {
        'debugMode': debugMode,
        'logLevel': logLevel,
        'enableApiLogging': enableApiLogging,
        'enableNetworkLogging': enableNetworkLogging,
      },
      'features': {
        'enableMockData': enableMockData,
        'enableOfflineMode': enableOfflineMode,
        'enableAnalytics': enableAnalytics,
        'enableCrashReporting': enableCrashReporting,
      },
      'ui': {
        'defaultTheme': defaultTheme,
        'enableDarkMode': enableDarkMode,
        'enableSystemTheme': enableSystemTheme,
        'enableAnimations': enableAnimations,
        'animationDurationMs': animationDurationMs,
      },
      'urls': {
        'swagger': swaggerUrl,
        'apiDocs': apiDocsUrl,
        'support': supportEmail,
        'terms': termsUrl,
        'privacy': privacyUrl,
      },
    };
  }

  /// Print all configuration for debugging
  static void printAllConfig() {
    if (!kDebugMode) return;

    debugPrint('📋 Complete Environment Configuration:');
    final config = getAllConfig();
    config.forEach((category, values) {
      debugPrint('  $category:');
      if (values is Map<String, dynamic>) {
        values.forEach((key, value) {
          debugPrint('    $key: $value');
        });
      }
    });
  }
}
