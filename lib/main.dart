import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/utils/api_config_verifier.dart';

/// Application entry point.
///
/// This function is responsible for:
/// - Initializing Flutter framework bindings
/// - Setting up dependency injection
/// - Verifying API configuration
/// - Starting the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection container
  await initializeDependencies();

  // Verify API configuration in development
  ApiConfigVerifier.verifyConfiguration();

  // Start the application
  runApp(const ConstructionApp());
}
