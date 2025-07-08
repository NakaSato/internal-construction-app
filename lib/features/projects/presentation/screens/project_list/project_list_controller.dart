import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../authentication/application/auth_bloc.dart';
import '../../../../authentication/application/auth_state.dart';
import '../../../application/project_bloc.dart';
import '../../../domain/entities/project_api_models.dart';

/// Main controller for project list screen business logic
///
/// This class manages:
/// - Project data loading and refreshing
/// - Live reload functionality
/// - State management for loading indicators
/// - Authentication checks
/// - Data synchronization
class ProjectListController {
  final BuildContext context;
  final void Function(VoidCallback) setState;
  final VoidCallback onStartLiveUpdates;
  final VoidCallback onStopLiveUpdates;

  // State variables
  bool _isLiveReloadEnabled = true;
  bool _isSilentRefreshing = false;
  bool _isRefreshing = false;
  Timer? _refreshTimer;

  // Configuration
  static const Duration _refreshInterval = Duration(seconds: 30);

  ProjectListController({
    required this.context,
    required this.setState,
    required this.onStartLiveUpdates,
    required this.onStopLiveUpdates,
  });

  // === GETTERS ===

  bool get isLiveReloadEnabled => _isLiveReloadEnabled;
  bool get isSilentRefreshing => _isSilentRefreshing;
  bool get isRefreshing => _isRefreshing;

  // === LIVE RELOAD MANAGEMENT ===

  /// Toggle live reload on/off
  void toggleLiveReload() {
    setState(() {
      _isLiveReloadEnabled = !_isLiveReloadEnabled;
    });

    if (_isLiveReloadEnabled) {
      _startLiveReload();
      onStartLiveUpdates();
    } else {
      _stopLiveReload();
      onStopLiveUpdates();
    }
  }

  /// Start the live reload timer for automatic project updates
  void _startLiveReload() {
    if (_isLiveReloadEnabled) {
      _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
        silentRefresh();
      });
    }
  }

  /// Stop the live reload timer
  void _stopLiveReload() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // === DATA LOADING AND REFRESHING ===

  /// Load initial projects with fresh data
  Future<void> loadInitialProjectsWithFreshData() async {
    // Check authentication state before loading
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      debugPrint('⚠️ Project List: Cannot load projects - user not authenticated');
      return;
    }

    // Small delay to ensure the BLoC is properly initialized
    await Future.delayed(const Duration(milliseconds: 100));

    // Double-check authentication state after delay
    final currentAuthState = context.read<AuthBloc>().state;
    if (currentAuthState is! AuthAuthenticated) {
      debugPrint('⚠️ Project List: Auth state changed during load - aborting');
      return;
    }

    // Use skipLoadingState based on whether we're coming from project detail
    final bool comingFromDetail = ModalRoute.of(context)?.settings.arguments == 'fromProjectDetail';

    context.read<ProjectBloc>().add(
      LoadProjectsRequested(query: const ProjectsQuery(), skipLoadingState: comingFromDetail, forceRefresh: false),
    );

    debugPrint('✅ Project List: Initial load with fresh API data (skipLoadingState: $comingFromDetail)');
  }

  /// Silent refresh that makes fresh API calls without showing loading indicators
  void silentRefresh() {
    // Check authentication before making API calls
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      debugPrint('⚠️ Project List: Cannot silent refresh - user not authenticated');
      return;
    }

    setState(() {
      _isSilentRefreshing = true;
    });

    // Always clear cache for silent refresh to ensure fresh data
    context.read<ProjectBloc>().add(RefreshProjectsWithCacheClear(query: const ProjectsQuery()));

    // Make fresh API request after cache clear
    _performSilentRefreshAfterDelay();
  }

  /// Perform silent refresh after cache clear delay
  void _performSilentRefreshAfterDelay() {
    Future.delayed(const Duration(milliseconds: 100), () {
      // Double-check authentication state after delay
      final currentAuthState = context.read<AuthBloc>().state;
      if (currentAuthState is! AuthAuthenticated) {
        debugPrint('⚠️ Project List: Auth state changed during silent refresh - aborting');
        setState(() {
          _isSilentRefreshing = false;
        });
        return;
      }

      context.read<ProjectBloc>().add(LoadProjectsRequested(query: const ProjectsQuery()));
    });

    // Hide the refresh indicator after 2 seconds
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _isSilentRefreshing = false;
      });
    });

    debugPrint('🔄 Project List: Silent refresh with fresh API data initiated');
  }

  /// Enhanced refresh that clears cache and makes fresh API requests
  Future<void> onRefresh() async {
    // Stop any ongoing real-time updates temporarily during refresh
    onStopLiveUpdates();

    // Restart the live reload timer
    if (_isLiveReloadEnabled) {
      _stopLiveReload();
      _startLiveReload();
    }

    // Force cache clear and make fresh API requests
    try {
      // Always clear cache first to ensure fresh data
      context.read<ProjectBloc>().add(RefreshProjectsWithCacheClear(query: const ProjectsQuery()));

      // Wait a bit for cache to clear, then make the fresh request
      await Future.delayed(const Duration(milliseconds: 150));

      context.read<ProjectBloc>().add(
        LoadProjectsRequested(
          query: const ProjectsQuery(),
          skipLoadingState: true, // Skip loading state to prevent flickering
          forceRefresh: true, // But still force a data refresh
        ),
      );

      // Restart live updates after refresh
      if (_isLiveReloadEnabled) {
        onStartLiveUpdates();
      }

      debugPrint('✅ Project List: Refresh completed with fresh API data');
    } catch (e) {
      debugPrint('❌ Project List: Error during refresh: $e');

      // Restart live updates even if refresh failed
      if (_isLiveReloadEnabled) {
        onStartLiveUpdates();
      }
    }
  }

  /// Force refresh that clears cache and shows loading indicator
  void forceRefreshWithCacheClear() {
    if (kDebugMode) {
      debugPrint('🔄 ProjectListController: Force refreshing projects with cache clear');
    }

    // Check authentication state before refreshing
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      debugPrint('⚠️ ProjectListController: Cannot refresh - user not authenticated');
      return;
    }

    // Show refresh indicator
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Use the dedicated event that clears cache first
      context.read<ProjectBloc>().add(const RefreshProjectsWithCacheClear());

      if (kDebugMode) {
        debugPrint('✅ ProjectListController: Refresh with cache clear initiated');
      }
    } catch (e) {
      debugPrint('❌ ProjectListController: Error refreshing projects: $e');
    }

    // Hide the refresh indicator after a delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isRefreshing = false;
      });
    });
  }

  /// Initialize authenticated services
  void initializeAuthenticatedServices() {
    // Start with fresh API data by clearing cache first
    loadInitialProjectsWithFreshData();
  }

  /// Clean up services when user is unauthenticated
  void cleanupUnauthenticatedServices() {
    debugPrint('🧹 Project List: Cleaning up controller services for unauthenticated user');

    // Stop live reload
    if (_refreshTimer?.isActive == true) {
      _refreshTimer?.cancel();
      _isLiveReloadEnabled = false;
      debugPrint('🛑 Project List: Stopped live reload timer');
    }

    // Stop any ongoing refreshes
    setState(() {
      _isSilentRefreshing = false;
      _isRefreshing = false;
    });

    debugPrint('✅ Project List: Controller cleanup completed');
  }

  /// Handle authentication errors
  void handleAuthenticationError() {
    debugPrint('🔐 Project List: Handling authentication error - cleaning up');
    cleanupUnauthenticatedServices();
  }

  /// Dispose of resources
  void dispose() {
    _stopLiveReload();
  }
}
