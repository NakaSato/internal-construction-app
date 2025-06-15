import 'package:flutter/material.dart';
import '../../domain/entities/work_request.dart';
import 'ui_system/ui_system.dart';

class WorkRequestCard extends StatelessWidget {
  const WorkRequestCard({
    super.key,
    required this.workRequest,
    this.onViewDetails,
    this.onSubmitForApproval,
    this.showActions = true,
  });

  final WorkRequest workRequest;
  final VoidCallback? onViewDetails;
  final VoidCallback? onSubmitForApproval;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return WorkRequestCardContainer(
      onTap: onViewDetails,
      child: WorkRequestCardContent(
        children: [
          WorkRequestCardHeader(
            title: workRequest.title,
            subtitle: workRequest.projectName,
            trailing: WorkRequestStatusChip(
              status: workRequest.currentStatus,
              size: WorkRequestStatusChipSize.medium,
            ),
          ),
          _buildDetailsSection(context),
          if (showActions) _buildActionsSection(context),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        WorkRequestInfoRow(
          icon: Icons.person_outline,
          label: 'Submitted by',
          value: workRequest.submittedByName,
        ),
        WorkRequestInfoRow(
          icon: Icons.calendar_today_outlined,
          label: 'Submitted',
          value: _formatDate(workRequest.submittedDate),
        ),
        if (workRequest.daysPending > 0)
          WorkRequestInfoRow(
            icon: Icons.schedule,
            label: 'Days pending',
            value: '${workRequest.daysPending} day(s)',
            iconColor: colorScheme.error,
          ),
        if (workRequest.estimatedCost > 0)
          WorkRequestInfoRow(
            icon: Icons.attach_money,
            label: 'Estimated cost',
            value: '\$${workRequest.estimatedCost.toStringAsFixed(2)}',
          ),
        WorkRequestInfoRow(
          icon: Icons.priority_high,
          label: 'Priority',
          value: workRequest.priority.displayName,
        ),
        if (workRequest.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              workRequest.description,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    final actions = <Widget>[];

    if (onSubmitForApproval != null) {
      actions.add(
        WorkRequestActionButton(
          label: 'Submit for Approval',
          icon: Icons.send,
          onPressed: onSubmitForApproval,
          style: WorkRequestActionButtonStyle.primary,
          size: WorkRequestActionButtonSize.small,
        ),
      );
    }

    if (onViewDetails != null) {
      actions.add(
        WorkRequestActionButton(
          label: 'View Details',
          icon: Icons.visibility,
          onPressed: onViewDetails,
          style: WorkRequestActionButtonStyle.secondary,
          size: WorkRequestActionButtonSize.small,
        ),
      );
    }

    return WorkRequestCardFooter(actions: actions);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
