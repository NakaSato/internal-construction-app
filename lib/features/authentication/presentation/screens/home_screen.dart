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
                    // Project list with colored vertical bars
                    _buildProjectList(projects),
                    // New project list with colored vertical bars
                    _buildProjectList(projects),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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

  /// Builds a project list with colored vertical bars as described
  Widget _buildProjectList(List<Project> projects) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];

        // Sample colors for demonstration - in real app, could be from project data
        final colors = [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.red,
          Colors.purple,
          Colors.teal,
        ];
        final color = colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Colored vertical bar
                  Container(
                    width: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  // Project details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Project',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  project.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (project.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    project.description,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Arrow icon
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
