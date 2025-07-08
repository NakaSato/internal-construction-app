import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/realtime_api_streams.dart';
import '../../../application/project_bloc.dart';
import '../../../domain/entities/project_api_models.dart';
import '../../widgets/project_search_bar.dart';
import '../../widgets/project_app_header.dart';
import '../../widgets/project_floating_action_button.dart';
import '../../widgets/project_list_content.dart';
import 'project_list_controller.dart';
import 'project_list_lifecycle_manager.dart';
import 'project_list_realtime_handler.dart';
import 'project_list_search_handler.dart';
import 'project_list_filter_handler.dart';

/// Refactored project list screen with clean separation of concerns
///
/// This screen now delegates responsibilities to focused handler classes:
/// - ProjectListController: Business logic and state management
/// - ProjectListLifecycleManager: App lifecycle and authentication handling
/// - ProjectListRealtimeHandler: Real-time updates and WebSocket connections
/// - ProjectListSearchHandler: Search functionality
/// - ProjectListFilterHandler: Filter management
///
/// Benefits:
/// - Easier to test individual components
/// - Better maintainability
/// - Clear separation of concerns
/// - Reusable components
class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Handler instances
  late ProjectListController _controller;
  late ProjectListLifecycleManager _lifecycleManager;
  late ProjectListRealtimeHandler _realtimeHandler;
  late ProjectListSearchHandler _searchHandler;
  late ProjectListFilterHandler _filterHandler;

  // State variables
  ProjectsQuery _currentQuery = const ProjectsQuery();
  bool _isRealtimeConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeHandlers();
    _initializeServices();
  }

  /// Initialize all handler instances
  void _initializeHandlers() {
    _controller = ProjectListController(
      context: context,
      setState: setState,
      onStartLiveUpdates: _startLiveUpdates,
      onStopLiveUpdates: _stopLiveUpdates,
    );

    _lifecycleManager = ProjectListLifecycleManager(
      context: context,
      onSilentRefresh: _controller.silentRefresh,
      onForceRefresh: _controller.forceRefreshWithCacheClear,
      onInitializeAuthenticatedServices: _controller.initializeAuthenticatedServices,
      onCleanupUnauthenticatedServices: _controller.cleanupUnauthenticatedServices,
      onHandleAuthenticationError: _controller.handleAuthenticationError,
    );

    _realtimeHandler = ProjectListRealtimeHandler(
      context: context,
      onSilentRefresh: _controller.silentRefresh,
      onShowNotification: _showRealtimeUpdateNotification,
      onConnectionStatusChanged: _onRealtimeConnectionStatusChanged,
    );

    _searchHandler = ProjectListSearchHandler(
      context: context,
      searchController: _searchController,
      onQueryChanged: _onQueryChanged,
      initialQuery: _currentQuery,
    );

    _filterHandler = ProjectListFilterHandler(
      context: context,
      onFilterApplied: _onFilterApplied,
      initialQuery: _currentQuery,
    );
  }

  /// Initialize services
  Future<void> _initializeServices() async {
    await _lifecycleManager.initialize();
    await _realtimeHandler.initialize();
  }

  // === CALLBACK HANDLERS ===

  /// Handle query changes from search handler
  void _onQueryChanged(ProjectsQuery newQuery) {
    setState(() {
      _currentQuery = newQuery;
    });
    _filterHandler.updateQuery(newQuery);
  }

  /// Handle filter application
  void _onFilterApplied(ProjectsQuery newQuery) {
    setState(() {
      _currentQuery = newQuery;
    });
    _searchHandler.updateQuery(newQuery);
    _searchHandler.searchWithQuery(newQuery);
  }

  /// Handle real-time connection status changes
  void _onRealtimeConnectionStatusChanged(bool isConnected) {
    setState(() {
      _isRealtimeConnected = isConnected;
    });
  }

  /// Start live updates
  void _startLiveUpdates() {
    _realtimeHandler.startLiveUpdates(_currentQuery);
  }

  /// Stop live updates
  void _stopLiveUpdates() {
    _realtimeHandler.stopLiveUpdates();
  }

  /// Show user-friendly notifications for real-time updates
  void _showRealtimeUpdateNotification(RealtimeProjectUpdate update) {
    String message;
    Color backgroundColor;
    IconData icon;

    switch (update.type) {
      case 'create':
        message = 'New project added';
        backgroundColor = Colors.green;
        icon = Icons.add_circle;
        break;
      case 'update':
        message = 'Project updated';
        backgroundColor = Colors.blue;
        icon = Icons.update;
        break;
      case 'delete':
        message = 'Project removed';
        backgroundColor = Colors.orange;
        icon = Icons.remove_circle;
        break;
      default:
        message = 'Project data changed';
        backgroundColor = Colors.grey;
        icon = Icons.sync;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    _lifecycleManager.dispose();
    _realtimeHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // App Header
          _buildAppHeader(),

          // Search and Filter Bar
          _buildSearchAndFilterBar(),

          // Project List Content
          Expanded(child: _buildProjectListContent()),
        ],
      ),
      floatingActionButton: const ProjectFloatingActionButton(),
    );
  }

  /// Build app header with real-time status
  Widget _buildAppHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: const ProjectAppHeader(),
    );
  }

  /// Build search and filter bar with real-time status
  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Real-time connection status
          _buildRealtimeStatus(),

          // Project count and controls
          _buildProjectCountAndControls(),

          const SizedBox(height: 20),

          // Search bar
          _buildSearchBar(),
        ],
      ),
    );
  }

  /// Build real-time connection status indicator
  Widget _buildRealtimeStatus() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _isRealtimeConnected
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Connection status
          Row(
            children: [
              Icon(
                _isRealtimeConnected ? Icons.wifi : Icons.wifi_off,
                color: _isRealtimeConnected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                _isRealtimeConnected ? 'Live Updates Active' : 'Real-time Offline',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _isRealtimeConnected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Controls
          Row(
            children: [
              // Force refresh button
              ElevatedButton.icon(
                onPressed: _controller.forceRefreshWithCacheClear,
                icon: Icon(Icons.refresh_rounded, size: 16, color: Theme.of(context).colorScheme.onPrimaryContainer),
                label: Text(
                  'Refresh',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),

              if (_controller.isSilentRefreshing) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Build project count and live reload controls
  Widget _buildProjectCountAndControls() {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, projectState) {
        return Row(
          children: [
            // Project count badge
            if (projectState is ProjectsLoaded) ...[
              _buildProjectCountBadge(projectState.projectsResponse.totalCount),
              const Spacer(),
            ],

            // Live reload toggle
            _buildLiveReloadToggle(),
          ],
        );
      },
    );
  }

  /// Build project count badge
  Widget _buildProjectCountBadge(int count) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_rounded, size: 14, color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$count',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' Projects',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build live reload toggle
  Widget _buildLiveReloadToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _controller.isLiveReloadEnabled
                  ? Theme.of(context).colorScheme.tertiary.withOpacity(0.2)
                  : Theme.of(context).colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _controller.isLiveReloadEnabled ? Icons.sync : Icons.sync_disabled,
              size: 14,
              color: _controller.isLiveReloadEnabled
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Auto Updates',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _controller.isLiveReloadEnabled
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (_controller.isSilentRefreshing) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _controller.isLiveReloadEnabled
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(width: 12),
          // Enhanced toggle switch
          GestureDetector(
            onTap: _controller.toggleLiveReload,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 24,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _controller.isLiveReloadEnabled
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _controller.isLiveReloadEnabled ? 24 : 0,
                    top: 0,
                    bottom: 0,
                    width: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, spreadRadius: 0.5)],
                      ),
                      child: Center(
                        child: Icon(
                          _controller.isLiveReloadEnabled ? Icons.check : Icons.close,
                          size: 12,
                          color: _controller.isLiveReloadEnabled
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build search bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ProjectSearchBar(
          controller: _searchController,
          onChanged: _searchHandler.onSearchChanged,
          onFilterTap: _filterHandler.showFilterBottomSheet,
          hintText: 'Search projects by name, client, or address...',
          onClearSearch: _searchHandler.clearSearch,
          showActiveFilters: _filterHandler.hasActiveFilters,
          activeFilterCount: _filterHandler.activeFilterCount,
          currentQuery: _currentQuery,
          onQueryChanged: _onQueryChanged,
        ),
      ),
    );
  }

  /// Build project list content
  Widget _buildProjectListContent() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ProjectListContent(onRefresh: _controller.onRefresh),
    );
  }
}
