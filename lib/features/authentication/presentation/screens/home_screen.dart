import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../project_management/application/project_bloc.dart';
import '../../../project_management/application/project_event.dart';
import '../../../project_management/application/project_state.dart';
import '../../../project_management/domain/entities/project.dart';
import '../../application/auth_bloc.dart';
import '../../application/auth_event.dart';
import '../../application/auth_state.dart';
import '../../domain/entities/user.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(body: LoadingIndicator());
          }

          if (state is AuthAuthenticated) {
            return _buildAuthenticatedHome(context, state);
          }

          // For unauthenticated state, the listener will handle navigation
          return const Scaffold(body: LoadingIndicator());
        },
      ),
    );
  }

  Widget _buildAuthenticatedHome(
    BuildContext context,
    AuthAuthenticated state,
  ) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Flutter Architecture App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(context, state.user),
            const SizedBox(height: 24),
            _buildProjectsSection(context),
            const SizedBox(height: 24),
            _buildFeatureGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (user.name.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(user.name, style: Theme.of(context).textTheme.titleMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsSection(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProjectBloc(context.read())..add(const ProjectLoadRequested()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Projects',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () {
                  context.read<ProjectBloc>().add(
                    const ProjectRefreshRequested(),
                  );
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh projects',
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<ProjectBloc, ProjectState>(
            builder: (context, state) {
              if (state is ProjectLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is ProjectError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load projects',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ProjectBloc>().add(
                              const ProjectLoadRequested(),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is ProjectLoaded || state is ProjectOperationSuccess) {
                final projects = state is ProjectLoaded
                    ? state.projects
                    : (state as ProjectOperationSuccess).projects;

                if (projects.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          const Icon(Icons.folder_open, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'No projects yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create your first project to get started',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Project count and status summary
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.folder,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${projects.length} Projects',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            _buildProjectStats(context, projects),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Enhanced project list
                    _buildEnhancedProjectList(context, projects),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.image,
        title: 'Image Upload',
        subtitle: 'Manage your images',
        route: AppRoutes.imageUpload,
      ),
      _FeatureItem(
        icon: Icons.location_on,
        title: 'Location Tracking',
        subtitle: 'Track your location',
        route: AppRoutes.locationTracking,
      ),
      _FeatureItem(
        icon: Icons.calendar_today,
        title: 'Work Calendar',
        subtitle: 'Manage your schedule',
        route: AppRoutes.calendar,
      ),
      _FeatureItem(
        icon: Icons.calendar_view_month,
        title: 'Enhanced Calendar',
        subtitle: 'Interactive project calendar',
        route: '/calendar-demo',
      ),
      _FeatureItem(
        icon: Icons.person,
        title: 'Profile',
        subtitle: 'Manage your profile',
        route: AppRoutes.profile,
      ),
      _FeatureItem(
        icon: Icons.view_list,
        title: 'Project List Demo',
        subtitle: 'New styled project list',
        route: '/project-list-demo',
      ),
      _FeatureItem(
        icon: Icons.calendar_month,
        title: 'Calendar API Demo',
        subtitle: 'Full calendar management',
        route: '/calendar-api-demo',
      ),
      _FeatureItem(
        icon: Icons.assignment,
        title: 'Daily Reports',
        subtitle: 'Field reports management',
        route: '/daily-reports-demo',
      ),
      _FeatureItem(
        icon: Icons.photo_library,
        title: 'Project Gallery',
        subtitle: 'Visual project cards',
        route: '/image-project-cards',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Features', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _buildFeatureCard(context, feature);
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureItem feature) {
    return Card(
      child: InkWell(
        onTap: () => context.go(feature.route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                feature.icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                feature.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectStats(BuildContext context, List<Project> projects) {
    final completedCount = projects
        .where((p) => p.status == ProjectStatus.completed)
        .length;
    final inProgressCount = projects
        .where((p) => p.status == ProjectStatus.inProgress)
        .length;
    final overdueCount = projects.where((p) => p.isOverdue).length;

    return Row(
      children: [
        _buildStatChip(
          context,
          'Completed',
          completedCount.toString(),
          Colors.green,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          context,
          'In Progress',
          inProgressCount.toString(),
          Colors.orange,
        ),
        if (overdueCount > 0) ...[
          const SizedBox(width: 8),
          _buildStatChip(
            context,
            'Overdue',
            overdueCount.toString(),
            Colors.red,
          ),
        ],
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    String count,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            count,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  /// Builds an enhanced project list with more detailed information
  Widget _buildEnhancedProjectList(
    BuildContext context,
    List<Project> projects,
  ) {
    return Column(
      children: [
        // Show "View All" button if there are more than 3 projects
        if (projects.length > 3) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Projects',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                onPressed: () => context.go('/project-list-demo'),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Show only first 3 projects on home screen
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: projects.length > 3 ? 3 : projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return _buildEnhancedProjectCard(context, project, index);
          },
        ),

        // Add project button
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Navigate to add project screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add Project feature coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Project'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedProjectCard(
    BuildContext context,
    Project project,
    int index,
  ) {
    // Get color based on project status
    Color getStatusColor() {
      switch (project.status) {
        case ProjectStatus.planning:
          return Colors.grey;
        case ProjectStatus.inProgress:
          return Colors.orange;
        case ProjectStatus.completed:
          return Colors.green;
        case ProjectStatus.onHold:
          return Colors.amber;
        case ProjectStatus.cancelled:
          return Colors.red;
      }
    }

    // Get priority color
    Color getPriorityColor() {
      switch (project.priority) {
        case ProjectPriority.low:
          return Colors.blue;
        case ProjectPriority.medium:
          return Colors.orange;
        case ProjectPriority.high:
          return Colors.red;
        case ProjectPriority.urgent:
          return Colors.purple;
      }
    }

    final statusColor = getStatusColor();
    final priorityColor = getPriorityColor();
    final isOverdue = project.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Status indicator bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),

            // Project content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project name and priority
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isOverdue
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Priority indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: priorityColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            project.priority.name.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: priorityColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Description
                    if (project.description.isNotEmpty) ...[
                      Text(
                        project.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Progress and status row
                    Row(
                      children: [
                        // Progress indicator
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progress',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  Text(
                                    '${project.completionPercentage}%',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: project.completionPercentage / 100,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  project.completionPercentage == 100
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Status and due date
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  project.status.name
                                      .replaceAll('_', ' ')
                                      .toUpperCase(),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                ),
                              ),

                              // Due date
                              if (project.dueDate != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Due: ${_formatDate(project.dueDate!)}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: isOverdue
                                            ? Colors.red
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                        fontSize: 10,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Action button
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () {
                  // TODO: Navigate to project details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening ${project.name} details...'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                tooltip: 'View project details',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return '${difference.abs()}d ago';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return '${difference}d left';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}
