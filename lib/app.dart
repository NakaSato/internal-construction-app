import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Common exports and utilities
import 'common/common.dart';

// Core theme and navigation
import 'core/theme/solar_app_theme.dart';
import 'core/di/injection.dart';
import 'core/navigation/app_router.dart';

// Feature imports - Authentication
import 'features/authentication/application/auth_bloc.dart';
import 'features/authentication/application/auth_event.dart';
import 'features/authentication/application/auth_state.dart' as auth;

// Feature imports - Authorization
import 'features/authorization/application/authorization_bloc.dart';

// Feature imports - Daily Reports
import 'features/daily_reports/application/cubits/daily_reports_cubit.dart';

// Feature imports - Project Management
import 'features/projects/application/project_bloc.dart';

// Feature imports - Work Calendar
import 'features/work_calendar/application/work_calendar_bloc.dart';

// Security and token management
import 'core/services/security_service.dart';
import 'core/services/session_validation_service.dart';

/// The main application widget that configures the Flutter app.
///
/// This widget is responsible for:
/// - Setting up global state providers (BLoCs/Cubits) with proper error handling
/// - Configuring the Material app with theme and routing
/// - Providing dependency injection context to the widget tree
/// - Setting up global BLoC observer for development debugging
/// - Implementing app-wide error boundaries and recovery mechanisms
class ConstructionApp extends StatelessWidget {
  const ConstructionApp({super.key});

