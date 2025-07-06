import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/universal_realtime_handler.dart';
import '../../../../core/services/realtime_api_streams.dart';
import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';
import '../../application/project_bloc.dart';
import '../../domain/entities/project_api_models.dart';
import '../widgets/project_search_bar.dart';
import '../widgets/project_filter_bottom_sheet.dart';
import '../widgets/project_app_header.dart';
import '../widgets/project_floating_action_button.dart';
import '../widgets/project_list_content.dart';

/// Enhanced project list screen that uses the new API-based project management system
class EnhancedProjectListScreen extends StatefulWidget {
  const EnhancedProjectListScreen({super.key});

  @override
  State<EnhancedProjectListScreen> createState() => _EnhancedProjectListScreenState();
}

class _EnhancedProjectListScreenState extends State<EnhancedProjectListScreen> {
  final TextEditingController _searchController = TextEditingController();
  ProjectsQuery _currentQuery = const ProjectsQuery();
  Timer? _refreshTimer;
  bool _isLiveReloadEnabled = true;
  bool _isSilentRefreshing = false;
  late final UniversalRealtimeHandler _realtimeHandler;
  StreamSubscription? _authSubscription;

  // Enhanced real-time system variables
  StreamSubscription<RealtimeProjectUpdate>? _realtimeApiSubscription;
  late final RealtimeApiStreams _realtimeApiStreams;
  bool _isRealtimeConnected = false;

  // Live reload interval (30 seconds)
  static const Duration _refreshInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();

    // Initialize comprehensive real-time handler
    _realtimeHandler = getIt<UniversalRealtimeHandler>();

    // Initialize enhanced real-time API streams
    _realtimeApiStreams = getIt<RealtimeApiStreams>();

    // Listen for authentication state changes throughout the app lifecycle
    _setupAuthenticationListener();

