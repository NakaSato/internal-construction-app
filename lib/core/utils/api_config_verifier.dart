import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/environment_config.dart';

/// Simple utility to verify API configuration
class ApiConfigVerifier {
  static void verifyConfiguration() {
    // Only show configuration details in debug mode
    if (kDebugMode) {
      debugPrint('🔧 API Configuration Verification');
      debugPrint('================================');

      // Check .env file loading
      debugPrint('📁 .env file status:');
      debugPrint(
        '  - API_BASE_URL: ${dotenv.env['API_BASE_URL'] ?? 'NOT SET'}',
      );
      debugPrint('  - DEBUG_MODE: ${dotenv.env['DEBUG_MODE'] ?? 'NOT SET'}');

      // Check EnvironmentConfig
      debugPrint('\n🌍 Environment Configuration:');
      debugPrint(
        '  - Current Environment: ${EnvironmentConfig.currentEnvironment}',
      );
      debugPrint('  - Is Development: ${EnvironmentConfig.isDevelopment}');
      debugPrint('  - API Base URL: ${EnvironmentConfig.apiBaseUrl}');
      debugPrint(
        '  - Debug Mode Enabled: ${EnvironmentConfig.enableDebugMode}',
      );

      // Validate URL format
      final apiUrl = EnvironmentConfig.apiBaseUrl;
      if (apiUrl.startsWith('http://localhost:8080')) {
        debugPrint('\n✅ API URL is correctly configured for localhost:8080');
      } else {
        debugPrint('\n⚠️  API URL might not be correctly configured');
        debugPrint('   Expected: http://localhost:8080');
        debugPrint('   Actual: $apiUrl');
      }

      debugPrint('================================\n');
    }
  }

  static Map<String, dynamic> getConfigSummary() {
    return {
      'envFileLoaded': dotenv.isEveryDefined(['API_BASE_URL']),
      'apiBaseUrl': EnvironmentConfig.apiBaseUrl,
      'environment': EnvironmentConfig.currentEnvironment.toString(),
      'debugMode': EnvironmentConfig.enableDebugMode,
      'isCorrectHost': EnvironmentConfig.apiBaseUrl.contains('localhost:8080'),
    };
  }
}
