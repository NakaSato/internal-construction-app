import 'package:flutter/material.dart';

/// Project status enumeration for better type safety
enum ProjectStatus { planning, active, onHold, completed, cancelled }

/// Extension on ProjectStatus for easy conversion from strings
extension ProjectStatusExtension on ProjectStatus {
  static ProjectStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return ProjectStatus.planning;
      case 'active':
      case 'in progress':
      case 'inprogress':
        return ProjectStatus.active;
      case 'onhold':
      case 'on hold':
        return ProjectStatus.onHold;
      case 'completed':
        return ProjectStatus.completed;
      case 'cancelled':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.planning;
    }
  }

  String get displayName {
    switch (this) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.onHold:
        return 'OnHold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectStatus.planning:
        return Icons.rule;
      case ProjectStatus.active:
        return Icons.directions_run;
      case ProjectStatus.onHold:
        return Icons.pause_circle_filled;
      case ProjectStatus.completed:
        return Icons.check_circle;
      case ProjectStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color get color {
    switch (this) {
      case ProjectStatus.planning:
        return Colors.blue;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.onHold:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.teal;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }
}

/// Reusable chip widget to provide consistent visual representation of project status
///
/// The chip's color, icon, and label change based on the status:
/// - Planning: Blue with rule icon
/// - Active: Green with directions_run icon
/// - OnHold: Orange with pause_circle_filled icon
/// - Completed: Teal with check_circle icon
/// - Cancelled: Red with cancel icon
class ProjectStatusChip extends StatelessWidget {
  const ProjectStatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectStatus = ProjectStatusExtension.fromString(status);
    final statusColor = projectStatus.color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(projectStatus.icon, color: statusColor, size: compact ? 16 : 18),
          if (!compact) ...[
            const SizedBox(width: 6),
            Text(
              projectStatus.displayName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Simplified status indicator using just a colored dot
class ProjectStatusDot extends StatelessWidget {
  const ProjectStatusDot({super.key, required this.status, this.size = 8.0});

  final String status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final projectStatus = ProjectStatusExtension.fromString(status);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: projectStatus.color,
        shape: BoxShape.circle,
      ),
    );
  }
}
