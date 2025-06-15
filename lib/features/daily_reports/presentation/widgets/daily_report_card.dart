import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/daily_report.dart';

/// Widget to display a daily report card in the list
class DailyReportCard extends StatelessWidget {
  final DailyReport report;
  final VoidCallback onTap;

  const DailyReportCard({super.key, required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with project name and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      report.project?.projectName ?? 'Unknown Project',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _formatDate(report.reportDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Technician name and hours worked
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report.technician?.fullName ?? 'Unknown User',
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildHoursWidget(context),
                ],
              ),

              const SizedBox(height: 12),

              // Status and photos row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(flex: 0, child: _buildStatusChip(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${report.photosCount} ${report.photosCount == 1 ? 'photo' : 'photos'}',
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
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

  String _formatDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  Widget _buildHoursWidget(BuildContext context) {
    // Calculate total hours from work progress items
    double totalHours = 0;
    for (final item in report.workProgressItems) {
      totalHours += item.hoursWorked;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            '${totalHours}h',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    IconData icon;

    switch (report.status) {
      case DailyReportStatus.draft:
        color = Colors.grey;
        icon = Icons.edit_note;
        break;
      case DailyReportStatus.submitted:
        color = Colors.blue;
        icon = Icons.send;
        break;
      case DailyReportStatus.approved:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case DailyReportStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            report.status.name.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
