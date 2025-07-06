import 'package:flutter/material.dart';
import '../../../domain/entities/project.dart';

class ProjectProgressWidget extends StatelessWidget {
  const ProjectProgressWidget({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildProgressCard(context, project)),
        const SizedBox(width: 12),
        Expanded(child: _buildBudgetCard(context, project)),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, Project project) {
    final theme = Theme.of(context);
    final progress = project.progressPercentage != null
        ? project.progressPercentage! / 100.0
        : project.completionPercentage / 100.0;

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
                  Icons.timeline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  constraints: const BoxConstraints(maxWidth: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: _getProgressColor(
                      progress * 100 ~/ 1,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: _getProgressColor(progress * 100 ~/ 1),
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress * 100 ~/ 1),
                    ),
                    minHeight: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (project.totalTasks != null &&
                project.completedTasks != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${project.completedTasks} of ${project.totalTasks} tasks',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Updated: ${_formatDate(project.updatedAt ?? DateTime.now())}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

  Widget _buildBudgetCard(BuildContext context, Project project) {
    final theme = Theme.of(context);
    final hasBudgetData = project.budget != null && project.actualCost != null;
    final isOverBudget = hasBudgetData && project.actualCost! > project.budget!;
    final budgetProgress = hasBudgetData
        ? (project.actualCost! / project.budget!).clamp(0.0, 1.5)
        : 0.0;

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
                  color: isOverBudget
                      ? theme.colorScheme.error
                      : theme.colorScheme.tertiary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Budget',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isOverBudget)
                  Container(
                    constraints: const BoxConstraints(maxWidth: 70),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Over Budget',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onErrorContainer,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasBudgetData) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Budget:', style: theme.textTheme.bodyMedium),
                  Text(
                    '\$${_formatCurrency(project.budget!)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Spent:', style: theme.textTheme.bodyMedium),
                  Text(
                    '\$${_formatCurrency(project.actualCost!)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isOverBudget
                          ? theme.colorScheme.error
                          : theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: budgetProgress,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverBudget
                            ? theme.colorScheme.error
                            : theme.colorScheme.tertiary,
                      ),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isOverBudget ? 'Over by:' : 'Remaining:',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    isOverBudget
                        ? '\$${_formatCurrency(project.actualCost! - project.budget!)}'
                        : '\$${_formatCurrency(project.budget! - project.actualCost!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isOverBudget
                          ? theme.colorScheme.error
                          : theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${(budgetProgress * 100).toStringAsFixed(1)}% of budget used',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Center(
                child: Text(
                  'Budget information not available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getProgressColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.lightGreen;
    if (percentage >= 40) return Colors.orange;
    if (percentage >= 20) return Colors.deepOrange;
    return Colors.red;
  }
}
