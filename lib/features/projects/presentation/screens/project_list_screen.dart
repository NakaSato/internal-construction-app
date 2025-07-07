import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

/// Project list screen that uses the new API-based project management system
class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final TextEditingController _searchController = TextEditingController();
  ProjectsQuery _currentQuery = const ProjectsQuery();
  Timer? _refreshTimer;
  bool _isLiveReloadEnabled = true;
  bool _isSilentRefreshing = false;
  bool _isRefreshing = false;
  late final UniversalRealtimeHandler _realtimeHandler;
  StreamSubscription? _authSubscription;

  // Enhanced real-time system variables
  StreamSubscription<RealtimeProjectUpdate>? _realtimeApiSubscription;
  StreamSubscription? _appFocusSubscription; // App focus event subscription
  late final RealtimeApiStreams _realtimeApiStreams;
  _AppLifecycleObserver? _lifecycleObserver; // App lifecycle observer
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

    // Enhanced logic for initializing or refreshing data when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOrRefreshData();

      // Check route arguments for navigation context
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args == 'fromAccountSwitch') {
        debugPrint('🔄 Project List: Account switch detected - forcing data refresh');
        _forceRefreshWithCacheClear();
      }
    });

    // Set up app lifecycle observer for refresh on resume
    _setupAppLifecycleListener();

    // Listen for app-wide focus events from RealtimeApiStreams
    _appFocusSubscription = _realtimeApiStreams.appFocusStream.listen((hasFocus) {
      if (!mounted) return;
      if (hasFocus) {
        debugPrint('🌟 Project List: App focus returned - refreshing data');
        _silentRefresh();
      }
    });
  }

  /// Initialize or refresh data based on current state
  void _initializeOrRefreshData() {
    final currentState = context.read<ProjectBloc>().state;

    if (currentState is ProjectsLoaded) {
      // Check if we have data already, but refresh if it's older than 30 seconds
      // ProjectsResponse doesn't have a timestamp, so we'll use a simple approach
      debugPrint('🔍 Project List: Has projects data, refreshing silently to ensure it\'s up to date');
      _silentRefresh();
    } else {
      debugPrint('🔍 Project List: No current projects data, initializing');
      // Check authentication and start if authenticated
      _checkAuthAndInitializeIfAuthenticated();
    }
  }

  /// Set up app lifecycle observer
  void _setupAppLifecycleListener() {
    _lifecycleObserver = _AppLifecycleObserver(
      onResume: () {
        if (!mounted) return;
        debugPrint('🌟 Project List: App lifecycle resumed - refreshing data');
        _silentRefresh();
      },
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver!);
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
    _initializeRealtime();

    // Initialize app focus listener to refresh data when app focus returns
    _initializeAppFocusListener();
  }

  /// Initialize app focus listener to refresh projects when app focus returns
  void _initializeAppFocusListener() {
    // Cancel any existing subscription
    _appFocusSubscription?.cancel();

    // Subscribe to app focus events
    _appFocusSubscription = _realtimeApiStreams.appFocusStream.listen((hasFocus) {
      if (!mounted) return;

      debugPrint('📱 Project List: App focus returned, refreshing projects data');

      // Refresh projects data when focus returns
      _forceRefreshWithCacheClear();
    });

    if (kDebugMode) {
      debugPrint('📱 Project List: App focus listener initialized');
    }
  }

  /// Clean up services when user is unauthenticated
  void _cleanupUnauthenticatedServices() {
    // Stop live reload
    if (_refreshTimer?.isActive == true) {
      _refreshTimer?.cancel();
      _isLiveReloadEnabled = false;
    }

    // Cancel app focus subscription
    _appFocusSubscription?.cancel();
    _appFocusSubscription = null;

    // Disconnect real-time services
    _disconnectRealtime();

    // Clear any existing project data
    if (mounted) {
      context.read<ProjectBloc>().add(RefreshProjectsWithCacheClear(query: const ProjectsQuery()));
    }
  }

  /// Load initial projects with fresh API data
  void _loadInitialProjectsWithFreshData() {
    // Clear any existing cache first
    context.read<ProjectBloc>().add(RefreshProjectsWithCacheClear(query: _currentQuery));

    // Then load fresh data from API
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        // Use skipLoadingState based on whether we're coming from project detail
        final bool comingFromDetail = ModalRoute.of(context)?.settings.arguments == 'fromProjectDetail';
        context.read<ProjectBloc>().add(
          LoadProjectsRequested(
            query: _currentQuery,
            skipLoadingState: comingFromDetail, // Skip loading state when returning from detail
            forceRefresh: false,
          ),
        );
        debugPrint('🚀 Project List: Initial load with fresh API data (skipLoadingState: $comingFromDetail)');
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
              final project = Project.fromJson(projectData);
              context.read<ProjectBloc>().add(RealTimeProjectCreatedReceived(project: project));
            } catch (e) {
              debugPrint('❌ Error parsing project created event: $e');
              _silentRefresh(); // Fallback to refresh
            }
            break;

          case 'projectUpdated':
            try {
              final project = Project.fromJson(projectData);
              context.read<ProjectBloc>().add(RealTimeProjectUpdateReceived(project: project));
            } catch (e) {
              debugPrint('❌ Error parsing project updated event: $e');
              _silentRefresh(); // Fallback to refresh
            }
            break;

          case 'projectDeleted':
            final projectId = projectData['id'] as String? ?? projectData['projectId'] as String?;
            if (projectId != null) {
              context.read<ProjectBloc>().add(RealTimeProjectDeletedReceived(projectId: projectId));
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
  Future<void> _initializeRealtime() async {
    try {
      // Initialize connection
      await _realtimeApiStreams.initialize();

      if (!mounted) return;

      setState(() {
        _isRealtimeConnected = _realtimeApiStreams.isConnected;
      });

      // Start enhanced real-time updates through BLoC
      context.read<ProjectBloc>().add(const StartProjectRealtimeUpdates());

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
    _appFocusSubscription?.cancel();

    // Remove lifecycle observer
    if (_lifecycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifecycleObserver!);
      _lifecycleObserver = null;
    }

    // Stop enhanced real-time updates
    context.read<ProjectBloc>().add(const StopProjectRealtimeUpdates());
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
      context.read<ProjectBloc>().add(
        StartLiveProjectUpdates(query: _currentQuery, updateInterval: _refreshInterval, includeDeltas: true),
      );
    }
  }

  /// Stop live API updates
  void _stopLiveApiUpdates() {
    context.read<ProjectBloc>().add(const StopLiveProjectUpdates());
  }

  /// Silent refresh that makes fresh API calls without showing loading indicators
  void _silentRefresh() {
    if (!mounted) return;

    setState(() {
      _isSilentRefreshing = true;
    });

    // Always clear cache for silent refresh to ensure fresh data
    context.read<ProjectBloc>().add(RefreshProjectsWithCacheClear(query: _currentQuery));

    // Make fresh API request after cache clear
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      final searchTerm = _searchController.text.trim();
      if (searchTerm.isNotEmpty) {
        context.read<ProjectBloc>().add(SearchProjectsRequested(searchTerm: searchTerm, filters: _currentQuery));
      } else {
        context.read<ProjectBloc>().add(LoadProjectsRequested(query: _currentQuery));
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
      context.read<ProjectBloc>().add(
        LoadProjectsRequested(
          query: _currentQuery,
          skipLoadingState: true, // Skip loading state for better UX during search
        ),
      );
    } else {
      // Search projects with current filters
      context.read<ProjectBloc>().add(SearchProjectsRequested(searchTerm: searchTerm, filters: _currentQuery));
    }
  }

  void _onFilterApplied(ProjectsQuery newQuery) {
    setState(() {
      _currentQuery = newQuery;
    });

    // Apply new filters
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      context.read<ProjectBloc>().add(SearchProjectsRequested(searchTerm: searchTerm, filters: newQuery));
    } else {
      context.read<ProjectBloc>().add(
        LoadProjectsRequested(
          query: newQuery,
          skipLoadingState: false, // Show loading state when applying filters
          forceRefresh: true, // Always get fresh data when filters change
        ),
      );
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
      context.read<ProjectBloc>().add(RefreshProjectsWithCacheClear(query: _currentQuery));

      // Wait a bit for cache to clear, then make the fresh request
      await Future.delayed(const Duration(milliseconds: 150));

      if (mounted) {
        if (searchTerm.isNotEmpty) {
          // Perform search with fresh data from API
          context.read<ProjectBloc>().add(SearchProjectsRequested(searchTerm: searchTerm, filters: _currentQuery));
        } else {
          // Load all projects with fresh data from API, but preserve state
          context.read<ProjectBloc>().add(
            LoadProjectsRequested(
              query: _currentQuery,
              skipLoadingState: true, // Skip loading state to prevent flickering
              forceRefresh: true, // But still force a data refresh
            ),
          );
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

  /// Force refresh that clears cache and shows loading indicator
  void _forceRefreshWithCacheClear() {
    if (kDebugMode) {
      debugPrint('🔄 ProjectListScreen: Force refreshing projects with cache clear');
    }

    // Check authentication state before refreshing
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      debugPrint('⚠️ ProjectListScreen: Cannot refresh - user not authenticated');
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
        debugPrint('✅ ProjectListScreen: Refresh with cache clear initiated');
      }
    } catch (e) {
      debugPrint('❌ ProjectListScreen: Error refreshing projects: $e');
    }

    // Hide the refresh indicator after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // App Header with subtle elevation
          Container(
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
          ),

          // Search and Filter Bar with Real-time Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                // Real-time connection status
                AnimatedContainer(
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
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status indicator
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated pulsing dot
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 1000),
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isRealtimeConnected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                              boxShadow: _isRealtimeConnected
                                  ? [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                            onPressed: _forceRefreshWithCacheClear,
                            icon: Icon(
                              Icons.refresh_rounded,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
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

                          if (_isSilentRefreshing) ...[
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Project Count Badge and Live Reload Status Row
                BlocBuilder<ProjectBloc, ProjectState>(
                  builder: (context, projectState) {
                    return Row(
                      children: [
                        // Project Count Badge
                        if (projectState is ProjectsLoaded) ...[
                          AnimatedContainer(
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
                                  child: Icon(
                                    Icons.folder_rounded,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${projectState.projectsResponse.totalCount} ',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: projectState.projectsResponse.totalCount == 1 ? 'project' : 'projects',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.secondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],

                        // Live Reload Status Badge
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isLiveReloadEnabled
                                ? Theme.of(context).colorScheme.tertiaryContainer
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _isLiveReloadEnabled
                                      ? Theme.of(context).colorScheme.tertiary.withOpacity(0.2)
                                      : Theme.of(context).colorScheme.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isLiveReloadEnabled ? Icons.sync : Icons.sync_disabled,
                                  size: 14,
                                  color: _isLiveReloadEnabled
                                      ? Theme.of(context).colorScheme.tertiary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Auto Updates',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: _isLiveReloadEnabled
                                      ? Theme.of(context).colorScheme.tertiary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (_isSilentRefreshing) ...[
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _isLiveReloadEnabled
                                          ? Theme.of(context).colorScheme.tertiary
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 12),
                              // Enhanced toggle switch
                              GestureDetector(
                                onTap: _toggleLiveReload,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 48,
                                  height: 24,
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: _isLiveReloadEnabled
                                        ? Theme.of(context).colorScheme.tertiary
                                        : Theme.of(context).colorScheme.surfaceVariant,
                                  ),
                                  child: Stack(
                                    children: [
                                      AnimatedPositioned(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        left: _isLiveReloadEnabled ? 24 : 0,
                                        top: 0,
                                        bottom: 0,
                                        width: 22,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context).colorScheme.surface,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 2,
                                                spreadRadius: 0.5,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Icon(
                                              _isLiveReloadEnabled ? Icons.check : Icons.close,
                                              size: 12,
                                              color: _isLiveReloadEnabled
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
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Enhanced search bar with elegant styling
                Container(
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
                      onChanged: _onSearchChanged,
                      onFilterTap: _showFilterBottomSheet,
                      hintText: 'Search projects by name, client, or address...',
                      onClearSearch: () {
                        // Reload all projects when search is cleared
                        context.read<ProjectBloc>().add(LoadProjectsRequested(query: _currentQuery));
                      },
                      showActiveFilters: _currentQuery.hasActiveFilters,
                      activeFilterCount: _currentQuery.activeFilterCount,
                      currentQuery: _currentQuery,
                      onQueryChanged: (newQuery) {
                        setState(() {
                          _currentQuery = newQuery;
                        });

                        // Apply the new query immediately
                        context.read<ProjectBloc>().add(LoadProjectsRequested(query: newQuery));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Project List with enhanced styling
          Expanded(
            child: Container(
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
              clipBehavior: Clip.antiAlias, // Ensures content respects the border radius
              child: ProjectListContent(onRefresh: _onRefresh),
            ),
          ),
        ],
      ),

      // Floating Action Button with enhanced styling
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 8),
        child: const ProjectFloatingActionButton(),
      ),
    );
  }
}

/// Observer class to handle app lifecycle events
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;

  _AppLifecycleObserver({required this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // App has resumed from background
      onResume();
    }
  }
}
