import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../application/project_bloc.dart';
import '../../application/project_event.dart';
import '../../application/project_state.dart';
import '../../domain/entities/project.dart';
import '../../../daily_reports/presentation/screens/daily_reports_screen.dart';
import '../../../daily_reports/application/cubits/daily_reports_cubit.dart';
import '../../../daily_reports/domain/usecases/get_daily_reports.dart';
import '../../../daily_reports/domain/usecases/get_daily_report_by_id.dart';
import '../../../daily_reports/domain/usecases/create_daily_report.dart';
import '../../../daily_reports/domain/usecases/update_daily_report.dart';
import '../../../daily_reports/domain/usecases/delete_daily_report.dart';
import '../../../daily_reports/domain/usecases/upload_daily_report_image.dart';
import '../../../daily_reports/infrastructure/repositories/mock_daily_report_repository.dart';
import '../../../work_request_approval/presentation/screens/my_work_requests_screen.dart';
import '../../../work_request_approval/application/cubits/my_work_requests_cubit.dart';
import '../../../work_request_approval/domain/usecases/get_my_work_requests_usecase.dart';
import '../../../work_request_approval/infrastructure/repositories/mock_work_request_approval_repository.dart';

/// Screen to display detailed information about a specific project
class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late ProjectBloc _projectBloc;
  Project? _project;

  @override
  void initState() {
    super.initState();
    _projectBloc = GetIt.instance<ProjectBloc>();
    _projectBloc.add(const ProjectLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider.value(
        value: _projectBloc,
        child: BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, state) {
            if (state is ProjectLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading project details...'),
                  ],
                ),
              );
            }

            if (state is ProjectError) {
              return _buildErrorView(context, state.message);
            }

            if (state is ProjectLoaded) {
              // Find the specific project by ID
              try {
                _project = state.projects.firstWhere(
                  (project) => project.projectId == widget.projectId,
                );
                return _buildProjectDetailView(context, _project!);
              } catch (e) {
                return _buildProjectNotFoundView(context);
              }
            }

            return const Center(child: Text('No project data available'));
          },
        ),
      ),
    );
  }

  Widget _buildProjectDetailView(BuildContext context, Project project) {
    return CustomScrollView(
      slivers: [
        // App Bar with Project Image
        _buildSliverAppBar(context, project),

        // Project Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Overview Card
                _buildProjectOverviewCard(context, project),

                const SizedBox(height: 16),

                // Project Details Card
                _buildProjectDetailsCard(context, project),

                const SizedBox(height: 16),

                // Progress & Tasks Card
                _buildProgressTasksCard(context, project),

                const SizedBox(height: 16),

                // Timeline Card
                _buildTimelineCard(context, project),

                const SizedBox(height: 16),

                // Daily Reports Card
                _buildDailyReportsCard(context, project),

                const SizedBox(height: 16),

                // Work Requests Card
                _buildWorkRequestsCard(context, project),

                const SizedBox(height: 16),

                // Project Manager Card
                if (project.projectManager != null)
                  _buildProjectManagerCard(context, project.projectManager!),

                const SizedBox(height: 16),

                // Additional Info Card
                _buildAdditionalInfoCard(context, project),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Project project) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          project.projectName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Project Image or Default Background
            if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
              Image.network(
                project.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultBackground(context);
                },
              )
            else
              _buildDefaultBackground(context),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editProject(context, project);
                break;
              case 'delete':
                _deleteProject(context, project);
                break;
              case 'share':
                _shareProject(context, project);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Project'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share Project'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Delete Project',
                  style: TextStyle(color: Colors.red),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.solar_power,
          size: 80,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildProjectOverviewCard(BuildContext context, Project project) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Project Overview',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusChip(context, project.projectStatus),
            const SizedBox(height: 16),
            if (project.description.isNotEmpty) ...[
              Text(
                project.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project.address,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDetailsCard(BuildContext context, Project project) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Project Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Project ID', project.projectId),
            _buildDetailRow('Client', project.clientInfo),
            _buildDetailRow('Priority', project.priority.displayName),
            if (project.tags.isNotEmpty) _buildTagsRow(context, project.tags),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTasksCard(BuildContext context, Project project) {
    final progressPercentage = project.completionPercentage;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.track_changes,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Progress & Tasks',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Overall Progress',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '$progressPercentage%',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getProgressColor(progressPercentage),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progressPercentage / 100,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(progressPercentage),
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tasks Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTaskStat(
                      context,
                      'Completed',
                      project.completedTaskCount.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  Expanded(
                    child: _buildTaskStat(
                      context,
                      'Remaining',
                      (project.taskCount - project.completedTaskCount)
                          .toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  Expanded(
                    child: _buildTaskStat(
                      context,
                      'Total',
                      project.taskCount.toString(),
                      Icons.assignment,
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, Project project) {
    final now = DateTime.now();
    final totalDuration = project.estimatedEndDate
        .difference(project.startDate)
        .inDays;
    final elapsedDuration = now.difference(project.startDate).inDays;
    final remainingDuration = project.estimatedEndDate.difference(now).inDays;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Timeline',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDateRow(
              context,
              'Start Date',
              project.startDate,
              Icons.play_arrow,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildDateRow(
              context,
              'Estimated End',
              project.estimatedEndDate,
              Icons.flag,
              project.isOverdue ? Colors.red : Colors.blue,
            ),
            if (project.actualEndDate != null) ...[
              const SizedBox(height: 8),
              _buildDateRow(
                context,
                'Actual End',
                project.actualEndDate!,
                Icons.check_circle,
                Colors.green,
              ),
            ],

            const SizedBox(height: 16),

            // Duration Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Duration:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '$totalDuration days',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Days Elapsed:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '$elapsedDuration days',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Days Remaining:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        remainingDuration > 0
                            ? '$remainingDuration days'
                            : 'Overdue by ${-remainingDuration} days',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: remainingDuration > 0 ? null : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (project.isOverdue)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'This project is overdue',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectManagerCard(
    BuildContext context,
    dynamic projectManager,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Project Manager',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    _getUserInitials(projectManager),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projectManager.fullName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        projectManager.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implement contact functionality
                  },
                  icon: const Icon(Icons.email),
                  tooltip: 'Contact Manager',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard(BuildContext context, Project project) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.more_horiz,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Additional Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (project.createdAt != null)
              _buildDetailRow('Created', _formatDate(project.createdAt!)),
            if (project.updatedAt != null)
              _buildDetailRow('Last Updated', _formatDate(project.updatedAt!)),
            if (project.assignedUserId != null)
              _buildDetailRow('Assigned User ID', project.assignedUserId!),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ProjectStatus status) {
    Color chipColor;
    switch (status) {
      case ProjectStatus.planning:
        chipColor = Colors.blue;
        break;
      case ProjectStatus.inProgress:
        chipColor = Colors.orange;
        break;
      case ProjectStatus.onHold:
        chipColor = Colors.grey;
        break;
      case ProjectStatus.completed:
        chipColor = Colors.green;
        break;
      case ProjectStatus.cancelled:
        chipColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTagsRow(BuildContext context, List<String> tags) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tags:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: tags
                .map(
                  (tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    String label,
    DateTime date,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(_formatDate(date)),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Details')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                'Error Loading Project',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _projectBloc.add(const ProjectLoadRequested());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectNotFoundView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Not Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Project Not Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The project you\'re looking for could not be found.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(int percentage) {
    if (percentage < 25) return Colors.red;
    if (percentage < 50) return Colors.orange;
    if (percentage < 75) return Colors.yellow.shade700;
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getUserInitials(dynamic user) {
    if (user?.fullName != null && user.fullName.isNotEmpty) {
      final names = user.fullName.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return names[0][0].toUpperCase();
    }
    return 'U';
  }

  void _editProject(BuildContext context, Project project) {
    // TODO: Implement edit project functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit project functionality coming soon')),
    );
  }

  void _deleteProject(BuildContext context, Project project) {
    // TODO: Implement delete project functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
          'Are you sure you want to delete "${project.projectName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality coming soon'),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _shareProject(BuildContext context, Project project) {
    // TODO: Implement share project functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  /// Build daily reports card for the project
  Widget _buildDailyReportsCard(BuildContext context, Project project) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Daily Reports',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'View and manage daily progress reports for this project',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildReportStat(
                    context,
                    'Total Reports',
                    '12', // Mock data - replace with actual count
                    Icons.description,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildReportStat(
                    context,
                    'Pending',
                    '3', // Mock data - replace with actual count
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => DailyReportsCubit(
                          getDailyReports: GetDailyReports(
                            MockDailyReportRepository(),
                          ),
                          getDailyReportById: GetDailyReportById(
                            MockDailyReportRepository(),
                          ),
                          createDailyReport: CreateDailyReport(
                            MockDailyReportRepository(),
                          ),
                          updateDailyReport: UpdateDailyReport(
                            MockDailyReportRepository(),
                          ),
                          deleteDailyReport: DeleteDailyReport(
                            MockDailyReportRepository(),
                          ),
                          uploadDailyReportImage: UploadDailyReportImage(
                            MockDailyReportRepository(),
                          ),
                        ),
                        child: const DailyReportsScreen(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text(
                  'View All Reports',
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build work requests card for the project
  Widget _buildWorkRequestsCard(BuildContext context, Project project) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.work,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Work Requests',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Manage work requests and approvals for this project',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRequestStat(
                    context,
                    'Active',
                    '8', // Mock data - replace with actual count
                    Icons.pending,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRequestStat(
                    context,
                    'Approved',
                    '15', // Mock data - replace with actual count
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => MyWorkRequestsCubit(
                          GetMyWorkRequestsUseCase(
                            MockWorkRequestApprovalRepository(),
                          ),
                        ),
                        child: const MyWorkRequestsScreen(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text(
                  'View All Requests',
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build report statistics
  Widget _buildReportStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  /// Helper method to build request statistics
  Widget _buildRequestStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
