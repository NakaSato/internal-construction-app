import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../application/auth_bloc.dart';
import '../../application/auth_event.dart';
import '../../application/auth_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Static project data
  final List<Map<String, dynamic>> _staticProjects = [
    {
      'id': '1',
      'name': 'E-Commerce Mobile App',
      'description':
          'A modern e-commerce app with Flutter and Firebase backend integration',
      'status': 'active',
      'progress': 0.75,
      'teamMembers': 4,
      'deadline': DateTime.now().add(const Duration(days: 15)),
      'tags': ['Flutter', 'Firebase', 'E-commerce'],
      'priority': 'high',
    },
    {
      'id': '2',
      'name': 'Weather Dashboard',
      'description':
          'Real-time weather data visualization with interactive charts',
      'status': 'completed',
      'progress': 1.0,
      'teamMembers': 2,
      'deadline': DateTime.now().subtract(const Duration(days: 5)),
      'tags': ['React', 'D3.js', 'API'],
      'priority': 'medium',
    },
    {
      'id': '3',
      'name': 'Task Management System',
      'description': 'Collaborative task management with real-time updates',
      'status': 'active',
      'progress': 0.45,
      'teamMembers': 6,
      'deadline': DateTime.now().add(const Duration(days: 30)),
      'tags': ['Vue.js', 'Node.js', 'WebSocket'],
      'priority': 'high',
    },
    {
      'id': '4',
      'name': 'Social Media Analytics',
      'description':
          'Analytics dashboard for social media metrics and insights',
      'status': 'planning',
      'progress': 0.1,
      'teamMembers': 3,
      'deadline': DateTime.now().add(const Duration(days: 60)),
      'tags': ['Python', 'Django', 'ML'],
      'priority': 'low',
    },
  ];

  @override
  void initState() {
    super.initState();
    // No need to load projects since we're using static data
  }

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
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
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
            _buildProjectsSection(context),
            const SizedBox(height: 24),
            _buildFeatureGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Projects',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View All Projects tapped')),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildProjectStatistics(context),
        const SizedBox(height: 20),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _staticProjects.length,
            itemBuilder: (context, index) {
              final project = _staticProjects[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < _staticProjects.length - 1 ? 16 : 0,
                ),
                child: _buildProjectCard(context, project),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProjectStatistics(BuildContext context) {
    final activeProjects = _staticProjects
        .where((p) => p['status'] == 'active')
        .length;
    final completedProjects = _staticProjects
        .where((p) => p['status'] == 'completed')
        .length;
    final planningProjects = _staticProjects
        .where((p) => p['status'] == 'planning')
        .length;
    final totalTeamMembers = _staticProjects.fold<int>(
      0,
      (sum, p) => sum + (p['teamMembers'] as int),
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Active',
            activeProjects.toString(),
            Icons.play_circle_outline,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Completed',
            completedProjects.toString(),
            Icons.check_circle_outline,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Planning',
            planningProjects.toString(),
            Icons.schedule_outlined,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Team',
            totalTeamMembers.toString(),
            Icons.people_outline,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Map<String, dynamic> project) {
    final status = project['status'] as String;
    final progress = project['progress'] as double;
    final tags = project['tags'] as List<String>;
    final teamMembers = project['teamMembers'] as int;
    final deadline = project['deadline'] as DateTime;
    final priority = project['priority'] as String;

    final statusColor = _getStatusColor(status);
    final priorityColor = _getPriorityColor(priority);

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project['name'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priority.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            project['description'],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (status != 'planning') ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Theme.of(
                          context,
                        ).dividerColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$teamMembers',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deadline',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      _formatDate(deadline),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags
                  .take(3)
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'planning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return '${difference.abs()} days ago';
    } else if (difference == 0) {
      return 'Today';
    } else {
      return 'In $difference days';
    }
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildFeatureCard(
              context,
              'Calendar',
              Icons.calendar_today,
              Colors.blue,
              () => context.push(AppRoutes.calendar),
            ),
            _buildFeatureCard(
              context,
              'Calendar Management',
              Icons.event_note,
              Colors.green,
              () => context.push(AppRoutes.calendarManagement),
            ),
            _buildFeatureCard(
              context,
              'Project List Demo',
              Icons.assignment,
              Colors.orange,
              () => context.go('/dashboard/project-list-demo'),
            ),
            _buildFeatureCard(
              context,
              'Profile',
              Icons.person,
              Colors.purple,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
            ),
          ],
        );
      },
    );
  }
}
