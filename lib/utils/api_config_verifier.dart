import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/config/environment_config.dart';

/// Simple utility to verify API configuration
class ApiConfigVerifier {
  static void verifyConfiguration() {
    print('🔧 API Configuration Verification');
    print('================================');

    // Check .env file loading
    print('📁 .env file status:');
    print('  - API_BASE_URL: ${dotenv.env['API_BASE_URL'] ?? 'NOT SET'}');
    print('  - DEBUG_MODE: ${dotenv.env['DEBUG_MODE'] ?? 'NOT SET'}');

    // Check EnvironmentConfig
    print('\n🌍 Environment Configuration:');
    print('  - Current Environment: ${EnvironmentConfig.currentEnvironment}');
    print('  - Is Development: ${EnvironmentConfig.isDevelopment}');
    print('  - API Base URL: ${EnvironmentConfig.apiBaseUrl}');
    print('  - Debug Mode Enabled: ${EnvironmentConfig.enableDebugMode}');

    // Validate URL format
    final apiUrl = EnvironmentConfig.apiBaseUrl;
    if (apiUrl.startsWith('http://localhost:5002')) {
      print('\n✅ API URL is correctly configured for localhost:5002');
    } else {
      print('\n⚠️  API URL might not be correctly configured');
      print('   Expected: http://localhost:5002');
      print('   Actual: $apiUrl');
    }

    print('================================\n');
  }

  static Map<String, dynamic> getConfigSummary() {
    return {
      'envFileLoaded': dotenv.isEveryDefined(['API_BASE_URL']),
      'apiBaseUrl': EnvironmentConfig.apiBaseUrl,
      'environment': EnvironmentConfig.currentEnvironment.toString(),
      'debugMode': EnvironmentConfig.enableDebugMode,
      'isCorrectHost': EnvironmentConfig.apiBaseUrl.contains('localhost:5002'),
    };
  }
}
