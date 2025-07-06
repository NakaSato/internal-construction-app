import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/realtime_api_streams.dart';
import '../../application/project_bloc.dart';
import '../../domain/entities/project_api_models.dart';

/// Mixin to handle live reload functionality
mixin ProjectLiveReloadMixin<T extends StatefulWidget> on State<T> {
  Timer? _refreshTimer;
  Timer? _debounceTimer;
  bool _isLiveReloadEnabled = true;

  // Live reload interval (30 seconds)
  static const Duration _refreshInterval = Duration(seconds: 30);

  bool get isLiveReloadEnabled => _isLiveReloadEnabled;
  Duration get refreshInterval => _refreshInterval;

  /// Start the live reload timer for automatic project updates
  void startLiveReload() {
    if (_isLiveReloadEnabled) {
      _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
        onSilentRefresh();
      });
    }
  }

  /// Stop the live reload timer
  void stopLiveReload() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Toggle live reload on/off
  void toggleLiveReload() {
    setState(() {
      _isLiveReloadEnabled = !_isLiveReloadEnabled;
    });

    if (_isLiveReloadEnabled) {
      startLiveReload();
      startLiveApiUpdates();
      onStartDatabaseSync();
    } else {
      stopLiveReload();
      stopLiveApiUpdates();
      onStopDatabaseSync();
    }
  }

  /// Start live API updates using the repository stream
  void startLiveApiUpdates() {
    if (_isLiveReloadEnabled) {
      final currentQuery = getCurrentQuery();
      context.read<EnhancedProjectBloc>().add(
        StartLiveProjectUpdates(query: currentQuery, updateInterval: _refreshInterval, includeDeltas: true),
      );
    }
  }

  /// Stop live API updates
  void stopLiveApiUpdates() {
    context.read<EnhancedProjectBloc>().add(const StopLiveProjectUpdates());
  }

  /// Silent refresh that makes fresh API calls without showing loading indicators
  /// Enhanced to ensure reliable database synchronization
  void silentRefresh() {
    if (!mounted) return;

    // Debounce rapid refresh calls to prevent excessive API requests
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      onSilentRefreshStarted();

      final currentQuery = getCurrentQuery();

      // Force cache clear to ensure fresh database data - critical for database sync
      context.read<EnhancedProjectBloc>().add(RefreshProjectsWithCacheClear(query: currentQuery));

      // Make fresh API request after cache clear with increased delay for reliability
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;

        final searchTerm = getCurrentSearchTerm();
        if (searchTerm.isNotEmpty) {
          context.read<EnhancedProjectBloc>().add(
            SearchProjectsRequested(searchTerm: searchTerm, filters: currentQuery),
          );
        } else {
          context.read<EnhancedProjectBloc>().add(LoadProjectsRequested(query: currentQuery));
        }

        debugPrint('🔄 Project List: Silent refresh with fresh database data completed');
      });

      // Hide the refresh indicator after 3 seconds (increased for better UX)
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          onSilentRefreshCompleted();
        }
      });

      debugPrint('🔄 Project List: Silent refresh with database sync initiated');
    });
  }

  /// Enhanced refresh that clears cache and makes fresh API requests
  /// Now with more aggressive database synchronization
  Future<void> performRefresh() async {
    debugPrint('🔄 Project List: User-initiated refresh with database sync');

    // Stop any ongoing real-time updates temporarily during refresh
    stopLiveApiUpdates();

    // Restart the live reload timer
    if (_isLiveReloadEnabled) {
      stopLiveReload();
      startLiveReload();
    }

    // Force cache clear and make fresh API requests with enhanced error handling
    try {
      final searchTerm = getCurrentSearchTerm();
      final currentQuery = getCurrentQuery();

      // Step 1: Always clear cache first to ensure fresh data
      context.read<EnhancedProjectBloc>().add(RefreshProjectsWithCacheClear(query: currentQuery));

      // Step 2: Wait longer for cache to clear completely
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        // Step 3: Make fresh request from database
        if (searchTerm.isNotEmpty) {
          context.read<EnhancedProjectBloc>().add(
            SearchProjectsRequested(searchTerm: searchTerm, filters: currentQuery),
          );
        } else {
          context.read<EnhancedProjectBloc>().add(LoadProjectsRequested(query: currentQuery));
        }
      }

      // Step 4: Wait a bit then force another sync to catch any missed updates
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        onForceDatabaseSync();
      }

      // Restart live updates after refresh
      if (_isLiveReloadEnabled && mounted) {
        startLiveApiUpdates();
      }

      debugPrint('✅ Project List: Enhanced refresh with database sync completed');
    } catch (e) {
      debugPrint('❌ Project List: Error during enhanced refresh: $e');

      // Restart live updates even if refresh failed
      if (_isLiveReloadEnabled && mounted) {
        startLiveApiUpdates();
      }

      rethrow; // Let the RefreshIndicator handle the error state
    }
  }

  /// Clean up live reload resources
  void disposeLiveReload() {
    stopLiveReload();
    stopLiveApiUpdates();
    _debounceTimer?.cancel();
  }

  /// Default implementation for checking if update matches current filters
  bool matchesCurrentFilters(Map<String, dynamic> data) {
    final currentQuery = getCurrentQuery();
    final searchTerm = getCurrentSearchTerm();

    // Check search text
    if (searchTerm.isNotEmpty) {
      final searchText = searchTerm.toLowerCase();
      final searchableText = [
        data['name']?.toString(),
        data['clientInfo']?.toString(),
        data['address']?.toString(),
      ].where((text) => text != null).join(' ').toLowerCase();

      if (!searchableText.contains(searchText)) return false;
    }

    // Check status filters
    if (currentQuery.statuses?.isNotEmpty == true) {
      final status = data['status']?.toString();
      if (status != null && !currentQuery.statuses!.contains(status)) {
        return false;
      }
    }

    return true;
  }

  /// Default implementation for determining if search results should be refreshed
  bool shouldRefreshForUpdate(RealtimeProjectUpdate update) {
    final currentQuery = getCurrentQuery();
    final searchTerm = getCurrentSearchTerm();

    // Always refresh if no specific filters are applied
    if (!currentQuery.hasActiveFilters && searchTerm.isEmpty) {
      return true;
    }

    // For complex filtering, delegate to helper method
    return matchesCurrentFilters(update.data);
  }

  // Abstract methods that must be implemented by the using class
  ProjectsQuery getCurrentQuery();
  String getCurrentSearchTerm();
  void onSilentRefresh();
  void onSilentRefreshStarted();
  void onSilentRefreshCompleted();
  void onStartDatabaseSync();
  void onStopDatabaseSync();
  void onForceDatabaseSync();
}