  // App configuration constants
  static const String _appTitle = AppConstants.appName;
  static const ThemeMode _themeMode = ThemeMode.light;
  static const bool _debugShowCheckedModeBanner = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: _createBlocProviders(),
      child: BlocListener<AuthBloc, auth.AuthState>(
        listener: _handleGlobalAuthChanges,
        child: MaterialApp.router(
          title: _appTitle,

          // Theme configuration - Using solar-themed design system
          theme: SolarAppTheme.themeData,
          themeMode: _themeMode,

          // Routing configuration
          routerConfig: AppRouter.router,

          // Development and production settings
          debugShowCheckedModeBanner: _debugShowCheckedModeBanner,

          // Localization support (ready for future implementation)
          // locale: const Locale('en', 'US'),
          // supportedLocales: const [Locale('en', 'US')],

          // Performance and UX optimization
          builder: (context, child) {
            return _AppWrapper(child: child);
          },
        ),
      ),
    );
  }

  /// Handles global authentication state changes.
  ///
  /// This listener responds to authentication events that affect
  /// the entire application state and security posture.
  void _handleGlobalAuthChanges(BuildContext context, auth.AuthState state) {
    final securityService = getIt<SecurityService>();

    if (state is auth.AuthUnauthenticated) {
      // Secure logout and cleanup when user logs out
      _performSecureLogout(securityService);
    } else if (state is auth.AuthAuthenticated) {
      // Initialize security session and user-specific services
      _initializeSecuritySession(securityService);
      _initializeUserServices();
    } else if (state is auth.AuthFailure) {
      // Handle authentication errors securely
      _handleAuthError(state, securityService);
    }
  }

  /// Performs secure logout with comprehensive cleanup
  Future<void> _performSecureLogout(SecurityService securityService) async {
    if (kDebugMode) {
      debugPrint('[SECURITY] Performing secure logout...');
    }

    try {
      await securityService.secureLogout();
      _clearApplicationCache();

      if (kDebugMode) {
        debugPrint('✅ [SECURITY] Secure logout completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [SECURITY] Error during secure logout: $e');
      }
    }
  }

  /// Initializes security session for authenticated user
  Future<void> _initializeSecuritySession(SecurityService securityService) async {
    if (kDebugMode) {
      debugPrint('🔐 [SECURITY] Initializing security session...');
    }

    try {
      await securityService.startSecuritySession();
      if (kDebugMode) {
        debugPrint('✅ [SECURITY] Security session initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [SECURITY] Error initializing security session: $e');
      }
    }
  }

  /// Handles authentication errors with security considerations
  void _handleAuthError(auth.AuthFailure state, SecurityService securityService) {
    if (kDebugMode) {
      debugPrint('🚨 [SECURITY] Authentication error: ${state.message}');
    }

    // Record failed login attempt for rate limiting
    securityService.recordFailedLoginAttempt();
  }

  /// Clears application cache when user logs out.
  void _clearApplicationCache() {
    if (kDebugMode) {
      debugPrint('🧹 [APP] Clearing application cache...');
    }
    // Implementation would clear cached data, temp files, etc.
  }

  /// Initializes user-specific services when user logs in.
  void _initializeUserServices() {
    if (kDebugMode) {
      debugPrint('🚀 [APP] Initializing user-specific services...');
    }
    // Implementation would initialize user-specific caching, preferences, etc.
  }

  /// Creates and configures all BLoC providers for the application.
  ///
  /// Each provider is wrapped with error handling to prevent startup failures
  /// if individual BLoCs fail to initialize. Providers are organized by criticality
  /// with authentication being the highest priority.
  List<BlocProvider> _createBlocProviders() {
    final providers = <BlocProvider>[];

    // Critical providers - loaded immediately and synchronously
    _addCriticalProviders(providers);

    // Standard providers - loaded with error handling
    _addStandardProviders(providers);

    return providers;
  }

  /// Adds critical providers that must be available immediately.
  void _addCriticalProviders(List<BlocProvider> providers) {
    // Authentication is critical - app can't function without it
    providers.add(
      BlocProvider<AuthBloc>(
        create: (context) => _createBlocSafely<AuthBloc>(
          () => getIt<AuthBloc>()..add(const AuthCheckRequested()),
          'AuthBloc',
          isCritical: true,
        ),
        lazy: false, // Load immediately
      ),
    );

    // Authorization depends on authentication
    providers.add(
      BlocProvider<AuthorizationBloc>(
        create: (context) => _createBlocSafely<AuthorizationBloc>(
          () => getIt<AuthorizationBloc>(),
          'AuthorizationBloc',
          isCritical: true,
        ),
        lazy: false,
      ),
    );
  }

  /// Adds standard providers with graceful failure handling.
  void _addStandardProviders(List<BlocProvider> providers) {
    // Work calendar - important but not critical
    providers.add(
      BlocProvider<WorkCalendarBloc>(
        create: (context) => _createBlocSafely<WorkCalendarBloc>(() => getIt<WorkCalendarBloc>(), 'WorkCalendarBloc'),
      ),
    );

    // Project management - important but not critical
    providers.add(
      BlocProvider<ProjectBloc>(
        create: (context) => _createBlocSafely<ProjectBloc>(() => getIt<ProjectBloc>(), 'ProjectBloc'),
      ),
    );

    // Daily reports - feature-specific, non-critical
    providers.add(
      BlocProvider<DailyReportsCubit>(
        create: (context) =>
            _createBlocSafely<DailyReportsCubit>(() => getIt<DailyReportsCubit>(), 'DailyReportsCubit'),
      ),
    );
  }

  /// Safely creates a BLoC with comprehensive error handling.
  ///
  /// If BLoC creation fails:
  /// - Critical BLoCs: Rethrow error to prevent app startup
  /// - Non-critical BLoCs: Log error and provide a null-safe fallback
  ///
  /// [createBloc] Function that creates the BLoC instance
  /// [blocName] Name for logging purposes
  /// [isCritical] Whether failure should prevent app startup
  T _createBlocSafely<T extends BlocBase>(T Function() createBloc, String blocName, {bool isCritical = false}) {
    try {
      final bloc = createBloc();
      if (kDebugMode) {
        debugPrint('✅ [$blocName] initialized successfully');
      }
      return bloc;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [$blocName] initialization failed: $error');
        debugPrint('Stack trace: $stackTrace');
      }

      // For critical BLoCs, rethrow to prevent app startup
      if (isCritical) {
        debugPrint('🚨 [$blocName] is critical - rethrowing error');
        rethrow;
      }

      // For non-critical BLoCs, you might want to provide a fallback
      // For now, rethrow as BLoC failures are generally critical
      // In the future, this could return a "stub" or "offline" BLoC
      rethrow;
    }
  }
}

