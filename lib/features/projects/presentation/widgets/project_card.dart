import 'package:flutter/material.dart';
import '../../domain/entities/project_api_models.dart';

/// Enhanced project card widget for displaying project information with modern Material Design 3
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onTap, this.index = 0});

  final Project project;
  final VoidCallback? onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Alternating subtle background colors for cards
    final isEven = index % 2 == 0;
    final cardColor = isEven ? colorScheme.surface : colorScheme.surfaceContainerLowest;
    final statusColor = _getStatusColor(project.status);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.shadow.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: colorScheme.primary.withOpacity(0.1),
          highlightColor: colorScheme.primary.withOpacity(0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status bar at the top
              Container(height: 4, color: statusColor),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section with icon, title and status badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProjectIcon(context, project.status),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.projectName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
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
                        const SizedBox(width: 8),
                        _buildStatusBadge(context, project.status),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Address with icon
                    _buildInfoRow(context, Icons.location_on_rounded, project.address),

                    const SizedBox(height: 8),

                    // Project Manager
                    if (project.projectManager != null)
                      _buildInfoRow(context, Icons.person_rounded, project.projectManager!.fullName),

                    if (project.projectManager != null) const SizedBox(height: 8),

                    // Team & Connection Type in a row if both exist
                    if (project.team != null || project.connectionType != null) ...[
                      Row(
                        children: [
                          if (project.team != null) ...[
                            Expanded(child: _buildInfoRow(context, Icons.group_rounded, project.team!)),
                          ],
                          if (project.team != null && project.connectionType != null) const SizedBox(width: 16),
                          if (project.connectionType != null) ...[
                            Expanded(child: _buildInfoRow(context, Icons.power_rounded, project.connectionType!)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Location Coordinates (if available)
                    if (project.locationCoordinates != null) ...[
                      _buildInfoRow(
                        context,
                        Icons.my_location_rounded,
                        'Coordinates: ${project.locationCoordinates!.latitude.toStringAsFixed(4)}, ${project.locationCoordinates!.longitude.toStringAsFixed(4)}',
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Progress header
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Progress',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${project.completedTaskCount}/${project.taskCount} tasks',
                          style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildEnhancedProgressBar(context),

                    // Equipment details (if available)
                    if (project.equipmentDetails != null && project.equipmentDetails!.totalInverters > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.electrical_services_rounded, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _buildEquipmentSummary(project.equipmentDetails!),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Footer with dates and capacity
                    _buildFooter(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectIcon(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(status);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Center(child: Icon(_getIconForStatus(status), size: 20, color: statusColor)),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: colorScheme.primary.withOpacity(0.8)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedProgressBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate progress percentage
    final progress = project.taskCount > 0 ? (project.completedTaskCount / project.taskCount).clamp(0.0, 1.0) : 0.0;

    // Choose color based on progress
    Color progressColor;
    if (progress >= 0.8) {
      progressColor = Colors.green;
    } else if (progress >= 0.5) {
      progressColor = Colors.orange;
    } else {
      progressColor = colorScheme.primary;
    }

    return Container(
      height: 8,
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          Expanded(
            flex: (progress * 100).toInt(),
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(color: progressColor.withOpacity(0.3), blurRadius: 3, offset: const Offset(0, 1)),
                ],
              ),
            ),
          ),
          Expanded(flex: ((1 - progress) * 100).toInt(), child: Container()),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Start date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Start Date', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(
                  _formatDate(project.startDate),
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),

          // End date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('End Date', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(
                  _formatDate(project.estimatedEndDate),
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),

          // Capacity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Capacity', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${project.totalCapacityKw?.toStringAsFixed(1) ?? 'N/A'} kW',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Financial section could be added here if needed in the future

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
        return Colors.amber;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return Icons.edit_document;
      case 'active':
      case 'in progress':
        return Icons.engineering;
      case 'completed':
        return Icons.check_circle;
      case 'on hold':
        return Icons.pause_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.solar_power;
    }
  }

  // Currency formatter could be added here if needed in the future

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
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
