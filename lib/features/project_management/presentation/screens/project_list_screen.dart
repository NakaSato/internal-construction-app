import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_header.dart';
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
  State<EnhancedProjectListScreen> createState() =>
      _EnhancedProjectListScreenState();
}

class _EnhancedProjectListScreenState extends State<EnhancedProjectListScreen> {
  final TextEditingController _searchController = TextEditingController();
  ProjectsQuery _currentQuery = const ProjectsQuery();
  Timer? _refreshTimer;
  bool _isLiveReloadEnabled = true;
  bool _isSilentRefreshing = false;
  
  // Live reload interval (30 seconds)
  static const Duration _refreshInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    // Load initial projects
    context.read<EnhancedProjectBloc>().add(const LoadProjectsRequested());
    
    // Start live reload timer
    _startLiveReload();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stopLiveReload();
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
      context.read<EnhancedProjectBloc>().add(
        SearchProjectsRequested(
          searchTerm: searchTerm, 
          filters: _currentQuery,
        ),
      );
    } else {
      context.read<EnhancedProjectBloc>().add(
        LoadProjectsRequested(query: _currentQuery),
      );
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
      context.read<EnhancedProjectBloc>().add(
        LoadProjectsRequested(query: _currentQuery),
      );
    } else {
      // Search projects with current filters
      context.read<EnhancedProjectBloc>().add(
        SearchProjectsRequested(searchTerm: searchTerm, filters: _currentQuery),
      );
    }
  }

  void _onFilterApplied(ProjectsQuery newQuery) {
    setState(() {
      _currentQuery = newQuery;
    });

    // Apply new filters
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      context.read<EnhancedProjectBloc>().add(
        SearchProjectsRequested(searchTerm: searchTerm, filters: newQuery),
      );
    } else {
      context.read<EnhancedProjectBloc>().add(
        LoadProjectsRequested(query: newQuery),
      );
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet<ProjectsQuery>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectFilterBottomSheet(
        currentQuery: _currentQuery,
        onApplyFilters: _onFilterApplied,
      ),
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
      context.read<EnhancedProjectBloc>().add(
        SearchProjectsRequested(searchTerm: searchTerm, filters: _currentQuery),
      );
    } else {
      context.read<EnhancedProjectBloc>().add(
        LoadProjectsRequested(query: _currentQuery),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<EnhancedProjectBloc>(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        body: Column(
          children: [
            // App Header
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final user = authState is AuthAuthenticated
                    ? authState.user
                    : null;

                if (user == null) {
                  return Container(
                    height: 120,
                    color: Theme.of(context).colorScheme.primary,
                    child: const Center(
                      child: Text(
                        'Please log in to continue',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                }

                return AppHeader(
                  title: 'Project Management',
                  subtitle: 'Manage solar installation projects',
                  user: user,
                );
              },
            ),

            // Search and Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Live Reload Status Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: _isLiveReloadEnabled 
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isLiveReloadEnabled
                          ? Theme.of(context).colorScheme.primary
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
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isLiveReloadEnabled ? 'Live Updates: ON' : 'Live Updates: OFF',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _isLiveReloadEnabled
                              ? Theme.of(context).colorScheme.primary
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
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
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _isLiveReloadEnabled ? 'ON' : 'OFF',
                              style: TextStyle(
                                color: _isLiveReloadEnabled
                                  ? Theme.of(context).colorScheme.onPrimary
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
                  
                  ProjectSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onFilterTap: _showFilterBottomSheet,
                    hintText: 'Search projects by name, client, or address...',
                    onClearSearch: () {
                      // Reload all projects when search is cleared
                      context.read<EnhancedProjectBloc>().add(
                        LoadProjectsRequested(query: _currentQuery),
                      );
                    },
                    showActiveFilters: _currentQuery.hasActiveFilters,
                    activeFilterCount: _currentQuery.activeFilterCount,
                    currentQuery: _currentQuery,
                    onQueryChanged: (newQuery) {
                      setState(() {
                        _currentQuery = newQuery;
                      });

                      // Apply the new query immediately
                      context.read<EnhancedProjectBloc>().add(
                        LoadProjectsRequested(query: newQuery),
                      );
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
            final canCreateProject =
                user?.roleName == 'Admin' ||
                user?.roleName == 'Project Manager';

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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: EnhancedProjectCard(
              project: project,
              onTap: () => context.push('/projects/${project.projectId}'),
            ),
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
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page ${response.pageNumber} of ${response.totalPages}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '${response.totalCount} total projects',
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error.message,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (error.details != null) ...[
              const SizedBox(height: 8),
              Text(
                error.details!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
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
            Icon(
              Icons.engineering_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Projects Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'There are no projects matching your search criteria.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final user = authState is AuthAuthenticated
                    ? authState.user
                    : null;
                final canCreateProject =
                    user?.roleName == 'Admin' ||
                    user?.roleName == 'Project Manager';

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