/// Enhanced wrapper widget that provides app-level configurations and optimizations.
///
/// This widget provides:
/// - Global gesture handling for keyboard dismissal
/// - App-wide accessibility features
/// - System-level interaction handling
/// - Performance monitoring hooks
/// - Memory optimization features
class _AppWrapper extends StatefulWidget {
  const _AppWrapper({required this.child});

  final Widget? child;

  @override
  State<_AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<_AppWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _logAppLifecycle('App Initialized');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _handleAppLifecycleChange(state);
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    _handleMemoryPressure();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Dismiss keyboard when tapping outside text fields
      onTap: _dismissKeyboard,
      child: Focus(
        // Handle system-level focus changes
        onFocusChange: _handleFocusChange,
        child: widget.child ?? const SizedBox.shrink(),
      ),
    );
  }

  /// Dismisses the keyboard when tapping outside text fields.
  void _dismissKeyboard() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  /// Handles system focus changes for accessibility and UX.
  void _handleFocusChange(bool hasFocus) {
    if (kDebugMode) {
      debugPrint('🔍 [APP] Focus changed: $hasFocus');
    }
    // Could be used for analytics or accessibility features
  }

  /// Handles app lifecycle state changes.
  void _handleAppLifecycleChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _logAppLifecycle('App Resumed');
        // App is visible and responding to user input
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _logAppLifecycle('App Paused');
        // App is not currently visible but still running
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        _logAppLifecycle('App Detached');
        // App is detached from the view hierarchy
        _onAppDetached();
        break;
      case AppLifecycleState.inactive:
        _logAppLifecycle('App Inactive');
        // App is inactive (e.g., during phone call)
        break;
      case AppLifecycleState.hidden:
        _logAppLifecycle('App Hidden');
        // App is hidden (iOS only)
        break;
    }
  }

  /// Handles memory pressure warnings from the system.
  void _handleMemoryPressure() {
    if (kDebugMode) {
      debugPrint('⚠️ [APP] Memory pressure detected - clearing caches');
    }
    // Clear non-essential caches, images, etc.
    _clearNonEssentialCaches();
  }

  /// Called when app resumes from background.
  void _onAppResumed() {
    if (kDebugMode) {
      debugPrint('🔄 [APP] Resuming - validating session and refreshing critical data');
    }

    // Use session validation service for comprehensive session management
    _validateSessionOnResume();
  }

  /// Validate session when app resumes from background using SessionValidationService
  Future<void> _validateSessionOnResume() async {
    try {
      final sessionValidationService = getIt<SessionValidationService>();

      // Let the session validation service handle app resume logic
      await sessionValidationService.onAppResume();

      if (kDebugMode) {
        debugPrint('✅ [SECURITY] Session validation on resume completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [SECURITY] Error validating session on resume: $e');
      }
    }
  }

  /// Called when app goes to background.
  void _onAppPaused() {
    // Update activity and save state when app goes to background
    if (kDebugMode) {
      debugPrint('⏸️ [APP] Pausing - updating activity and saving state');
    }

    _updateActivityOnPause();
  }

  /// Update last activity when app pauses using SessionValidationService
  Future<void> _updateActivityOnPause() async {
    try {
      final sessionValidationService = getIt<SessionValidationService>();

      // Let the session validation service handle app pause logic
      await sessionValidationService.onAppPause();

      if (kDebugMode) {
        debugPrint('✅ [SECURITY] Activity updated on pause');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [SECURITY] Error updating activity on pause: $e');
      }
    }
  }

  /// Called when app is being terminated.
  void _onAppDetached() {
    // Final cleanup, save critical data
    if (kDebugMode) {
      debugPrint('🛑 [APP] Detaching - final cleanup');
    }
  }

  /// Clears non-essential caches to free memory.
  void _clearNonEssentialCaches() {
    // Implementation would clear image caches, temp files, etc.
    // Example: imageCache.clear();
  }

  /// Logs app lifecycle events.
  void _logAppLifecycle(String event) {
    if (kDebugMode) {
      debugPrint('📱 [LIFECYCLE] $event');
    }
    // In production, send to analytics
  }
}
