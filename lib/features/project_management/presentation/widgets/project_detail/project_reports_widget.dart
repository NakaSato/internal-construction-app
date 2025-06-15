import 'package:flutter/material.dart';
import '../../../domain/entities/project.dart';

class ProjectReportsWidget extends StatelessWidget {
  const ProjectReportsWidget({
    super.key,
    required this.project,
    this.onViewAllReports,
  });

  final Project project;
  final VoidCallback? onViewAllReports;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reports = project.recentReports;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Reports',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: onViewAllReports,
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
            if (reports.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recent reports available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (reports.isNotEmpty) ...[
              const SizedBox(height: 12),
              // Replace ListView with Column to avoid nested scrolling issues
              Column(
                children: [
                  for (
                    int i = 0;
                    i < (reports.length > 3 ? 3 : reports.length);
                    i++
                  ) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ReportItemWidget(report: reports[i]),
                  ],
                ],
              ),
              if (reports.length > 3) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: onViewAllReports,
                    child: Text('See all ${reports.length} reports'),
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

class ReportItemWidget extends StatelessWidget {
  const ReportItemWidget({super.key, required this.report, this.onTap});

  final RecentReport report;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportDate = _formatDate(report.reportDate);
    final isToday = report.reportDate.difference(DateTime.now()).inDays == 0;
    final isYesterday =
        report.reportDate.difference(DateTime.now()).inDays == -1;

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today';
    } else if (isYesterday) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = reportDate;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          report.userName.isNotEmpty
              ? report.userName.substring(0, 1).toUpperCase()
              : '?',
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        report.userName,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Row(
        children: [
          Icon(
            Icons.event,
            size: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            dateLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  '${report.hoursWorked}h',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
      onTap:
          onTap ??
          () {
            // Handle report tap - navigate to report details
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Report ${report.id} details coming soon'),
              ),
            );
          },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
