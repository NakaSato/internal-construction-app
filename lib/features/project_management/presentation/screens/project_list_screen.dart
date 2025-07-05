import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/services/universal_realtime_handler.dart';
import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';
import '../../application/project_bloc.dart';
import '../../domain/entities/project_api_models.dart';
import '../widgets/project_card.dart';
import '../widgets/project_search_bar.dart';
import '../widgets/project_filter_bottom_sheet.dart';

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

  // Live reload interval (30 seconds)
  static const Duration _refreshInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();

    // Initialize comprehensive real-time handler
    _realtimeHandler = getIt<UniversalRealtimeHandler>();

    // Load initial projects
    context.read<EnhancedProjectBloc>().add(const LoadProjectsRequested());

    // Start live reload timer as fallback
    _startLiveReload();

    // Initialize real-time updates based on authentication state
    _checkAuthAndInitializeRealtime();
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
              debugPrint('❌ No project ID in delete event');
              _silentRefresh(); // Fallback to refresh
            }
            break;

          case 'projectStatusChanged':
            // For status changes, we'll do a refresh to get the latest data
            _silentRefresh();
            break;

          default:
            debugPrint('⚠️ Unknown project event type: ${event.type.name}');
            _silentRefresh(); // Fallback to refresh
        }
      });

      // Register handlers for task-related events (affects project status)
      _realtimeHandler.registerTaskHandler((event) {
        debugPrint('📡 Real-time task event: ${event.type.name}');
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

      debugPrint('✅ Project List: Real-time updates initialized successfully');
    } catch (e) {
      debugPrint('❌ Project List: Failed to initialize real-time updates: $e');
      // Continue with fallback polling if real-time fails
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stopLiveReload();
    _authSubscription?.cancel();

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
    } else {
      _stopLiveReload();
    }
  }

  /// Silent refresh that doesn't show loading indicators
  void _silentRefresh() {
    if (!mounted) return;

    setState(() {
      _isSilentRefreshing = true;
    });

    final searchTerm = _searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      context.read<EnhancedProjectBloc>().add(SearchProjectsRequested(searchTerm: searchTerm, filters: _currentQuery));
    } else {
      context.read<EnhancedProjectBloc>().add(LoadProjectsRequested(query: _currentQuery));
    }

    // Hide the refresh indicator after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSilentRefreshing = false;
        });
      }
    });
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

  void _onRefresh() {
    // Restart the live reload timer
    if (_isLiveReloadEnabled) {
      _stopLiveReload();
      _startLiveReload();
    }

    final searchTerm = _searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      context.read<EnhancedProjectBloc>().add(SearchProjectsRequested(searchTerm: searchTerm, filters: _currentQuery));
    } else {
      context.read<EnhancedProjectBloc>().add(LoadProjectsRequested(query: _currentQuery));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          // App Header
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final user = authState is AuthAuthenticated ? authState.user : null;

              if (user == null) {
                return Container(
                  height: 120,
                  color: Theme.of(context).colorScheme.primary,
                  child: const Center(
                    child: Text('Please log in to continue', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                );
              }

              return BlocBuilder<EnhancedProjectBloc, EnhancedProjectState>(
                builder: (context, projectState) {
                  String subtitle = 'Manage solar installation projects';

                  // Add project count to subtitle if available
                  if (projectState is EnhancedProjectsLoaded) {
                    final count = projectState.projectsResponse.totalCount;
                    subtitle = 'Manage solar installation projects • $count project${count != 1 ? 's' : ''}';
                  }

                  return AppHeader(title: 'Project Management', subtitle: subtitle, user: user);
                },
              );
            },
          ),

          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
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
          Expanded(
            child: BlocBuilder<EnhancedProjectBloc, EnhancedProjectState>(
              builder: (context, state) {
                if (state is EnhancedProjectLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is EnhancedProjectError) {
                  return _buildErrorWidget(state);
                }

                if (state is EnhancedProjectsLoaded) {
                  return _buildProjectList(state.projectsResponse);
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),

      // Floating Action Button for creating new projects
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState is AuthAuthenticated ? authState.user : null;
          final canCreateProject = user?.roleName == 'Admin' || user?.roleName == 'Project Manager';

          if (!canCreateProject) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () => context.push('/projects/create'),
            icon: const Icon(Icons.add),
            label: const Text('New Project'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          );
        },
      ),
    );
  }

  Widget _buildProjectList(ProjectsResponse projectsResponse) {
    if (projectsResponse.items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: projectsResponse.items.length + 1, // +1 for pagination info
        itemBuilder: (context, index) {
          if (index == projectsResponse.items.length) {
            return _buildPaginationInfo(projectsResponse);
          }

          final project = projectsResponse.items[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: EnhancedProjectCard(project: project, onTap: () => context.push('/projects/${project.projectId}')),
          );
        },
      ),
    );
  }

  Widget _buildPaginationInfo(ProjectsResponse response) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Page ${response.pageNumber} of ${response.totalPages}', style: Theme.of(context).textTheme.bodySmall),
          Text('${response.totalCount} total projects', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(EnhancedProjectError error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(error.message, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            if (error.details != null) ...[
              const SizedBox(height: 8),
              Text(
                error.details!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: _onRefresh, icon: const Icon(Icons.refresh), label: const Text('Try Again')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.engineering_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No Projects Found', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'There are no projects matching your search criteria.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final user = authState is AuthAuthenticated ? authState.user : null;
                final canCreateProject = user?.roleName == 'Admin' || user?.roleName == 'Project Manager';

                if (!canCreateProject) {
                  return ElevatedButton.icon(
                    onPressed: _onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  );
                }

                return Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.push('/projects/create'),
                      icon: const Icon(Icons.add),
                      label: const Text('Create First Project'),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _onRefresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
