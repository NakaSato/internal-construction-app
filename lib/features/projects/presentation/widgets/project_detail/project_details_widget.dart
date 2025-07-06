import 'package:flutter/material.dart';
import '../../../domain/entities/project.dart';

class ProjectDetailsWidget extends StatelessWidget {
  const ProjectDetailsWidget({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Project Header Card
        _buildHeaderCard(context),
        const SizedBox(height: 16),

        // Project Information Cards
        LayoutBuilder(
          builder: (context, constraints) {
            // If width is too narrow, stack vertically
            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  _buildBasicInfoCard(context),
                  const SizedBox(height: 16),
                  _buildDatesCard(context),
                  const SizedBox(height: 16),
                  _buildProgressCard(context),
                  if (project.budget != null) ...[
                    const SizedBox(height: 16),
                    _buildBudgetCard(context),
                  ],
                ],
              );
            }

            // Use side-by-side layout for wider screens
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Basic Info
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildBasicInfoCard(context),
                      const SizedBox(height: 16),
                      _buildDatesCard(context),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Right Column - Progress & Budget
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildProgressCard(context),
                      const SizedBox(height: 16),
                      if (project.budget != null) _buildBudgetCard(context),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        // Additional Information
        if (project.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDescriptionCard(context),
        ],

        if (project.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTagsCard(context),
        ],
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.business,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.projectName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${project.projectId}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(child: _buildStatusChip(context)),
              ],
            ),
            if (project.clientInfo.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Client: ${project.clientInfo}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (project.address.isNotEmpty)
              _buildDetailRow(context, 'Address', project.address),

            if (project.location != null && project.location!.isNotEmpty)
              _buildDetailRow(context, 'Location', project.location!),

            if (project.projectManager != null)
              _buildDetailRow(
                context,
                'Project Manager',
                project.projectManager!.fullName,
              ),

            _buildDetailRow(context, 'Priority', project.priority.displayName),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Timeline',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildDetailRow(
              context,
              'Start Date',
              _formatDate(project.startDate),
            ),
            _buildDetailRow(
              context,
              'Est. End Date',
              _formatDate(project.estimatedEndDate),
            ),

            if (project.actualEndDate != null)
              _buildDetailRow(
                context,
                'Actual End',
                _formatDate(project.actualEndDate!),
              ),

            if (project.dueDate != null)
              _buildDetailRow(
                context,
                'Due Date',
                _formatDate(project.dueDate!),
              ),

            // Project duration
            _buildDetailRow(context, 'Duration', _calculateDuration()),

            // Overdue indicator
            if (project.isOverdue)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        size: 16,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Overdue',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final theme = Theme.of(context);
    final progress = project.completionPercentage;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress percentage
            Center(
              child: Text(
                '$progress%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Task counts
            if (project.totalTasks != null || project.taskCount > 0) ...[
              _buildDetailRow(
                context,
                'Total Tasks',
                '${project.totalTasks ?? project.taskCount}',
              ),
              _buildDetailRow(
                context,
                'Completed',
                '${project.completedTasks ?? project.completedTaskCount}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context) {
    final theme = Theme.of(context);
    final budget = project.budget!;
    final actualCost = project.actualCost ?? 0.0;
    final utilization = project.budgetUtilization;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Budget',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildDetailRow(context, 'Budget', _formatCurrency(budget)),
            _buildDetailRow(context, 'Spent', _formatCurrency(actualCost)),
            _buildDetailRow(
              context,
              'Remaining',
              _formatCurrency(budget - actualCost),
            ),

            const SizedBox(height: 12),

            // Budget utilization bar
            Text(
              'Utilization: ${utilization.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (utilization / 100).clamp(0.0, 1.0),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                project.isOverBudget
                    ? theme.colorScheme.error
                    : utilization > 80
                    ? Colors.orange
                    : theme.colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),

            if (project.isOverBudget) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      size: 16,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Over Budget',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Description',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              project.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.label_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Tags',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag, style: theme.textTheme.bodySmall),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      side: BorderSide.none,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final status = project.projectStatus;

    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case ProjectStatus.planning:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.design_services;
        break;
      case ProjectStatus.inProgress:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.play_arrow;
        break;
      case ProjectStatus.onHold:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        icon = Icons.pause;
        break;
      case ProjectStatus.completed:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case ProjectStatus.cancelled:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              status.displayName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String _calculateDuration() {
    final start = project.startDate;
    final end = project.actualEndDate ?? project.estimatedEndDate;
    final duration = end.difference(start).inDays;

    if (duration < 30) {
      return '$duration days';
    } else if (duration < 365) {
      final months = (duration / 30).round();
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      final years = (duration / 365).floor();
      final remainingMonths = ((duration % 365) / 30).round();
      String result = '$years year${years > 1 ? 's' : ''}';
      if (remainingMonths > 0) {
        result += ', $remainingMonths month${remainingMonths > 1 ? 's' : ''}';
      }
      return result;
    }
  }
}
