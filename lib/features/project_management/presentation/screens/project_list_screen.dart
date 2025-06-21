import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';
import '../../application/project_bloc.dart';
import '../../domain/entities/project_api_models.dart';
import '../widgets/enhanced_project_card.dart';
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

  @override
  void initState() {
    super.initState();
    // Load initial projects
    context.read<EnhancedProjectBloc>().add(const LoadProjectsRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        backgroundColor: Colors.grey[50],
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
              color: Colors.white,
              child: Column(
                children: [
                  ProjectSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onFilterTap: _showFilterBottomSheet,
                    hintText: 'Search projects...',
                  ),
                  const SizedBox(height: 8),
                  _buildActiveFiltersChips(),
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

  Widget _buildActiveFiltersChips() {
    final activeFilters = <Widget>[];

    // Status filter
    if (_currentQuery.status?.isNotEmpty == true) {
      activeFilters.add(
        Chip(
          label: Text('Status: ${_currentQuery.status}'),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () => _onFilterApplied(_currentQuery.copyWith(status: '')),
        ),
      );
    }

    // Project manager filter
    if (_currentQuery.managerId?.isNotEmpty == true) {
      activeFilters.add(
        Chip(
          label: const Text('Manager Filter'),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () =>
              _onFilterApplied(_currentQuery.copyWith(managerId: '')),
        ),
      );
    }

    // Sort filter
    if (_currentQuery.sortBy?.isNotEmpty == true) {
      activeFilters.add(
        Chip(
          label: Text('Sort: ${_currentQuery.sortBy}'),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () => _onFilterApplied(_currentQuery.copyWith(sortBy: '')),
        ),
      );
    }

    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: activeFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) => activeFilters[index],
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
        padding: const EdgeInsets.all(16),
        itemCount: projectsResponse.items.length + 1, // +1 for pagination info
        itemBuilder: (context, index) {
          if (index == projectsResponse.items.length) {
            return _buildPaginationInfo(projectsResponse);
          }

          final project = projectsResponse.items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
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
