import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/services/realtime_api_streams.dart';
import '../../../../authentication/application/auth_bloc.dart';
import '../../../../authentication/application/auth_state.dart';
import '../../../application/project_bloc.dart';

/// Manages app lifecycle events and authentication state changes for the project list screen
///
/// This class handles:
/// - App lifecycle events (resume, pause)
/// - Authentication state changes
/// - Route argument processing
/// - Initial data loading decisions
class ProjectListLifecycleManager with WidgetsBindingObserver {
  final BuildContext context;
  final VoidCallback onSilentRefresh;
  final VoidCallback onForceRefresh;
  final VoidCallback onInitializeAuthenticatedServices;
  final VoidCallback onCleanupUnauthenticatedServices;
  final VoidCallback onHandleAuthenticationError;

  StreamSubscription? _authSubscription;
  StreamSubscription? _appFocusSubscription;
  late final RealtimeApiStreams _realtimeApiStreams;
  _AppLifecycleObserver? _lifecycleObserver;

  ProjectListLifecycleManager({
    required this.context,
    required this.onSilentRefresh,
    required this.onForceRefresh,
    required this.onInitializeAuthenticatedServices,
    required this.onCleanupUnauthenticatedServices,
    required this.onHandleAuthenticationError,
  });

  /// Initialize lifecycle management
  Future<void> initialize() async {
    await _initializeServices();
    _setupAuthenticationListener();
    _setupAppLifecycleListener();
    _setupAppFocusListener();

    // Handle initial data loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOrRefreshData();
      _checkRouteArguments();
    });
  }

  /// Initialize required services
  Future<void> _initializeServices() async {
    try {
      // Initialize enhanced real-time API streams
      _realtimeApiStreams = getIt<RealtimeApiStreams>();
    } catch (e) {
      debugPrint('❌ ProjectListLifecycleManager: Failed to initialize services: $e');
    }
  }

  /// Initialize or refresh data based on current state
  void _initializeOrRefreshData() {
    final currentState = context.read<ProjectBloc>().state;

    if (currentState is ProjectsLoaded) {
      // Check if we have data already, but refresh if it's older than 30 seconds
      debugPrint('🔍 Project List: Has projects data, refreshing silently to ensure it\'s up to date');
      onSilentRefresh();
    } else {
      debugPrint('🔍 Project List: No current projects data, initializing');
      _checkAuthAndInitializeIfAuthenticated();
    }
  }

  /// Check route arguments for special handling
  void _checkRouteArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == 'fromAccountSwitch') {
      debugPrint('🔄 Project List: Account switch detected - forcing data refresh');
      onForceRefresh();
    }
  }

  /// Set up authentication state listener to handle login/logout
  void _setupAuthenticationListener() {
    _authSubscription = context.read<AuthBloc>().stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        debugPrint('🔐 Project List: User authenticated - initializing services');
        onInitializeAuthenticatedServices();
      } else if (authState is AuthUnauthenticated) {
        debugPrint('🔐 Project List: User unauthenticated - cleaning up services');
        onCleanupUnauthenticatedServices();
      } else if (authState is AuthFailure) {
        debugPrint('🔐 Project List: Authentication failed - ${authState.message}');
        onHandleAuthenticationError();
      } else if (authState is AuthTokenExpired) {
        debugPrint('🔐 Project List: Token expired - ${authState.message}');
        onHandleAuthenticationError();
      }
    });
  }

  /// Set up app lifecycle observer
  void _setupAppLifecycleListener() {
    _lifecycleObserver = _AppLifecycleObserver(
      onResume: () {
        debugPrint('🌟 Project List: App lifecycle resumed - refreshing data');
        onSilentRefresh();
      },
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver!);
  }

  /// Set up app focus listener
  void _setupAppFocusListener() {
    try {
      _appFocusSubscription = _realtimeApiStreams.appFocusStream.listen((hasFocus) {
        if (hasFocus) {
          debugPrint('🌟 Project List: App focus returned - refreshing data');
          onSilentRefresh();
        }
      });
    } catch (e) {
      debugPrint('❌ ProjectListLifecycleManager: Failed to setup app focus listener: $e');
    }
  }

  /// Check initial authentication state and initialize if authenticated
  void _checkAuthAndInitializeIfAuthenticated() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      debugPrint('✅ Project List: User authenticated - initializing services');
      onInitializeAuthenticatedServices();
    } else {
      debugPrint('⚠️ Project List: User not authenticated on init - waiting for auth');
      // The auth listener will handle initialization once authenticated
    }
  }

  /// Clean up all subscriptions and observers
  void dispose() {
    _authSubscription?.cancel();
    _appFocusSubscription?.cancel();

    if (_lifecycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifecycleObserver!);
      _lifecycleObserver = null;
    }
  }
}

/// App lifecycle observer for handling app resume/pause events
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;

  _AppLifecycleObserver({required this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}
