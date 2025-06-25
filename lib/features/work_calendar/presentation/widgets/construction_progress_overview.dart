import 'package:flutter/material.dart';

import '../../domain/entities/construction_task.dart';

/// Widget displaying construction progress overview and metrics
class ConstructionProgressOverview extends StatelessWidget {
  const ConstructionProgressOverview({
    super.key,
    required this.tasks,
    required this.projectId,
    this.onTaskStatusTapped,
  });

  final List<ConstructionTask> tasks;
  final String projectId;
  final Function(TaskStatus)? onTaskStatusTapped;

  @override
  Widget build(BuildContext context) {
    final projectTasks = tasks
        .where((task) => task.projectId == projectId)
        .toList();
    final metrics = _calculateMetrics(projectTasks);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildOverallProgress(context, metrics),
              const SizedBox(height: 20),
              _buildStatusBreakdown(context, metrics),
              const SizedBox(height: 20),
              _buildKeyMetrics(context, metrics),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.construction,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Progress',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                'Solar Installation - $projectId',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverallProgress(BuildContext context, ProjectMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${(metrics.overallProgress * 100).toInt()}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: metrics.overallProgress,
              minHeight: 12,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(context, metrics.overallProgress),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Completion: ${_formatDate(metrics.estimatedCompletion)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (metrics.isDelayed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'DELAYED',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown(BuildContext context, ProjectMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Status Breakdown',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: TaskStatus.values.map((status) {
              final count = metrics.statusCounts[status] ?? 0;
              final percentage = metrics.totalTasks > 0
                  ? (count / metrics.totalTasks * 100).toInt()
                  : 0;

              return GestureDetector(
                onTap: () => onTaskStatusTapped?.call(status),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${status.displayName} ($count)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (percentage > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '$percentage%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context, ProjectMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Metrics',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Active Tasks',
                  '${metrics.activeTasks}',
                  Icons.play_circle,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Overdue',
                  '${metrics.overdueTasks}',
                  Icons.warning,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Total Hours',
                  '${metrics.totalEstimatedHours.toInt()}h',
                  Icons.schedule,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Completion',
                  '${metrics.completedTasks}/${metrics.totalTasks}',
                  Icons.check_circle,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  ProjectMetrics _calculateMetrics(List<ConstructionTask> tasks) {
    if (tasks.isEmpty) {
      return ProjectMetrics(
        totalTasks: 0,
        completedTasks: 0,
        activeTasks: 0,
        overdueTasks: 0,
        overallProgress: 0.0,
        totalEstimatedHours: 0.0,
        statusCounts: {},
        estimatedCompletion: DateTime.now(),
        isDelayed: false,
      );
    }

    final statusCounts = <TaskStatus, int>{};
    for (final status in TaskStatus.values) {
      statusCounts[status] = tasks
          .where((task) => task.status == status)
          .length;
    }

    final completedTasks = statusCounts[TaskStatus.completed] ?? 0;
    final activeTasks = tasks.where((task) => task.isActive).length;
    final overdueTasks = tasks.where((task) => task.isOverdue).length;

    final totalProgress = tasks.fold<double>(
      0.0,
      (sum, task) => sum + task.progress,
    );
    final overallProgress = totalProgress / tasks.length;

    final totalEstimatedHours = tasks.fold<double>(
      0.0,
      (sum, task) => sum + (task.estimatedHours ?? 0.0),
    );

    // Calculate estimated completion based on progress
    final activeTasks_ = tasks
        .where(
          (task) =>
              task.status == TaskStatus.inProgress ||
              task.status == TaskStatus.notStarted,
        )
        .toList();

    DateTime estimatedCompletion = DateTime.now();
    if (activeTasks_.isNotEmpty) {
      final latestEndDate = activeTasks_
          .map((task) => task.endDate)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      estimatedCompletion = latestEndDate;
    }

    final isDelayed =
        overdueTasks > 0 ||
        (activeTasks_.isNotEmpty &&
            estimatedCompletion.isBefore(DateTime.now()));

    return ProjectMetrics(
      totalTasks: tasks.length,
      completedTasks: completedTasks,
      activeTasks: activeTasks,
      overdueTasks: overdueTasks,
      overallProgress: overallProgress,
      totalEstimatedHours: totalEstimatedHours,
      statusCounts: statusCounts,
      estimatedCompletion: estimatedCompletion,
      isDelayed: isDelayed,
    );
  }

  Color _getProgressColor(BuildContext context, double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.delayed:
        return Colors.orange;
      case TaskStatus.onHold:
        return Colors.purple;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Project metrics data class
class ProjectMetrics {
  const ProjectMetrics({
    required this.totalTasks,
    required this.completedTasks,
    required this.activeTasks,
    required this.overdueTasks,
    required this.overallProgress,
    required this.totalEstimatedHours,
    required this.statusCounts,
    required this.estimatedCompletion,
    required this.isDelayed,
  });

  final int totalTasks;
  final int completedTasks;
  final int activeTasks;
  final int overdueTasks;
  final double overallProgress;
  final double totalEstimatedHours;
  final Map<TaskStatus, int> statusCounts;
  final DateTime estimatedCompletion;
  final bool isDelayed;
}
