import 'package:flutter/material.dart';
import '../../../domain/entities/project.dart';

class ProjectDetailsWidget extends StatelessWidget {
  const ProjectDetailsWidget({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
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
                  'Project Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Project ID', project.projectId),
            if (project.clientInfo.isNotEmpty)
              _buildDetailRow(context, 'Client', project.clientInfo),
            if (project.address.isNotEmpty)
              _buildDetailRow(context, 'Address', project.address),
            if (project.location != null && project.location!.isNotEmpty)
              _buildDetailRow(context, 'Location', project.location!),
            _buildDetailRow(
              context,
              'Start Date',
              _formatDate(project.startDate),
            ),
            _buildDetailRow(
              context,
              'End Date',
              _formatDate(project.estimatedEndDate),
            ),
            if (project.actualEndDate != null)
              _buildDetailRow(
                context,
                'Actual End',
                _formatDate(project.actualEndDate!),
              ),
            if (project.projectManager != null)
              _buildDetailRow(
                context,
                'Project Manager',
                project.projectManager!.fullName,
              ),
            if (project.createdAt != null)
              _buildDetailRow(
                context,
                'Created',
                _formatDateTime(project.createdAt!),
              ),
            if (project.updatedAt != null)
              _buildDetailRow(
                context,
                'Last Updated',
                _formatDateTime(project.updatedAt!),
              ),
          ],
        ),
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
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}
