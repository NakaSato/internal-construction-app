import 'package:flutter/material.dart';
import '../../domain/entities/project_api_models.dart';
import 'shared/project_status_chip.dart';

/// Enhanced project card widget for displaying project information
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onTap});

  final Project project;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.projectName,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.clientInfo,
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ProjectStatusChip(status: project.status),
                ],
              ),

              const SizedBox(height: 12),

              // Address
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      project.address,
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Project Manager
              if (project.projectManager != null)
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        project.projectManager!.fullName,
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              if (project.projectManager != null) const SizedBox(height: 8),

              // Team and Connection Type
              Row(
                children: [
                  if (project.team != null) ...[
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.group_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              project.team!,
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (project.team != null && project.connectionType != null) const SizedBox(width: 12),
                  if (project.connectionType != null) ...[
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.power_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              project.connectionType!,
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              if (project.team != null || project.connectionType != null) const SizedBox(height: 8),

              // Location Coordinates (if available)
              if (project.locationCoordinates != null)
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Coordinates: ${project.locationCoordinates!.latitude.toStringAsFixed(4)}, ${project.locationCoordinates!.longitude.toStringAsFixed(4)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),

              if (project.locationCoordinates != null) const SizedBox(height: 12),

              // Progress and capacity info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress',
                          style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 2),
                        LinearProgressIndicator(
                          value: project.taskCount > 0
                              ? (project.completedTaskCount / project.taskCount).clamp(0.0, 1.0)
                              : 0.0,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${project.completedTaskCount}/${project.taskCount} tasks',
                          style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Capacity',
                        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${project.totalCapacityKw?.toStringAsFixed(1) ?? 'N/A'} kW',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (project.pvModuleCount != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${project.pvModuleCount} modules',
                          style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              // Equipment details (if available)
              if (project.equipmentDetails != null && project.equipmentDetails!.totalInverters > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.electrical_services_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _buildEquipmentSummary(project.equipmentDetails!),
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Dates and Financial Info
              Row(
                children: [
                  Expanded(child: _buildDateInfo(context, 'Start Date', project.startDate)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: project.estimatedEndDate != null
                        ? _buildDateInfo(context, 'End Date', project.estimatedEndDate!)
                        : _buildInfoField(context, 'Status', project.status),
                  ),
                ],
              ),

              // Financial information (if available)
              if (project.ftsValue != null || project.revenueValue != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (project.ftsValue != null) ...[
                      Expanded(child: _buildFinancialInfo(context, 'FTS Value', project.ftsValue!)),
                    ],
                    if (project.ftsValue != null && project.revenueValue != null) const SizedBox(width: 16),
                    if (project.revenueValue != null) ...[
                      Expanded(child: _buildFinancialInfo(context, 'Revenue', project.revenueValue!)),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(BuildContext context, String label, DateTime date) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(_formatDate(date), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildInfoField(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: _getStatusColor(value)),
        ),
      ],
    );
  }

  Widget _buildFinancialInfo(BuildContext context, String label, double value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(
          _formatCurrency(value),
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.primary),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return Colors.blue;
      case 'active':
      case 'in progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'on hold':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '฿${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '฿${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return '฿${value.toStringAsFixed(0)}';
    }
  }

  String _buildEquipmentSummary(EquipmentDetails equipment) {
    final List<String> inverters = [];

    if (equipment.inverter125kw > 0) {
      inverters.add('${equipment.inverter125kw}×125kW');
    }
    if (equipment.inverter80kw > 0) {
      inverters.add('${equipment.inverter80kw}×80kW');
    }
    if (equipment.inverter60kw > 0) {
      inverters.add('${equipment.inverter60kw}×60kW');
    }
    if (equipment.inverter40kw > 0) {
      inverters.add('${equipment.inverter40kw}×40kW');
    }

    if (inverters.isEmpty) {
      return 'No inverters';
    }

    return 'Inverters: ${inverters.join(', ')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
