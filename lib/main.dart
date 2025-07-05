import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/utils/api_config_verifier.dart';
import 'core/services/universal_realtime_handler.dart';

/// Application entry point.
///
/// This function is responsible for:
/// - Initializing Flutter framework bindings
/// - Setting up dependency injection
/// - Verifying API configuration
/// - Initializing comprehensive real-time updates system
/// - Starting the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection container
  await initializeDependencies();

  // Verify API configuration in development
  ApiConfigVerifier.verifyConfiguration();

  // Initialize comprehensive real-time updates for all API endpoints
  try {
    final realtimeHandler = getIt<UniversalRealtimeHandler>();
    await realtimeHandler.initialize();
    debugPrint('✅ Comprehensive real-time updates initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Failed to initialize real-time updates: $e');
    // App can still function without real-time updates
  }

  // Start the application
  runApp(const ConstructionApp());
}
