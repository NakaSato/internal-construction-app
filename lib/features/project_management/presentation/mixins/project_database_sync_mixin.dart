import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/project_bloc.dart';
import '../../domain/entities/project_api_models.dart';

/// Mixin to handle database synchronization functionality
mixin ProjectDatabaseSyncMixin<T extends StatefulWidget> on State<T> {
  Timer? _databaseSyncTimer;
  bool _isSilentRefreshing = false;

  bool get isSilentRefreshing => _isSilentRefreshing;

  /// Start database sync timer for periodic database synchronization
  void startDatabaseSync() {
    // More frequent database sync every 90 seconds to ensure data consistency
    _databaseSyncTimer = Timer.periodic(const Duration(seconds: 90), (timer) {
      if (mounted) {
        debugPrint('🔄 Database sync: Periodic database update check');
        forceDatabaseSync();
      }
    });

    debugPrint('✅ Database sync timer started - syncing every 90 seconds');
  }

  /// Stop database sync timer
  void stopDatabaseSync() {
    _databaseSyncTimer?.cancel();
    _databaseSyncTimer = null;
    debugPrint('🔄 Database sync timer stopped');
  }

  /// Force a database sync by clearing cache and reloading with enhanced reliability
  void forceDatabaseSync() {
    if (!mounted) return;

    debugPrint('🔄 Database sync: Force refreshing from database');

    final currentQuery = getCurrentQuery();

    // Clear cache and force fresh database query with longer delay for reliability
    context.read<EnhancedProjectBloc>().add(RefreshProjectsWithCacheClear(query: currentQuery));

    // Load fresh data after cache clear with increased delay to ensure cache clearing completes
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _loadFreshData(currentQuery);
        debugPrint('✅ Database sync: Fresh data loaded from database');
      }
    });
  }

  /// Manual database sync with enhanced error handling and user feedback
  Future<void> manualDatabaseSync() async {
    if (!mounted) return;

    try {
      debugPrint('🔄 Manual database sync: Starting comprehensive sync');

      setState(() {
        _isSilentRefreshing = true;
      });

      // Step 1: Stop any ongoing updates
      onStopLiveUpdates();

      // Step 2: Clear all caches to ensure fresh database data
      final currentQuery = getCurrentQuery();
      context.read<EnhancedProjectBloc>().add(RefreshProjectsWithCacheClear(query: currentQuery));

      // Step 3: Wait for cache clear to complete
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Step 4: Force fresh database query
      _loadFreshData(currentQuery);

      // Step 5: Restart live updates
      onRestartLiveUpdates();

      // Step 6: Reset refresh indicator after delay
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isSilentRefreshing = false;
          });
        }
      });

      debugPrint('✅ Manual database sync: Completed successfully');
    } catch (e) {
      debugPrint('❌ Manual database sync: Error occurred: $e');

      if (mounted) {
        setState(() {
          _isSilentRefreshing = false;
        });

        // Show error message to user
        _showSyncErrorMessage();

        // Restart live updates even on error
        onRestartLiveUpdates();
      }
    }
  }

  /// Load initial projects with fresh API data
  /// Enhanced to ensure reliable database synchronization on startup
  void loadInitialProjectsWithFreshData() {
    debugPrint('🚀 Project List: Starting initial load with fresh database sync');

    final currentQuery = getCurrentQuery();

    // Step 1: Clear any existing cache first to ensure fresh data from database
    context.read<EnhancedProjectBloc>().add(RefreshProjectsWithCacheClear(query: currentQuery));

    // Step 2: Wait for cache clear to complete, then load fresh data from API
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<EnhancedProjectBloc>().add(LoadProjectsRequested(query: currentQuery));
        debugPrint('🚀 Project List: Initial load with fresh API data from database requested');
      }
    });

    // Step 3: Additional force refresh after initial load to ensure complete database sync
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        onSilentRefresh();
        debugPrint('🔄 Project List: Post-initial force refresh to ensure database sync');
      }
    });

    // Step 4: Final verification refresh after 2 seconds to catch any missed updates
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        forceDatabaseSync();
        debugPrint('✅ Project List: Final database sync verification completed');
      }
    });
  }

  void _loadFreshData(ProjectsQuery currentQuery) {
    final searchTerm = getCurrentSearchTerm();
    if (searchTerm.isNotEmpty) {
      context.read<EnhancedProjectBloc>().add(SearchProjectsRequested(searchTerm: searchTerm, filters: currentQuery));
    } else {
      context.read<EnhancedProjectBloc>().add(LoadProjectsRequested(query: currentQuery));
    }
  }

  void _showSyncErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.error, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Database sync failed. Please try again.'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      ),
    );
  }

  /// Clean up database sync resources
  void disposeDatabaseSync() {
    stopDatabaseSync();
  }

  // Abstract methods that must be implemented by the using class
  ProjectsQuery getCurrentQuery();
  String getCurrentSearchTerm();
  void onStopLiveUpdates();
  void onRestartLiveUpdates();
  void onSilentRefresh();
}
