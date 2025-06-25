import 'package:flutter/material.dart';
import '../../../domain/entities/work_request.dart';

/// A reusable priority indicator widget
class WorkRequestPriorityIndicator extends StatelessWidget {
  const WorkRequestPriorityIndicator({
    super.key,
    required this.priority,
    this.style = WorkRequestPriorityStyle.chip,
    this.size = WorkRequestPrioritySize.medium,
  });

  final WorkRequestPriority priority;
  final WorkRequestPriorityStyle style;
  final WorkRequestPrioritySize size;

  @override
  Widget build(BuildContext context) {
    final config = _getPriorityConfig();
    final sizeConfig = _getSizeConfig();

    switch (style) {
      case WorkRequestPriorityStyle.chip:
        return _buildChipStyle(config, sizeConfig);
      case WorkRequestPriorityStyle.badge:
        return _buildBadgeStyle(config, sizeConfig);
      case WorkRequestPriorityStyle.indicator:
        return _buildIndicatorStyle(config, sizeConfig);
    }
  }

  Widget _buildChipStyle(
    _PriorityConfig config,
    _PrioritySizeConfig sizeConfig,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizeConfig.horizontalPadding,
        vertical: sizeConfig.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: sizeConfig.iconSize,
            color: config.foregroundColor,
          ),
          SizedBox(width: sizeConfig.spacing),
          Text(
            priority.displayName,
            style: TextStyle(
              color: config.foregroundColor,
              fontSize: sizeConfig.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeStyle(
    _PriorityConfig config,
    _PrioritySizeConfig sizeConfig,
  ) {
    return CircleAvatar(
      radius: sizeConfig.badgeRadius,
      backgroundColor: config.color,
      child: Icon(config.icon, size: sizeConfig.iconSize, color: Colors.white),
    );
  }

  Widget _buildIndicatorStyle(
    _PriorityConfig config,
    _PrioritySizeConfig sizeConfig,
  ) {
    return Container(
      width: sizeConfig.indicatorWidth,
      height: sizeConfig.indicatorHeight,
      decoration: BoxDecoration(
        color: config.color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  _PriorityConfig _getPriorityConfig() {
    switch (priority) {
      case WorkRequestPriority.low:
        return _PriorityConfig(
          color: Colors.green,
          backgroundColor: Colors.green.withOpacity(0.15),
          foregroundColor: Colors.green[800]!,
          icon: Icons.keyboard_arrow_down,
        );
      case WorkRequestPriority.medium:
        return _PriorityConfig(
          color: Colors.orange,
          backgroundColor: Colors.orange.withOpacity(0.15),
          foregroundColor: Colors.orange[800]!,
          icon: Icons.remove,
        );
      case WorkRequestPriority.high:
        return _PriorityConfig(
          color: Colors.red,
          backgroundColor: Colors.red.withOpacity(0.15),
          foregroundColor: Colors.red[800]!,
          icon: Icons.keyboard_arrow_up,
        );
      case WorkRequestPriority.critical:
        return _PriorityConfig(
          color: Colors.red[900]!,
          backgroundColor: Colors.red.withOpacity(0.2),
          foregroundColor: Colors.red[900]!,
          icon: Icons.priority_high,
        );
    }
  }

  _PrioritySizeConfig _getSizeConfig() {
    switch (size) {
      case WorkRequestPrioritySize.small:
        return const _PrioritySizeConfig(
          horizontalPadding: 6,
          verticalPadding: 3,
          iconSize: 12,
          fontSize: 11,
          borderRadius: 10,
          spacing: 3,
          badgeRadius: 8,
          indicatorWidth: 3,
          indicatorHeight: 16,
        );
      case WorkRequestPrioritySize.medium:
        return const _PrioritySizeConfig(
          horizontalPadding: 8,
          verticalPadding: 4,
          iconSize: 14,
          fontSize: 12,
          borderRadius: 12,
          spacing: 4,
          badgeRadius: 10,
          indicatorWidth: 4,
          indicatorHeight: 20,
        );
      case WorkRequestPrioritySize.large:
        return const _PrioritySizeConfig(
          horizontalPadding: 12,
          verticalPadding: 6,
          iconSize: 16,
          fontSize: 14,
          borderRadius: 16,
          spacing: 6,
          badgeRadius: 12,
          indicatorWidth: 5,
          indicatorHeight: 24,
        );
    }
  }
}

enum WorkRequestPriorityStyle { chip, badge, indicator }

enum WorkRequestPrioritySize { small, medium, large }

class _PriorityConfig {
  const _PriorityConfig({
    required this.color,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  final Color color;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
}

class _PrioritySizeConfig {
  const _PrioritySizeConfig({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.iconSize,
    required this.fontSize,
    required this.borderRadius,
    required this.spacing,
    required this.badgeRadius,
    required this.indicatorWidth,
    required this.indicatorHeight,
  });

  final double horizontalPadding;
  final double verticalPadding;
  final double iconSize;
  final double fontSize;
  final double borderRadius;
  final double spacing;
  final double badgeRadius;
  final double indicatorWidth;
  final double indicatorHeight;
}
