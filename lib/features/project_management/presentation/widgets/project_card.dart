import 'package:flutter/material.dart';

import '../../domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Delete'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                project.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Status and Priority row
              Row(
                children: [
                  _buildStatusChip(context, project.projectStatus),
                  const SizedBox(width: 8),
                  _buildPriorityChip(context, project.priority),
                  const Spacer(),
                  if (project.isOverdue)
                    Icon(
                      Icons.warning,
                      color: theme.colorScheme.error,
                      size: 16,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress', style: theme.textTheme.bodySmall),
                      Text(
                        '${project.completionPercentage}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: project.completionPercentage / 100,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(context, project.completionPercentage),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Due date and tags
              Row(
                children: [
                  if (project.dueDate != null) ...[
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(project.dueDate!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: project.isOverdue
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (project.tags.isNotEmpty)
                    Text(
                      '${project.tags.length} tags',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ProjectStatus status) {
    final theme = Theme.of(context);
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

    return Chip(
      label: Text(
        status.displayName,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPriorityChip(BuildContext context, ProjectPriority priority) {
    final theme = Theme.of(context);
    Color chipColor;

    switch (priority) {
      case ProjectPriority.low:
        chipColor = Colors.green.shade300;
        break;
      case ProjectPriority.medium:
        chipColor = Colors.yellow.shade600;
        break;
      case ProjectPriority.high:
        chipColor = Colors.orange.shade600;
        break;
      case ProjectPriority.urgent:
        chipColor = Colors.red.shade600;
        break;
    }

    return Chip(
      label: Text(
        priority.displayName,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getProgressColor(BuildContext context, int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 1) return 'In $difference days';
    return '${-difference} days ago';
  }
}
