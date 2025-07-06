import 'package:flutter/material.dart';
import '../../../../daily_reports/domain/entities/daily_report.dart';
import 'constants.dart';

/// Helper methods for daily reports functionality
class DailyReportsHelpers {
  /// Get status color based on daily report status
  static Color getStatusColor(DailyReportStatus status, ThemeData theme) {
    switch (status) {
      case DailyReportStatus.draft:
        return Colors.grey;
      case DailyReportStatus.submitted:
        return Colors.orange;
      case DailyReportStatus.approved:
        return Colors.green;
      case DailyReportStatus.rejected:
        return Colors.red;
    }
  }

  /// Get status icon based on daily report status
  static IconData getStatusIcon(DailyReportStatus status) {
    switch (status) {
      case DailyReportStatus.draft:
        return Icons.edit;
      case DailyReportStatus.submitted:
        return Icons.schedule;
      case DailyReportStatus.approved:
        return Icons.check;
      case DailyReportStatus.rejected:
        return Icons.close;
    }
  }

  /// Build report statistics card
  static Widget buildReportStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Build create report card for users
  static Widget buildCreateReportCard(
    BuildContext context,
    VoidCallback onCreateReport,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ProjectDetailConstants.borderRadius,
        ),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ProjectDetailConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_add,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Create Daily Report',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ProjectDetailConstants.defaultSpacing),
            Text(
              'Document your daily work progress, achievements, and any issues encountered.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: ProjectDetailConstants.cardPadding),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCreateReport,
                icon: const Icon(Icons.add),
                label: const Text('Create New Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
