import 'package:flutter/material.dart';
import '../../domain/entities/wbs_task.dart';

class WbsTaskDetailsWidget extends StatelessWidget {
  const WbsTaskDetailsWidget({super.key, this.task, this.onTaskUpdated, this.onTaskDeleted});

  final WbsTask? task;
  final Function(WbsTask task)? onTaskUpdated;
  final Function(String taskId)? onTaskDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (task == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: theme.colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Select a task',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a task from the WBS tree to view details',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // WBS Code
                    if (task!.wbsCode?.isNotEmpty == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task!.wbsCode!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),

                    if (task!.wbsCode?.isNotEmpty == true) const SizedBox(height: 8),

                    // Task Name
                    Text(task!.taskNameEN, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              // Actions menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [Icon(Icons.edit_outlined), SizedBox(width: 8), Text('Edit Task')]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outlined, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Task', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditDialog(context);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Status and Progress
          _buildStatusSection(context),

          const SizedBox(height: 20),

          // Description
          if (task!.description != null && task!.description!.isNotEmpty) ...[
            _buildSectionHeader(context, 'Description'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
              ),
              child: Text(task!.description!, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 20),
          ],

          // Task Information
          _buildTaskInformation(context),

          const SizedBox(height: 20),

          // Dates and Duration
          _buildDatesSection(context),

          const SizedBox(height: 20),

          // Cost Information
          if ((task!.estimatedCost != null && task!.estimatedCost! > 0) ||
              (task!.actualCost != null && task!.actualCost! > 0))
            _buildCostSection(context),

          // Attachments
          if (task!.evidenceAttachments.isNotEmpty) ...[const SizedBox(height: 20), _buildAttachmentsSection(context)],

          // Children Tasks
          if (task!.children.isNotEmpty) ...[const SizedBox(height: 20), _buildChildrenSection(context)],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600));
  }

  Widget _buildStatusSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Status & Progress'),
        const SizedBox(height: 12),

        Row(
          children: [
            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(task!.status, theme).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getStatusColor(task!.status, theme)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: _getStatusColor(task!.status, theme), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    task!.status.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(task!.status, theme),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Progress percentage
            Text(
              '${task!.progressPercentage.toStringAsFixed(1)}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Progress bar
        LinearProgressIndicator(
          value: task!.progressPercentage / 100,
          backgroundColor: theme.colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation(_getStatusColor(task!.status, theme)),
        ),
      ],
    );
  }

  Widget _buildTaskInformation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Task Information'),
        const SizedBox(height: 12),

        _buildInfoRow(context, 'Type', task!.taskType.displayName),
        _buildInfoRow(context, 'Priority', task!.priority.displayName),

        if (task!.assignedTo != null) _buildInfoRow(context, 'Assigned To', task!.assignedTo!),
        if (task!.estimatedDuration != null && task!.estimatedDuration! > 0)
          _buildInfoRow(context, 'Estimated Duration', '${task!.estimatedDuration} days'),

        if (task!.actualDuration != null && task!.actualDuration! > 0)
          _buildInfoRow(context, 'Actual Duration', '${task!.actualDuration} days'),
      ],
    );
  }

  Widget _buildDatesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Schedule'),
        const SizedBox(height: 12),

        _buildInfoRow(context, 'Start Date', task!.startDate != null ? _formatDate(task!.startDate!) : 'Not set'),
        _buildInfoRow(context, 'End Date', task!.endDate != null ? _formatDate(task!.endDate!) : 'Not set'),

        if (task!.completedAt != null) _buildInfoRow(context, 'Completed At', _formatDateTime(task!.completedAt!)),

        _buildInfoRow(context, 'Created At', _formatDateTime(task!.createdAt)),
        _buildInfoRow(context, 'Updated At', _formatDateTime(task!.updatedAt)),
      ],
    );
  }

  Widget _buildCostSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Cost Information'),
        const SizedBox(height: 12),

        if (task!.estimatedCost != null && task!.estimatedCost! > 0)
          _buildInfoRow(context, 'Estimated Cost', '\$${task!.estimatedCost!.toStringAsFixed(2)}'),

        if (task!.actualCost != null && task!.actualCost! > 0)
          _buildInfoRow(context, 'Actual Cost', '\$${task!.actualCost!.toStringAsFixed(2)}'),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAttachmentsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Attachments'),
        const SizedBox(height: 12),

        ...task!.evidenceAttachments.map(
          (attachment) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_file, size: 20, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.filename,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      if (attachment.description != null && attachment.description!.isNotEmpty)
                        Text(
                          attachment.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    // TODO: Implement download
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChildrenSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Subtasks (${task!.children.length})'),
        const SizedBox(height: 12),

        ...task!.children.map(
          (child) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: _getStatusColor(child.status, theme), shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(child.taskNameEN, style: theme.textTheme.bodyMedium)),
                Text(
                  '${child.progressPercentage.toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(WbsTaskStatus status, ThemeData theme) {
    switch (status) {
      case WbsTaskStatus.notStarted:
        return theme.colorScheme.outline;
      case WbsTaskStatus.inProgress:
        return Colors.orange;
      case WbsTaskStatus.completed:
        return Colors.green;
      case WbsTaskStatus.blocked:
        return theme.colorScheme.error;
      case WbsTaskStatus.cancelled:
        return Colors.grey;
      case WbsTaskStatus.onHold:
        return Colors.amber;
      case WbsTaskStatus.underReview:
        return Colors.blue;
      case WbsTaskStatus.approved:
        return Colors.teal;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: const Text('Task editing form would go here.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              // TODO: Implement task editing
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task!.taskNameEN}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              onTaskDeleted?.call(task!.wbsId);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
