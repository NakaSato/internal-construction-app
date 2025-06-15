import 'package:flutter/material.dart';
import '../../../domain/entities/work_request.dart';

/// A reusable status chip widget for work request status display
class WorkRequestStatusChip extends StatelessWidget {
  const WorkRequestStatusChip({
    super.key,
    required this.status,
    this.size = WorkRequestStatusChipSize.medium,
    this.showIcon = true,
  });

  final WorkRequestStatus status;
  final WorkRequestStatusChipSize size;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final config = _getStatusConfig(colorScheme);
    final sizeConfig = _getSizeConfig();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizeConfig.horizontalPadding,
        vertical: sizeConfig.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
        border: config.borderColor != null
            ? Border.all(color: config.borderColor!, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              config.icon,
              size: sizeConfig.iconSize,
              color: config.foregroundColor,
            ),
            SizedBox(width: sizeConfig.spacing),
          ],
          Text(
            status.displayName,
            style: TextStyle(
              color: config.foregroundColor,
              fontSize: sizeConfig.fontSize,
              fontWeight: sizeConfig.fontWeight,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(ColorScheme colorScheme) {
    switch (status) {
      case WorkRequestStatus.draft:
        return _StatusConfig(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          borderColor: colorScheme.outline,
          icon: Icons.edit_outlined,
        );
      case WorkRequestStatus.pendingApproval:
        return _StatusConfig(
          backgroundColor: Colors.orange.withOpacity(0.15),
          foregroundColor: Colors.orange[800]!,
          icon: Icons.pending_outlined,
        );
      case WorkRequestStatus.approved:
        return _StatusConfig(
          backgroundColor: Colors.green.withOpacity(0.15),
          foregroundColor: Colors.green[800]!,
          icon: Icons.check_circle_outline,
        );
      case WorkRequestStatus.rejected:
        return _StatusConfig(
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
          icon: Icons.cancel_outlined,
        );
      case WorkRequestStatus.escalated:
        return _StatusConfig(
          backgroundColor: Colors.purple.withOpacity(0.15),
          foregroundColor: Colors.purple[800]!,
          icon: Icons.trending_up_outlined,
        );
    }
  }

  _SizeConfig _getSizeConfig() {
    switch (size) {
      case WorkRequestStatusChipSize.small:
        return _SizeConfig(
          horizontalPadding: 8,
          verticalPadding: 4,
          iconSize: 14,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          borderRadius: 12,
          spacing: 4,
        );
      case WorkRequestStatusChipSize.medium:
        return _SizeConfig(
          horizontalPadding: 12,
          verticalPadding: 6,
          iconSize: 16,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          borderRadius: 16,
          spacing: 6,
        );
      case WorkRequestStatusChipSize.large:
        return _SizeConfig(
          horizontalPadding: 16,
          verticalPadding: 8,
          iconSize: 18,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          borderRadius: 20,
          spacing: 8,
        );
    }
  }
}

enum WorkRequestStatusChipSize { small, medium, large }

class _StatusConfig {
  const _StatusConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    this.borderColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final IconData icon;
}

class _SizeConfig {
  const _SizeConfig({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.iconSize,
    required this.fontSize,
    required this.fontWeight,
    required this.borderRadius,
    required this.spacing,
  });

  final double horizontalPadding;
  final double verticalPadding;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final double spacing;
}
