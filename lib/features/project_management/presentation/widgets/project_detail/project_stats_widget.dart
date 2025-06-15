import 'package:flutter/material.dart';
import '../../../domain/entities/project.dart';

class ProjectStatsWidget extends StatelessWidget {
  const ProjectStatsWidget({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Duration',
                _calculateProjectDuration(project),
                Icons.calendar_month,
                theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Progress',
                '${project.completionPercentage}%',
                Icons.trending_up,
                _getProgressColor(project.completionPercentage),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Tasks',
                '${project.completedTasks ?? project.completedTaskCount}/${project.totalTasks ?? project.taskCount}',
                Icons.task_alt,
                theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Budget',
                project.budget != null
                    ? '\$${_formatCurrency(project.budget!)}'
                    : 'N/A',
                Icons.account_balance_wallet,
                theme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateProjectDuration(Project project) {
    final difference = project.estimatedEndDate.difference(project.startDate);
    final days = difference.inDays;

    if (days < 30) {
      return '${days}d';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '${months}mo';
    } else {
      final years = (days / 365).floor();
      return '${years}y';
    }
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

  Color _getProgressColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.lightGreen;
    if (percentage >= 40) return Colors.orange;
    if (percentage >= 20) return Colors.deepOrange;
    return Colors.red;
  }
}
