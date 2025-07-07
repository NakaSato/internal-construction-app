import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../features/projects/application/project_bloc.dart';
import '../../../features/projects/domain/entities/project_api_models.dart';
import '../../../features/projects/presentation/widgets/project_card.dart';
import '../../permissions/presentation/widgets/permission_widgets.dart';

/// Project list section with loading, empty, and error states
/// Uses composition pattern with smaller, focused components
class ProjectListSection extends StatefulWidget {
  const ProjectListSection({super.key});

  @override
  State<ProjectListSection> createState() => _ProjectListSectionState();
}

class _ProjectListSectionState extends State<ProjectListSection> {
  @override
  void initState() {
    super.initState();
    // Load projects if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialProjectsIfNeeded();
    });
  }

  /// Helper method to load initial projects if needed
  void _loadInitialProjectsIfNeeded() {
    final state = context.read<ProjectBloc>().state;
    if (state is! ProjectsLoaded && state is! ProjectLoading) {
      context.read<ProjectBloc>().add(
        const LoadProjectsRequested(
          query: ProjectsQuery(
            pageSize: 1000, // Load up to 1000 projects to show all
            pageNumber: 1,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section with title and create button
        _ProjectListHeader(),
        SizedBox(height: 16),
        // Content section - Uses the shared ProjectBloc instance from app level
        _ProjectListContent(),
      ],
    );
  }
}

/// Dedicated header component for project list
/// Uses const constructor for better performance
class _ProjectListHeader extends StatelessWidget {
  const _ProjectListHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _SectionTitle(),
        // Permission-aware Create Project button
        const _CreateProjectButton(),
      ],
    );
  }
}

/// Dedicated content component for project list
/// Uses BlocBuilder for reactive UI
class _ProjectListContent extends StatelessWidget {
  const _ProjectListContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoading) {
          return const _LoadingState();
        } else if (state is ProjectsLoaded) {
          final allProjects = state.projectsResponse.items;

          if (allProjects.isEmpty) {
            return const _EmptyState();
          }

          return _ProjectList(projects: allProjects);
        } else if (state is ProjectError) {
          return _ErrorState(message: state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  // _buildHeader has been replaced with _ProjectListHeader class
}

/// Dedicated section title component
/// Uses const constructor for better performance
class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      'Projects',
      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
    );
  }
}

/// Dedicated create project button component
/// Uses const constructor for better performance
class _CreateProjectButton extends StatelessWidget {
  const _CreateProjectButton();

  @override
  Widget build(BuildContext context) {
    return PermissionBuilder(
      resource: 'projects',
      action: 'create',
      fallback: const SizedBox.shrink(),
      loading: const SizedBox.shrink(),
      builder: (context, hasPermission) {
        if (!hasPermission) {
          return const SizedBox.shrink();
        }

        return _ActionButton(onPressed: () => context.push('/projects/create'), label: 'Create Project');
      },
    );
  }
}

/// Reusable action button component
/// Uses const constructor for better performance
class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const _ActionButton({required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

/// Loading state widget
/// Optimized with const constructors and broken down into smaller focused components
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 200, child: Center(child: _LoadingIndicator()));
  }
}

/// Dedicated loading indicator component
/// Uses const constructor for better performance
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text('Loading projects...', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

/// Empty state widget
/// Uses composition pattern with smaller, focused components
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: _EmptyStateContent());
  }
}

