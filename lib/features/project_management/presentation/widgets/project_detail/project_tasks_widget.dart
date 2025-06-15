import 'package:flutter/material.dart';
import '../../../domain/entities/project.dart';

class ProjectTasksWidget extends StatelessWidget {
  const ProjectTasksWidget({
    super.key,
    required this.project,
    this.onViewAllTasks,
  });

  final Project project;
  final VoidCallback? onViewAllTasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = project.tasks;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Tasks',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (tasks.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${project.completedTasks ?? 0}/${tasks.length}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.task_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (tasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...tasks.take(3).map((task) => TaskItemWidget(task: task)),
              if (tasks.length > 3) ...[
                const SizedBox(height: 12),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: onViewAllTasks,
                    icon: const Icon(Icons.list),
                    label: Text('View all ${tasks.length} tasks'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class TaskItemWidget extends StatelessWidget {
  const TaskItemWidget({
    super.key,
    required this.task,
  });

  final ProjectTask task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.status.toLowerCase() == 'completed';
    final daysLeft = task.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0 && !isCompleted;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isCompleted
          ? theme.colorScheme.surface.withOpacity(0.7)
          : isOverdue
              ? theme.colorScheme.errorContainer.withOpacity(0.2)
              : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : isOverdue
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.primaryContainer,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: isCompleted
                    ? theme.colorScheme.primary
                    : isOverdue
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted 
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: isOverdue
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${_formatDate(task.dueDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOverdue
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isOverdue && !isCompleted) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(${daysLeft.abs()} ${daysLeft.abs() == 1 ? 'day' : 'days'} overdue)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            TaskStatusChip(status: task.status),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color chipColor;
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'in progress':
        chipColor = Colors.blue;
        statusIcon = Icons.trending_up;
        break;
      case 'pending':
        chipColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      default:
        chipColor = theme.colorScheme.primary;
        statusIcon = Icons.circle;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: theme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
