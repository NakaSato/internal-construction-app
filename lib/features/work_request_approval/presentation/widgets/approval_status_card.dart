import 'package:flutter/material.dart';
import '../../domain/entities/work_request.dart';

class ApprovalStatusCard extends StatelessWidget {
  const ApprovalStatusCard({super.key, required this.workRequest});

  final WorkRequest workRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Status',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(context),
                    ],
                  ),
                ),
                if (workRequest.daysPending > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${workRequest.daysPending} day(s)',
                          style: TextStyle(
                            color: colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (workRequest.nextApproverName != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Next Approver: ${workRequest.nextApproverName}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Submitted: ${_formatDate(workRequest.submittedDate)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            if (workRequest.lastActionDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.update,
                    size: 20,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last Action: ${_formatDate(workRequest.lastActionDate!)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            _buildApprovalFlow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color chipColor;
    Color textColor;
    IconData icon;

    switch (workRequest.currentStatus) {
      case WorkRequestStatus.draft:
        chipColor = colorScheme.surface;
        textColor = colorScheme.onSurface;
        icon = Icons.edit;
        break;
      case WorkRequestStatus.pendingApproval:
        chipColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange[800]!;
        icon = Icons.pending;
        break;
      case WorkRequestStatus.approved:
        chipColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green[800]!;
        icon = Icons.check_circle;
        break;
      case WorkRequestStatus.rejected:
        chipColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        icon = Icons.cancel;
        break;
      case WorkRequestStatus.escalated:
        chipColor = Colors.purple.withOpacity(0.2);
        textColor = Colors.purple[800]!;
        icon = Icons.trending_up;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 6),
          Text(
            workRequest.currentStatus.displayName,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalFlow(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define the approval flow steps
    final steps = [
      {'label': 'Submitted', 'status': 'completed'},
      {'label': 'Manager', 'status': _getStepStatus('manager')},
      {'label': 'Admin', 'status': _getStepStatus('admin')},
      {'label': 'Done', 'status': _getStepStatus('done')},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Approval Progress',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildStepIndicator(context, step['status']!),
                        const SizedBox(height: 4),
                        Text(
                          step['label']!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 20,
                      height: 2,
                      color: step['status'] == 'completed'
                          ? colorScheme.primary
                          : colorScheme.outline.withOpacity(0.3),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color foregroundColor;
    Widget child;

    switch (status) {
      case 'completed':
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        child = Icon(Icons.check, size: 16, color: foregroundColor);
        break;
      case 'current':
        backgroundColor = colorScheme.primaryContainer;
        foregroundColor = colorScheme.onPrimaryContainer;
        child = Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: foregroundColor,
            shape: BoxShape.circle,
          ),
        );
        break;
      case 'pending':
      default:
        backgroundColor = colorScheme.outline.withOpacity(0.2);
        foregroundColor = colorScheme.onSurface.withOpacity(0.5);
        child = Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: foregroundColor,
            shape: BoxShape.circle,
          ),
        );
        break;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }

  String _getStepStatus(String step) {
    switch (workRequest.currentStatus) {
      case WorkRequestStatus.draft:
        return 'pending';
      case WorkRequestStatus.pendingApproval:
        return step == 'manager' ? 'current' : 'pending';
      case WorkRequestStatus.approved:
        return 'completed';
      case WorkRequestStatus.rejected:
        return step == 'manager' ? 'current' : 'pending';
      case WorkRequestStatus.escalated:
        return step == 'admin'
            ? 'current'
            : step == 'manager'
            ? 'completed'
            : 'pending';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