/// Dedicated content for the empty state
/// Uses const constructor for better performance
class _EmptyStateContent extends StatelessWidget {
  const _EmptyStateContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon container
        _EmptyStateIcon(color: colorScheme.surfaceContainerHighest, iconColor: colorScheme.onSurfaceVariant),
        const SizedBox(height: 8),
        // Title
        Text(
          'No projects yet',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 2),
        // Subtitle
        Flexible(
          child: Text(
            'Projects will appear here once they are created',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Dedicated icon component for empty state
/// Uses const constructor for better performance
class _EmptyStateIcon extends StatelessWidget {
  final Color color;
  final Color iconColor;

  const _EmptyStateIcon({required this.color, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(Icons.folder_open_outlined, size: 20, color: iconColor),
    );
  }
}

/// Error state widget
class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight.isFinite ? constraints.maxHeight.toDouble() : 120.0;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: availableHeight, maxHeight: availableHeight),
            child: _buildAdaptiveErrorLayout(context, availableHeight),
          ),
        );
      },
    );
  }

  Widget _buildAdaptiveErrorLayout(BuildContext context, double height) {
    // Determine layout based on available height
    if (height > 180) {
      return _buildFullErrorLayout(context, height);
    } else if (height > 100) {
      return _buildCompactErrorLayout(context, height);
    } else {
      return _buildMiniErrorLayout(context, height);
    }
  }

  Widget _buildFullErrorLayout(BuildContext context, double height) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 28, color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load projects',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                context.read<ProjectBloc>().add(
                  const RefreshProjectsWithCacheClear(
                    query: ProjectsQuery(
                      pageSize: 250, // Load up to 250 projects to show all
                      pageNumber: 1,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Try Again'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactErrorLayout(BuildContext context, double height) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(6),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 20, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 3),
            Text(
              'Failed to load',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: 22,
              child: OutlinedButton(
                onPressed: () {
                  context.read<ProjectBloc>().add(
                    const RefreshProjectsWithCacheClear(
                      query: ProjectsQuery(
                        pageSize: 1000, // Load up to 1000 projects to show all
                        pageNumber: 1,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  minimumSize: const Size(0, 22),
                  textStyle: const TextStyle(fontSize: 10),
                ),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniErrorLayout(BuildContext context, double height) {
    // For extremely small heights, show just icon and button
    final isExtremelySmall = height < 50;

    return Container(
      height: height,
      padding: const EdgeInsets.all(2),
      child: Center(
        child: isExtremelySmall
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 12, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 18,
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<ProjectBloc>().add(
                          const RefreshProjectsWithCacheClear(
                            query: ProjectsQuery(
                              pageSize: 1000, // Load up to 1000 projects to show all
                              pageNumber: 1,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        minimumSize: const Size(0, 18),
                        textStyle: const TextStyle(fontSize: 7),
                      ),
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 16, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      'Failed to load',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 20,
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<ProjectBloc>().add(
                          const RefreshProjectsWithCacheClear(
                            query: ProjectsQuery(
                              pageSize: 1000, // Load up to 1000 projects to show all
                              pageNumber: 1,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        minimumSize: const Size(0, 20),
                        textStyle: const TextStyle(fontSize: 9),
                      ),
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Project list widget
/// Project list widget
/// Optimized with const constructors and broken down into smaller components
class _ProjectList extends StatelessWidget {
  final List<Project> projects;

  const _ProjectList({required this.projects});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Use cache-clearing refresh for fresh data
        context.read<ProjectBloc>().add(
          const RefreshProjectsWithCacheClear(
            query: const ProjectsQuery(
              pageSize: 1000, // Load up to 1000 projects to show all
              pageNumber: 1,
            ),
          ),
        );
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: _ProjectListView(projects: projects),
    );
  }
}

/// Dedicated list view component for projects
/// Uses const constructor for better performance
class _ProjectListView extends StatelessWidget {
  final List<Project> projects;

  const _ProjectListView({required this.projects});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _AnimatedProjectCard(
          project: project,
          index: index,
          onTap: () => context.push('/projects/${project.projectId}'),
        );
      },
    );
  }
}

/// Dedicated animated project card component
/// Extracts animation logic from the list builder
class _AnimatedProjectCard extends StatelessWidget {
  final Project project;
  final int index;
  final VoidCallback onTap;

  const _AnimatedProjectCard({required this.project, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 16),
      child: ProjectCard(project: project, onTap: onTap, index: index),
    );
  }
}

// _EnhancedProjectCard class was moved to project_card.dart
