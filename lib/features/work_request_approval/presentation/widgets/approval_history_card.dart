import 'package:flutter/material.dart';
import '../../domain/entities/approval_history.dart';

class ApprovalHistoryCard extends StatelessWidget {
  const ApprovalHistoryCard({
    super.key,
    required this.history,
    this.isLast = false,
  });

  final ApprovalHistory history;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildActionIcon(context),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getActionTitle(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'by ${history.approverName}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatDate(history.processedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          _formatTime(history.processedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (history.comments != null &&
                    history.comments!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 16,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            history.comments!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (history.rejectionReason != null &&
                    history.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rejection Reason:',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                history.rejectionReason!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: 2,
            height: 20,
            color: colorScheme.outline.withOpacity(0.3),
          ),
      ],
    );
  }

  Widget _buildActionIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData icon;
    Color backgroundColor;
    Color iconColor;

    switch (history.action.toLowerCase()) {
      case 'adminapproved':
      case 'managerapproved':
      case 'approved':
        icon = Icons.check_circle;
        backgroundColor = Colors.green.withOpacity(0.2);
        iconColor = Colors.green[700]!;
        break;
      case 'rejected':
        icon = Icons.cancel;
        backgroundColor = colorScheme.errorContainer;
        iconColor = colorScheme.onErrorContainer;
        break;
      case 'escalated':
        icon = Icons.trending_up;
        backgroundColor = Colors.purple.withOpacity(0.2);
        iconColor = Colors.purple[700]!;
        break;
      case 'submitted':
        icon = Icons.send;
        backgroundColor = colorScheme.primaryContainer;
        iconColor = colorScheme.onPrimaryContainer;
        break;
      default:
        icon = Icons.info;
        backgroundColor = colorScheme.surfaceContainerHighest;
        iconColor = colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  String _getActionTitle() {
    switch (history.action.toLowerCase()) {
      case 'adminapproved':
        return 'Admin Approved';
      case 'managerapproved':
        return 'Manager Approved';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'escalated':
        return 'Escalated';
      case 'submitted':
        return 'Submitted for Approval';
      default:
        return history.action;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