    // Check authentication and start if authenticated
    _checkAuthAndInitializeIfAuthenticated();
  }

  /// Set up authentication state listener to handle login/logout
  void _setupAuthenticationListener() {
    _authSubscription = context.read<AuthBloc>().stream.listen((authState) {
      if (!mounted) return;

      if (authState is AuthAuthenticated) {
        debugPrint('🔐 Project List: User authenticated - initializing services');
        _initializeAuthenticatedServices();
      } else if (authState is AuthUnauthenticated) {
        debugPrint('🔐 Project List: User unauthenticated - cleaning up services');
        _cleanupUnauthenticatedServices();
      } else if (authState is AuthFailure) {
        debugPrint('🔐 Project List: Authentication failed - ${authState.message}');
        _cleanupUnauthenticatedServices();
      }
    });
  }

  /// Check initial authentication state and initialize if authenticated
  void _checkAuthAndInitializeIfAuthenticated() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _initializeAuthenticatedServices();
    } else {
      debugPrint('⚠️ Project List: User not authenticated on init');
    }
  }

  /// Initialize services when user is authenticated
  void _initializeAuthenticatedServices() {
    // Start with fresh API data by clearing cache first
    _loadInitialProjectsWithFreshData();

    // Start live reload timer as fallback
    _startLiveReload();

    // Initialize both real-time systems
    _checkAuthAndInitializeRealtime();
    _initializeEnhancedRealtime();
  }

  /// Clean up services when user is unauthenticated
  void _cleanupUnauthenticatedServices() {
    // Stop live reload
    if (_refreshTimer?.isActive == true) {
      _refreshTimer?.cancel();
      _isLiveReloadEnabled = false;
    }

    // Disconnect real-time services
    _disconnectRealtime();

    // Clear any existing project data
    if (mounted) {
      context.read<EnhancedProjectBloc>().add(const ClearProjectsRequested());
    }
  }

  /// Load initial projects with fresh API data
  void _loadInitialProjectsWithFreshData() {
    // Clear any existing cache first
    context.read<EnhancedProjectBloc>().add(RefreshProjectsWithCacheClear(query: _currentQuery));

    // Then load fresh data from API
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        context.read<EnhancedProjectBloc>().add(const LoadProjectsRequested());
        debugPrint('🚀 Project List: Initial load with fresh API data');
      }
    });
  }

  /// Check authentication state and initialize real-time updates if authenticated
  Future<void> _checkAuthAndInitializeRealtime() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      await _initializeRealtimeUpdates();
    } else {
      debugPrint('⚠️ Project List: User not authenticated, skipping real-time initialization');
      // Listen for authentication changes
      _authSubscription = context.read<AuthBloc>().stream.listen((state) {
        if (state is AuthAuthenticated && mounted) {
          _initializeRealtimeUpdates();
        } else if (state is AuthUnauthenticated && mounted) {
          _disconnectRealtime();
        }
      });
    }
  }

  /// Disconnect real-time updates when user logs out
  Future<void> _disconnectRealtime() async {
    try {
      // The UniversalRealtimeHandler will handle cleanup automatically
      debugPrint('🔌 Project List: Disconnecting real-time updates due to logout');
    } catch (e) {
      debugPrint('❌ Project List: Error disconnecting real-time updates: $e');
    }
  }

  /// Initialize real-time updates for comprehensive live data synchronization
  Future<void> _initializeRealtimeUpdates() async {
    try {
      // Initialize the universal real-time handler if not already connected
      if (!_realtimeHandler.isConnected) {
        await _realtimeHandler.initialize();
      }

      // Register handlers for project-related events
      _realtimeHandler.registerProjectHandler((event) {
        debugPrint('📡 Real-time project event: ${event.type.name}');

        // Parse the event data to extract project information
        final projectData = event.data;

        switch (event.type.name) {
          case 'projectCreated':
            // Create a project from the event data
            try {
              final project = EnhancedProject.fromJson(projectData);
              context.read<EnhancedProjectBloc>().add(RealTimeProjectCreatedReceived(project: project));
            } catch (e) {
              debugPrint('❌ Error parsing project created event: $e');
              _silentRefresh(); // Fallback to refresh
            }
            break;

          case 'projectUpdated':
            try {
              final project = EnhancedProject.fromJson(projectData);
              context.read<EnhancedProjectBloc>().add(RealTimeProjectUpdateReceived(project: project));
            } catch (e) {
              debugPrint('❌ Error parsing project updated event: $e');
              _silentRefresh(); // Fallback to refresh
            }
            break;

          case 'projectDeleted':
            final projectId = projectData['id'] as String? ?? projectData['projectId'] as String?;
            if (projectId != null) {
              context.read<EnhancedProjectBloc>().add(RealTimeProjectDeletedReceived(projectId: projectId));
            } else {
              debugPrint('No project ID in delete event');
              _silentRefresh(); // Fallback to refresh
            }
            break;

          case 'projectStatusChanged':
            // For status changes, we'll do a refresh to get the latest data
            _silentRefresh();
            break;

          default:
            debugPrint('Unknown project event type: ${event.type.name}');
            _silentRefresh(); // Fallback to refresh
        }
      });

      // Register handlers for task-related events (affects project status)
      _realtimeHandler.registerTaskHandler((event) {
        debugPrint('Real-time task event: ${event.type.name}');
        // Refresh project list when tasks are updated (may affect project progress)
        if (mounted) {
          _silentRefresh();
        }
      });

      // Register handlers for daily report events (affects project status)
      _realtimeHandler.registerDailyReportHandler((event) {
        debugPrint('📡 Real-time daily report event: ${event.type.name}');
        // Refresh project list when daily reports are updated
        if (mounted) {
          _silentRefresh();
        }
      });

      debugPrint('Project List: Real-time updates initialized successfully');
    } catch (e) {
      debugPrint('Project List: Failed to initialize real-time updates: $e');
      // Continue with fallback polling if real-time fails
    }
  }

  /// Initialize enhanced real-time API system
  Future<void> _initializeEnhancedRealtime() async {
    try {
      // Initialize connection
      await _realtimeApiStreams.initialize();

      if (!mounted) return;

      setState(() {
        _isRealtimeConnected = _realtimeApiStreams.isConnected;
      });

      // Start enhanced real-time updates through BLoC
      context.read<EnhancedProjectBloc>().add(const StartProjectRealtimeUpdates());

      // Subscribe for UI feedback and live connection status
      _realtimeApiSubscription = _realtimeApiStreams.projectsStream.listen(
        (update) {
          debugPrint('📡 Enhanced real-time project update: ${update.type}');

          // Show user-friendly notifications for real-time updates
          if (mounted) {
            _showRealtimeUpdateNotification(update);
          }
        },
        onError: (error) {
          debugPrint('Enhanced real-time error: $error');
          setState(() {
            _isRealtimeConnected = false;
          });
        },
      );

      debugPrint('✅ Enhanced real-time system initialized for project list');
    } catch (e) {
      debugPrint('❌ Failed to initialize enhanced real-time: $e');
      setState(() {
        _isRealtimeConnected = false;
      });
    }
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
    _stopLiveReload();
    _stopLiveApiUpdates();
    _authSubscription?.cancel();

    // Stop enhanced real-time updates
    context.read<EnhancedProjectBloc>().add(const StopProjectRealtimeUpdates());
    _realtimeApiSubscription?.cancel();

    // Note: Real-time handlers are automatically cleaned up when the BLoC is disposed
    // The UniversalRealtimeHandler is a singleton and will manage its own lifecycle

    super.dispose();
  }

  /// Start the live reload timer for automatic project updates
  void _startLiveReload() {
    if (_isLiveReloadEnabled) {
      _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
        _silentRefresh();
      });
    }
  }

  /// Stop the live reload timer
  void _stopLiveReload() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Toggle live reload on/off
  void _toggleLiveReload() {
    setState(() {
      _isLiveReloadEnabled = !_isLiveReloadEnabled;
    });

    if (_isLiveReloadEnabled) {
      _startLiveReload();
      _startLiveApiUpdates();
    } else {
      _stopLiveReload();
      _stopLiveApiUpdates();
    }
  }

  /// Start live API updates using the repository stream
  void _startLiveApiUpdates() {
    if (_isLiveReloadEnabled) {
      context.read<EnhancedProjectBloc>().add(
        StartLiveProjectUpdates(query: _currentQuery, updateInterval: _refreshInterval, includeDeltas: true),
      );
    }
  }

  /// Stop live API updates
  void _stopLiveApiUpdates() {
    context.read<EnhancedProjectBloc>().add(const StopLiveProjectUpdates());
  }

  /// Silent refresh that makes fresh API calls without showing loading indicators
  void _silentRefresh() {
    if (!mounted) return;

    setState(() {
      _isSilentRefreshing = true;
    });

    // Always clear cache for silent refresh to ensure fresh data
    context.read<EnhancedProjectBloc>().add(RefreshProjectsWithCacheClear(query: _currentQuery));

    // Make fresh API request after cache clear
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      final searchTerm = _searchController.text.trim();
      if (searchTerm.isNotEmpty) {
        context.read<EnhancedProjectBloc>().add(
          SearchProjectsRequested(searchTerm: searchTerm, filters: _currentQuery),
        );
      } else {
        context.read<EnhancedProjectBloc>().add(LoadProjectsRequested(query: _currentQuery));
      }
    });

    // Hide the refresh indicator after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSilentRefreshing = false;
        });
      }
    });

    debugPrint('🔄 Project List: Silent refresh with fresh API data initiated');
  }

  void _onSearchChanged(String searchTerm) {
    if (searchTerm.isEmpty) {
      // Load all projects if search is empty
      context.read<EnhancedProjectBloc>().add(LoadProjectsRequested(query: _currentQuery));
    } else {
      // Search projects with current filters
      context.read<EnhancedProjectBloc>().add(SearchProjectsRequested(searchTerm: searchTerm, filters: _currentQuery));
    }
  }

  void _onFilterApplied(ProjectsQuery newQuery) {
    setState(() {
      _currentQuery = newQuery;
    });

    // Apply new filters
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      context.read<EnhancedProjectBloc>().add(SearchProjectsRequested(searchTerm: searchTerm, filters: newQuery));
    } else {
      context.read<EnhancedProjectBloc>().add(LoadProjectsRequested(query: newQuery));
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet<ProjectsQuery>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectFilterBottomSheet(currentQuery: _currentQuery, onApplyFilters: _onFilterApplied),
    );
  }

  /// Enhanced refresh that clears cache and makes fresh API requests
  Future<void> _onRefresh() async {
    // Stop any ongoing real-time updates temporarily during refresh
    _stopLiveApiUpdates();

    // Restart the live reload timer
    if (_isLiveReloadEnabled) {
      _stopLiveReload();
      _startLiveReload();
    }

    // Force cache clear and make fresh API requests
    try {
      final searchTerm = _searchController.text.trim();

      // Always clear cache first to ensure fresh data
      context.read<EnhancedProjectBloc>().add(RefreshProjectsWithCacheClear(query: _currentQuery));

      // Wait a bit for cache to clear, then make the fresh request
      await Future.delayed(const Duration(milliseconds: 150));

      if (mounted) {
        if (searchTerm.isNotEmpty) {
          // Perform search with fresh data from API
          context.read<EnhancedProjectBloc>().add(
            SearchProjectsRequested(searchTerm: searchTerm, filters: _currentQuery),
          );
        } else {
          // Load all projects with fresh data from API
          context.read<EnhancedProjectBloc>().add(LoadProjectsRequested(query: _currentQuery));
        }
      }

      // Restart live updates after refresh
      if (_isLiveReloadEnabled && mounted) {
        _startLiveApiUpdates();
      }

      debugPrint('✅ Project List: Refresh completed with fresh API data');
    } catch (e) {
      debugPrint('❌ Project List: Error during refresh: $e');

      // Restart live updates even if refresh failed
      if (_isLiveReloadEnabled && mounted) {
        _startLiveApiUpdates();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          // App Header
          const ProjectAppHeader(),

          // Search and Filter Bar with Real-time Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                // Real-time connection status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _isRealtimeConnected
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _isRealtimeConnected ? Colors.green : Colors.grey, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isRealtimeConnected ? Icons.wifi : Icons.wifi_off,
                        color: _isRealtimeConnected ? Colors.green : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isRealtimeConnected ? 'Live Updates Active' : 'Real-time Offline',
                        style: TextStyle(
                          color: _isRealtimeConnected ? Colors.green.shade700 : Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_isSilentRefreshing) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _isRealtimeConnected ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Project Count Badge and Live Reload Status Row
                BlocBuilder<EnhancedProjectBloc, EnhancedProjectState>(
                  builder: (context, projectState) {
                    return Row(
                      children: [
                        // Project Count Badge
                        if (projectState is EnhancedProjectsLoaded) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.folder_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  '${projectState.projectsResponse.totalCount}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  projectState.projectsResponse.totalCount == 1 ? 'project' : 'projects',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        // Live Reload Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isLiveReloadEnabled
                                ? Theme.of(context).colorScheme.secondaryContainer
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isLiveReloadEnabled
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isLiveReloadEnabled ? Icons.wifi : Icons.wifi_off,
                                size: 16,
                                color: _isLiveReloadEnabled
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isLiveReloadEnabled ? 'Live Updates: ON' : 'Live Updates: OFF',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _isLiveReloadEnabled
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_isSilentRefreshing) ...[
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _toggleLiveReload,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _isLiveReloadEnabled
                                        ? Theme.of(context).colorScheme.secondary
                                        : Theme.of(context).colorScheme.outline,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _isLiveReloadEnabled ? 'ON' : 'OFF',
                                    style: TextStyle(
                                      color: _isLiveReloadEnabled
                                          ? Theme.of(context).colorScheme.onSecondary
                                          : Theme.of(context).colorScheme.surface,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 12),

                ProjectSearchBar(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onFilterTap: _showFilterBottomSheet,
                  hintText: 'Search projects by name, client, or address...',
                  onClearSearch: () {
                    // Reload all projects when search is cleared
                    context.read<EnhancedProjectBloc>().add(LoadProjectsRequested(query: _currentQuery));
                  },
                  showActiveFilters: _currentQuery.hasActiveFilters,
                  activeFilterCount: _currentQuery.activeFilterCount,
                  currentQuery: _currentQuery,
                  onQueryChanged: (newQuery) {
                    setState(() {
                      _currentQuery = newQuery;
                    });

                    // Apply the new query immediately
                    context.read<EnhancedProjectBloc>().add(LoadProjectsRequested(query: newQuery));
                  },
                ),
              ],
            ),
          ),

          // Project List
          Expanded(child: ProjectListContent(onRefresh: _onRefresh)),
        ],
      ),

      // Floating Action Button for creating new projects
      floatingActionButton: const ProjectFloatingActionButton(),
    );
  }
}
