import 'package:flutter/material.dart';
import '../../domain/entities/work_request.dart';

class PendingApprovalCard extends StatelessWidget {
  const PendingApprovalCard({
    super.key,
    required this.workRequest,
    this.isSelected = false,
    this.isBulkMode = false,
    this.onTap,
    this.onApprove,
    this.onReject,
  });

  final WorkRequest workRequest;
  final bool isSelected;
  final bool isBulkMode;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isBulkMode)
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) => onTap?.call(),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workRequest.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            workRequest.projectName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDaysPendingBadge(context),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 16,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Submitted by: ${workRequest.submittedByName}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(workRequest.submittedDate),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildPriorityChip(context),
                        const SizedBox(height: 8),
                        Text(
                          '\$${workRequest.estimatedCost.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!isBulkMode) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            side: BorderSide(color: colorScheme.error),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: onApprove,
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysPendingBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color badgeColor;
    if (workRequest.daysPending <= 1) {
      badgeColor = Colors.green;
    } else if (workRequest.daysPending <= 3) {
      badgeColor = Colors.orange;
    } else {
      badgeColor = colorScheme.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${workRequest.daysPending} day(s) pending',
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color chipColor;
    Color textColor;

    switch (workRequest.priority) {
      case WorkRequestPriority.low:
        chipColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue[800]!;
        break;
      case WorkRequestPriority.medium:
        chipColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange[800]!;
        break;
      case WorkRequestPriority.high:
        chipColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red[800]!;
        break;
      case WorkRequestPriority.critical:
        chipColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        workRequest.priority.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
