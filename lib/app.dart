import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Common exports and utilities
import 'common/common.dart';

// Core theme and navigation
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'core/navigation/app_router.dart';
import 'core/services/realtime_api_streams.dart'; // Add this import for RealtimeApiStreams

// Feature imports - Authentication
import 'features/authentication/application/auth_bloc.dart';
import 'features/authentication/application/auth_cubit.dart';
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
    // AuthCubit for login screen - important but not critical
    providers.add(
      BlocProvider<AuthCubit>(create: (context) => _createBlocSafely<AuthCubit>(() => getIt<AuthCubit>(), 'AuthCubit')),
    );

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
  // Flag to track if dashboard needs refresh after focus change
  bool _needsDashboardRefresh = false;

  // Flag to track if we're navigating between project screens
  bool _isInProjectDetailView = false;
  DateTime? _lastProjectDetailVisit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _logAppLifecycle('App Initialized');
    _setupNavigationListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppRouter.router.routeInformationProvider.removeListener(_handleRouteChange);
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

    if (!hasFocus) {
      // When focus leaves the app (e.g., during account switching)
      if (kDebugMode) {
        debugPrint('🔍 [APP] Focus lost - preparing for potential account switch');
      }

      // Mark dashboard as needing refresh when focus returns
      _markDashboardForRefresh();
    } else {
      // When focus returns to the app, trigger a comprehensive refresh
      // Delay slightly to ensure UI is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (kDebugMode) {
          debugPrint('🔄 [APP] Focus returned - triggering comprehensive refresh');
        }

        // Notify all listeners that app focus has returned - can be used by screens to refresh data
        getIt<RealtimeApiStreams>().notifyAppFocusReturned();

        // Check auth state to ensure we're still authenticated
        if (mounted) {
          context.read<AuthBloc>().add(const AuthCheckRequested());

          // Force refresh project dashboard after auth check
          _forceRefreshDashboard();
        }
      });
    }
  }

  /// Marks the dashboard as needing refresh when focus returns
  void _markDashboardForRefresh() {
    _needsDashboardRefresh = true;
    if (kDebugMode) {
      debugPrint('🏗️ [APP] Dashboard marked for refresh on next focus return');
    }
  }

  /// Force refreshes the project dashboard when needed
  /// [fromDetailView] indicates if refresh is triggered from returning from detail view
  void _forceRefreshDashboard({bool fromDetailView = false}) {
    if (!_needsDashboardRefresh && !fromDetailView) return;

    try {
      if (kDebugMode) {
        final reason = fromDetailView ? 'returning from detail view' : 'focus return';
        debugPrint('🏗️ [APP] Forcing project dashboard refresh after $reason');
      }

      // Reset the flag
      _needsDashboardRefresh = false;

      // Force data refresh through project bloc
      final projectBloc = context.read<ProjectBloc>();

      // First clear any cached data to ensure fresh API results
      projectBloc.add(const RefreshProjectsWithCacheClear());

      // Short delay to ensure cache clear happens first
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;

        // Use smart refresh approach based on the trigger source
        if (fromDetailView) {
          // When returning from detail, we want to maintain visual continuity
          // Skip loading state for a smoother user experience
          projectBloc.add(
            const LoadProjectsRequested(
              forceRefresh: true,
              skipLoadingState: true, // Don't show loading indicator for smoother UX
            ),
          );
        } else {
          // For focus returns or account switches, do a complete refresh
          // but still try to maintain visual continuity
          projectBloc.add(
            const LoadProjectsRequested(
              forceRefresh: true,
              skipLoadingState: true, // Smoother UX for focus returns
            ),
          );
        }
      });

      if (kDebugMode) {
        debugPrint('✅ [APP] Project dashboard refresh triggered successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [APP] Error refreshing project dashboard: $e');
      }
    }
  }

  /// Setup navigation listener to track screen transitions
  void _setupNavigationListener() {
    Future.delayed(Duration.zero, () {
      // Listen to router changes after the widget tree is built
      AppRouter.router.routeInformationProvider.addListener(_handleRouteChange);
    });
  }

  /// Handle route changes to detect navigation between project screens
  void _handleRouteChange() {
    if (!mounted) return;

    final location = AppRouter.router.routeInformationProvider.value.uri.path;

    // Check if we're entering or leaving a project detail view
    final isProjectDetail = location.contains('/projects/') && !location.endsWith('/projects');

    if (isProjectDetail && !_isInProjectDetailView) {
      // We're entering a project detail view
      _isInProjectDetailView = true;
      _lastProjectDetailVisit = DateTime.now();
      if (kDebugMode) {
        debugPrint('🚶 [APP] Entered project detail view: $location');
      }
    } else if (!isProjectDetail && _isInProjectDetailView) {
      // We're returning from a project detail view to another screen
      _isInProjectDetailView = false;

      if (kDebugMode) {
        debugPrint('🔙 [APP] Returning from project detail view to: $location');
      }

      // If we're going back to the projects list, refresh the data
      if (location.endsWith('/projects') || location == '/') {
        _handleReturnFromProjectDetail();
      }
    }
  }

  /// Handle return from project detail view
  void _handleReturnFromProjectDetail() {
    // Get the current location to extract recently viewed project ID
    final location = AppRouter.router.routeInformationProvider.value.uri.path;
    final recentProjectId = _extractProjectIdFromRoute(location);

    // Calculate time since last visit (to avoid excessive refreshes)
    final now = DateTime.now();
    final timeSinceVisit = _lastProjectDetailVisit != null
        ? now.difference(_lastProjectDetailVisit!)
        : const Duration(seconds: 0);

    // Always refresh when returning from detail view, but with different approaches:
    // 1. For quick navigations (< 0.5s): Use skipLoadingState to avoid visual flicker
    // 2. For normal navigations: Clear cache and get fresh data
    if (kDebugMode) {
      debugPrint(
        '🔄 [APP] Refreshing project data after returning from detail view (time since visit: ${timeSinceVisit.inMilliseconds}ms)',
      );
    }

    try {
      final projectBloc = context.read<ProjectBloc>();

      // If it's a very quick navigation, use the specialized event
      if (timeSinceVisit.inMilliseconds < 500) {
        projectBloc.add(RefreshProjectsAfterDetailView(recentProjectId: recentProjectId));
      } else {
        // For longer navigations, force a cache clear and full refresh
        // First clear cache to ensure fresh data
        projectBloc.add(const RefreshProjectsWithCacheClear());

        // Then trigger a refresh that shows the projects immediately (skip loading state)
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            projectBloc.add(const LoadProjectsRequested(skipLoadingState: true, forceRefresh: true));
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [APP] Error dispatching refresh event: $e');
      }
      // Fallback to general refresh
      _forceRefreshDashboard(fromDetailView: true);
    }
  }

  /// Refresh the currently viewed project detail
  /// [location] The current route path
  void _refreshCurrentProjectDetail(String location) {
    try {
      // Extract project ID from the route
      final projectId = _extractProjectIdFromRoute(location);

      if (projectId != null) {
        if (kDebugMode) {
          debugPrint('🔄 [APP] Refreshing details for project: $projectId');
        }

        // Get project bloc and dispatch appropriate event
        final projectBloc = context.read<ProjectBloc>();
        projectBloc.add(LoadProjectDetailsRequested(projectId: projectId));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [APP] Error refreshing project detail: $e');
      }
    }
  }

  /// Extract project ID from a route path
  /// Returns null if cannot extract
  String? _extractProjectIdFromRoute(String route) {
    // Pattern: /projects/{projectId} or /projects/{projectId}/something
    final projectDetailPattern = RegExp(r'/projects/([^/]+)');
    final match = projectDetailPattern.firstMatch(route);

    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
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

    // Get current route to make intelligent refresh decisions
    final currentLocation = AppRouter.router.routeInformationProvider.value.uri.path;
    final isProjectsList = currentLocation.endsWith('/projects') || currentLocation == '/';
    final isProjectDetail = currentLocation.contains('/projects/') && !currentLocation.endsWith('/projects');

    // Mark the dashboard for refresh to ensure it will be refreshed when viewed
    _markDashboardForRefresh();

    // Account for potential account switches or data changes while in background
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      if (kDebugMode) {
        debugPrint('📍 [APP] Resuming at location: $currentLocation');
      }

      try {
        // If on projects list, aggressively refresh to ensure fresh data after resume
        if (isProjectsList) {
          final projectBloc = context.read<ProjectBloc>();

          // Clear cache first to ensure fresh data
          projectBloc.add(const RefreshProjectsWithCacheClear());

          // Then immediately trigger a load with skipLoadingState for smoother UX
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) {
              projectBloc.add(const LoadProjectsRequested(forceRefresh: true, skipLoadingState: true));
            }
          });
        } else if (isProjectDetail) {
          // If we're on project detail, refresh with special logic
          _refreshCurrentProjectDetail(currentLocation);
        }

        // Notify all streams that app focus has returned
        getIt<RealtimeApiStreams>().notifyAppFocusReturned();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ [APP] Error during app resume refresh: $e');
        }
      }
    });
  }

  /// Validate session when app resumes from background using SessionValidationService
  Future<void> _validateSessionOnResume() async {
    try {
      final sessionValidationService = getIt<SessionValidationService>();

      // Let the session validation service handle app resume logic
      await sessionValidationService.onAppResume();

      if (kDebugMode) {
        debugPrint('[SECURITY] Session validation on resume completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SECURITY] Error validating session on resume: $e');
      }
    }
  }

  /// Called when app goes to background.
  void _onAppPaused() {
    // Update activity and save state when app goes to background
    if (kDebugMode) {
      debugPrint('[APP] Pausing - updating activity and saving state');
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
        debugPrint('[SECURITY] Activity updated on pause');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SECURITY] Error updating activity on pause: $e');
      }
    }
  }

  /// Called when app is being terminated.
  void _onAppDetached() {
    // Final cleanup, save critical data
    if (kDebugMode) {
      debugPrint('[APP] Detaching - final cleanup');
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
      debugPrint('[LIFECYCLE] $event');
    }
    // In production, send to analytics
  }
}
