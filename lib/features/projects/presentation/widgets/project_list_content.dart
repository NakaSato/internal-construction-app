import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';
import '../../application/project_bloc.dart';
import '../../domain/entities/project_api_models.dart';
import 'project_card.dart';

/// Widget that handles the main project list content including
/// loading states, error states, and the actual project list
class ProjectListContent extends StatelessWidget {
  final VoidCallback onRefresh;

  const ProjectListContent({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProjectError) {
          return _buildErrorWidget(context, state);
        }

        if (state is ProjectsLoaded) {
          return _buildProjectList(context, state.projectsResponse);
        }

        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildProjectList(BuildContext context, ProjectsResponse projectsResponse) {
    if (projectsResponse.items.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: projectsResponse.items.length + 1, // +1 for pagination info
        itemBuilder: (context, index) {
          if (index == projectsResponse.items.length) {
            return _buildPaginationInfo(context, projectsResponse);
          }

          final project = projectsResponse.items[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: ProjectCard(project: project, onTap: () => context.push('/projects/${project.projectId}')),
          );
        },
      ),
    );
  }

  Widget _buildPaginationInfo(BuildContext context, ProjectsResponse response) {
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

  Widget _buildErrorWidget(BuildContext context, ProjectError error) {
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
            ElevatedButton.icon(onPressed: onRefresh, icon: const Icon(Icons.refresh), label: const Text('Try Again')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                    onPressed: onRefresh,
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
                      onPressed: onRefresh,
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
