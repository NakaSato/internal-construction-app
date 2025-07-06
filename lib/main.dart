import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// App and core dependencies
import 'app.dart';
import 'core/di/injection.dart';
import 'core/utils/api_config_verifier.dart';
import 'core/services/universal_realtime_handler.dart';

// Common utilities
import 'common/utils/utils.dart';

/// Application entry point.
///
/// This function is responsible for:
/// - Initializing Flutter framework bindings
/// - Configuring system UI and device orientation
/// - Setting up dependency injection
/// - Verifying API configuration
/// - Initializing comprehensive real-time updates system
/// - Global error handling setup
/// - Starting the application
void main() async {
  // Constants for better code organization
  const List<DeviceOrientation> supportedOrientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  // Ensure Flutter framework is properly initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI and device orientation
  await _configureSystemUI(supportedOrientations);

  // Set up global error handling
  _setupErrorHandling();

  try {
    // Initialize dependency injection container
    await _initializeDependencies();

    // Verify API configuration in development builds
    await _verifyApiConfiguration();

    // Initialize real-time updates system
    await _initializeRealtimeUpdates();

    // Start the application
    runApp(const ConstructionApp());
  } catch (error, stackTrace) {
    _handleCriticalError(error, stackTrace);
  }
}

/// Configures system UI settings and device orientation.
Future<void> _configureSystemUI(List<DeviceOrientation> orientations) async {
  // Set preferred device orientations
  await SystemChrome.setPreferredOrientations(orientations);

  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

/// Sets up global error handling for Flutter and Dart errors.
void _setupErrorHandling() {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    LogUtils.logError('FLUTTER', details.exception, details.stack);
  };

  // Handle async errors that escape the Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    LogUtils.logError('PLATFORM', error, stack);
    return true;
  };
}

/// Initializes the dependency injection container with proper error handling.
Future<void> _initializeDependencies() async {
  try {
    await initializeDependencies();
    LogUtils.logSuccess('MAIN', 'Dependency injection initialized successfully');
  } catch (error, stackTrace) {
    LogUtils.logError('MAIN', error, stackTrace);
    rethrow;
  }
}

/// Verifies API configuration in development builds.
Future<void> _verifyApiConfiguration() async {
  if (kDebugMode) {
    try {
      ApiConfigVerifier.verifyConfiguration();
      LogUtils.logSuccess('API_CONFIG', 'API configuration verified successfully');
    } catch (error) {
      LogUtils.logWarning('API_CONFIG', 'API configuration verification failed: $error');
      // Don't rethrow as this is not critical for app startup
    }
  }
}

/// Initializes the comprehensive real-time updates system.
Future<void> _initializeRealtimeUpdates() async {
  try {
    final realtimeHandler = getIt<UniversalRealtimeHandler>();
    await realtimeHandler.initialize();
    LogUtils.logSuccess('REALTIME', 'Comprehensive real-time updates initialized successfully');
  } catch (error) {
    LogUtils.logWarning('REALTIME', 'Failed to initialize real-time updates: $error');
    // App can still function without real-time updates, so don't rethrow
  }
}

/// Handles critical errors that prevent app startup.
void _handleCriticalError(Object error, StackTrace? stackTrace) {
  const String criticalErrorTitle = 'Unable to start the application';
  const String debugErrorSuffix = 'Please try again later';
  const double iconSize = 64.0;
  const double verticalSpacing = 16.0;
  const double smallVerticalSpacing = 8.0;
  const double titleFontSize = 18.0;
  const double descriptionFontSize = 14.0;

  LogUtils.logCritical('STARTUP', 'Critical startup error', error, stackTrace);

  // In production, you might want to show a user-friendly error screen
  // or send the error to a crash reporting service
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: iconSize, color: Colors.red),
              const SizedBox(height: verticalSpacing),
              const Text(
                criticalErrorTitle,
                style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: smallVerticalSpacing),
              Text(
                kDebugMode ? error.toString() : debugErrorSuffix,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: descriptionFontSize),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
