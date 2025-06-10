import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'core/config/environment_config.dart';
import 'core/di/injection.dart';

/// Simple test app to verify API configuration
class TestApiConfigApp extends StatelessWidget {
  const TestApiConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Config Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('API Configuration Test')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Environment Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Environment: ${EnvironmentConfig.currentEnvironment}',
                      ),
                      Text(
                        'Is Development: ${EnvironmentConfig.isDevelopment}',
                      ),
                      Text('Debug Mode: ${EnvironmentConfig.enableDebugMode}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'API Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'API Base URL (EnvironmentConfig): ${EnvironmentConfig.apiBaseUrl}',
                      ),
                      Text(
                        'API Base URL (.env): ${dotenv.env['API_BASE_URL'] ?? 'Not set'}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dependency Injection Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('GetIt ready: ${getIt.isReady}'),
                      Text('Has Dio: ${getIt.isRegistered<Dio>()}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Test entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Configure dependencies
  configureDependencies();

  runApp(const TestApiConfigApp());
}
