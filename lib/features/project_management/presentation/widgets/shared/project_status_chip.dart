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
        return 'On Hold'; // Fixed from 'OnHold' for better readability
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

/// Size options for ProjectStatusChip with specific use cases
enum ProjectStatusChipSize {
  /// Extra small size for dense layouts (12x20px) - Lists, tables
  extraSmall,

  /// Small size for compact displays - optimized visibility (15x26px) - Cards, sidebars
  small,

  /// Medium size for normal use (16x28px) - Default for most UI elements
  medium,

  /// Large size for emphasis (18x32px) - Important status displays
  large,

  /// Extra large size for headers (20x40px) - Hero sections, main displays
  extraLarge,
}

/// Extension for ProjectStatusChipSize with optimized size configurations
extension ProjectStatusChipSizeExtension on ProjectStatusChipSize {
  /// Icon size for the chip (optimized for readability)
  double get iconSize {
    switch (this) {
      case ProjectStatusChipSize.extraSmall:
        return 12.0;
      case ProjectStatusChipSize.small:
        return 15.0; // Increased for better visibility
      case ProjectStatusChipSize.medium:
        return 16.0;
      case ProjectStatusChipSize.large:
        return 18.0;
      case ProjectStatusChipSize.extraLarge:
        return 20.0;
    }
  }

  /// Horizontal padding for the chip (balanced spacing)
  double get horizontalPadding {
    switch (this) {
      case ProjectStatusChipSize.extraSmall:
        return 6.0;
      case ProjectStatusChipSize.small:
        return 10.0; // Increased for better spacing
      case ProjectStatusChipSize.medium:
        return 10.0;
      case ProjectStatusChipSize.large:
        return 12.0;
      case ProjectStatusChipSize.extraLarge:
        return 16.0;
    }
  }

  /// Vertical padding for the chip (proportional height)
  double get verticalPadding {
    switch (this) {
      case ProjectStatusChipSize.extraSmall:
        return 2.0;
      case ProjectStatusChipSize.small:
        return 4.0; // Increased for better height
      case ProjectStatusChipSize.medium:
        return 4.0;
      case ProjectStatusChipSize.large:
        return 6.0;
      case ProjectStatusChipSize.extraLarge:
        return 8.0;
    }
  }

  /// Border radius for the chip (consistent rounded appearance)
  double get borderRadius {
    switch (this) {
      case ProjectStatusChipSize.extraSmall:
        return 8.0;
      case ProjectStatusChipSize.small:
        return 12.0; // Increased for better rounded appearance
      case ProjectStatusChipSize.medium:
        return 12.0;
      case ProjectStatusChipSize.large:
        return 14.0;
      case ProjectStatusChipSize.extraLarge:
        return 16.0;
    }
  }

  /// Font size for the text (optimized readability)
  double get fontSize {
    switch (this) {
      case ProjectStatusChipSize.extraSmall:
        return 10.0;
      case ProjectStatusChipSize.small:
        return 12.0; // Increased for better readability
      case ProjectStatusChipSize.medium:
        return 12.0;
      case ProjectStatusChipSize.large:
        return 13.0;
      case ProjectStatusChipSize.extraLarge:
        return 14.0;
    }
  }

  /// Spacing between icon and text (proportional separation)
  double get spacing {
    switch (this) {
      case ProjectStatusChipSize.extraSmall:
        return 3.0;
      case ProjectStatusChipSize.small:
        return 5.0; // Increased for better separation
      case ProjectStatusChipSize.medium:
        return 5.0;
      case ProjectStatusChipSize.large:
        return 6.0;
      case ProjectStatusChipSize.extraLarge:
        return 8.0;
    }
  }

  /// Minimum height for the chip (consistent sizing)
  double get minHeight {
    switch (this) {
      case ProjectStatusChipSize.extraSmall:
        return 20.0;
      case ProjectStatusChipSize.small:
        return 26.0; // Increased for better visibility
      case ProjectStatusChipSize.medium:
        return 28.0;
      case ProjectStatusChipSize.large:
        return 32.0;
      case ProjectStatusChipSize.extraLarge:
        return 40.0;
    }
  }

  /// Border width for the chip (size-appropriate thickness)
  double get borderWidth {
    switch (this) {
      case ProjectStatusChipSize.extraSmall:
        return 0.8;
      case ProjectStatusChipSize.small:
        return 1.2; // Slightly thicker for better definition
      case ProjectStatusChipSize.medium:
      case ProjectStatusChipSize.large:
        return 1.0;
      case ProjectStatusChipSize.extraLarge:
        return 1.5;
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
///
/// Supports multiple sizes for different contexts:
/// - extraSmall: For dense layouts and lists
/// - small: For compact cards and secondary displays
/// - medium: Default size for most use cases
/// - large: For emphasis and primary displays
/// - extraLarge: For headers and hero sections
class ProjectStatusChip extends StatelessWidget {
  const ProjectStatusChip({
    super.key,
    required this.status,
    this.size = ProjectStatusChipSize.medium,
    this.showText = true,
    this.showIcon = true,
    this.compact = false, // Deprecated: use size instead
  });

  /// Creates a responsive ProjectStatusChip that adapts to screen size
  factory ProjectStatusChip.responsive({
    Key? key,
    required String status,
    required BuildContext context,
    bool showText = true,
    bool showIcon = true,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = screenWidth < 360
        ? ProjectStatusChipSize.extraSmall
        : screenWidth < 480
        ? ProjectStatusChipSize.small
        : screenWidth < 768
        ? ProjectStatusChipSize.medium
        : ProjectStatusChipSize.large;

    return ProjectStatusChip(
      key: key,
      status: status,
      size: size,
      showText: showText,
      showIcon: showIcon,
    );
  }

  /// Creates a compact ProjectStatusChip (icon only)
  factory ProjectStatusChip.iconOnly({
    Key? key,
    required String status,
    ProjectStatusChipSize size = ProjectStatusChipSize.small,
  }) {
    return ProjectStatusChip(
      key: key,
      status: status,
      size: size,
      showText: false,
      showIcon: true,
    );
  }

  /// Creates a text-only ProjectStatusChip (no icon)
  factory ProjectStatusChip.textOnly({
    Key? key,
    required String status,
    ProjectStatusChipSize size = ProjectStatusChipSize.medium,
  }) {
    return ProjectStatusChip(
      key: key,
      status: status,
      size: size,
      showText: true,
      showIcon: false,
    );
  }

  /// Creates a small but highly visible ProjectStatusChip
  factory ProjectStatusChip.smallVisible({
    Key? key,
    required String status,
    bool showIcon = true,
    bool showText = true,
  }) {
    return ProjectStatusChip(
      key: key,
      status: status,
      size: ProjectStatusChipSize.small,
      showText: showText,
      showIcon: showIcon,
    );
  }

  final String status;
  final ProjectStatusChipSize size;
  final bool showText;
  final bool showIcon;
  @Deprecated(
    'Use size parameter instead. This will be removed in future versions.',
  )
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectStatus = ProjectStatusExtension.fromString(status);
    final statusColor = projectStatus.color;

    // Handle backward compatibility with compact parameter
    final effectiveSize = compact ? ProjectStatusChipSize.small : size;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: effectiveSize.minHeight),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: effectiveSize.horizontalPadding,
          vertical: effectiveSize.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: statusColor.withValues(
            alpha: 0.12,
          ), // Slightly increased opacity for small size
          borderRadius: BorderRadius.circular(effectiveSize.borderRadius),
          border: Border.all(
            color: statusColor.withValues(
              alpha: 0.35,
            ), // Slightly darker border for better definition
            width: effectiveSize == ProjectStatusChipSize.small
                ? 1.2
                : 1, // Thicker border for small size
          ),
          boxShadow: effectiveSize == ProjectStatusChipSize.extraLarge
              ? [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : effectiveSize == ProjectStatusChipSize.small
              ? [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.08),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              Icon(
                projectStatus.icon,
                color: statusColor,
                size: effectiveSize.iconSize,
              ),
              if (showText) SizedBox(width: effectiveSize.spacing),
            ],
            if (showText) ...[
              Flexible(
                child: Text(
                  projectStatus.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: effectiveSize == ProjectStatusChipSize.small
                        ? FontWeight
                              .w700 // Bolder text for small size
                        : FontWeight.w600,
                    fontSize: effectiveSize.fontSize,
                    letterSpacing:
                        effectiveSize == ProjectStatusChipSize.extraLarge
                        ? 0.5
                        : effectiveSize == ProjectStatusChipSize.small
                        ? 0.2 // Slight letter spacing for small size readability
                        : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simplified status indicator using just a colored dot
class ProjectStatusDot extends StatelessWidget {
  const ProjectStatusDot({
    super.key,
    required this.status,
    this.size = 8.0,
    this.withBorder = false,
  });

  final String status;
  final double size;
  final bool withBorder;

  /// Creates a small but visible status dot
  factory ProjectStatusDot.smallVisible({Key? key, required String status}) {
    return ProjectStatusDot(
      key: key,
      status: status,
      size: 10.0, // Slightly larger for better visibility
      withBorder: true, // Add border for definition
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectStatus = ProjectStatusExtension.fromString(status);
    final statusColor = projectStatus.color;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: statusColor,
        shape: BoxShape.circle,
        border: withBorder
            ? Border.all(color: statusColor.withValues(alpha: 0.3), width: 1)
            : null,
        boxShadow: withBorder
            ? [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
    );
  }
}

/// Enhanced status bar with progress indicator and label
class ProjectStatusBar extends StatelessWidget {
  const ProjectStatusBar({
    super.key,
    required this.status,
    this.progress,
    this.showPercentage = false,
    this.height = 4.0,
    this.width,
    this.showLabel = true,
    this.compact = false,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  final String status;
  final double? progress;
  final bool showPercentage;
  final double height;
  final double? width;
  final bool showLabel;
  final bool compact;
  final bool animated;
  final Duration animationDuration;

  /// Creates a responsive ProjectStatusBar that adapts to screen size
  factory ProjectStatusBar.responsive({
    Key? key,
    required String status,
    required BuildContext context,
    double? progress,
    bool showPercentage = false,
    bool animated = true,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 480;

    return ProjectStatusBar(
      key: key,
      status: status,
      progress: progress,
      showPercentage: showPercentage && !isSmallScreen,
      height: isSmallScreen ? 4.0 : 6.0,
      compact: isSmallScreen,
      animated: animated,
      showLabel: !isSmallScreen || screenWidth > 360,
    );
  }

  /// Creates a compact ProjectStatusBar for small spaces
  factory ProjectStatusBar.compact({
    Key? key,
    required String status,
    double? progress,
    bool showPercentage = false,
    bool animated = true,
  }) {
    return ProjectStatusBar(
      key: key,
      status: status,
      progress: progress,
      showPercentage: showPercentage,
      height: 4.0,
      compact: true,
      animated: animated,
      showLabel: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectStatus = ProjectStatusExtension.fromString(status);
    final statusColor = projectStatus.color;
    final progressValue = progress ?? _getDefaultProgress(projectStatus);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final effectiveWidth =
        width ?? (compact ? screenWidth * 0.8 : double.infinity);
    final effectiveHeight = compact ? height * 0.8 : height;
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: statusColor,
      fontWeight: FontWeight.w600,
      fontSize: compact ? 11 : 12,
    );
    final percentageStyle = theme.textTheme.bodySmall?.copyWith(
      color: statusColor,
      fontWeight: FontWeight.w500,
      fontSize: compact ? 10 : 11,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final shouldShowPercentage =
            showPercentage && (availableWidth > 200 || !showLabel);

        return SizedBox(
          width: effectiveWidth == double.infinity ? null : effectiveWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status label and percentage row
              if (showLabel || shouldShowPercentage) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showLabel) ...[
                      Expanded(
                        child: Text(
                          projectStatus.displayName,
                          style: labelStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                    if (shouldShowPercentage) ...[
                      Text(
                        '${(progressValue * 100).toInt()}%',
                        style: percentageStyle,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: compact ? 3 : 4),
              ],

              // Progress bar
              Container(
                width: double.infinity,
                height: effectiveHeight,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(effectiveHeight / 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(effectiveHeight / 2),
                  child: animated
                      ? TweenAnimationBuilder<double>(
                          duration: animationDuration,
                          tween: Tween(begin: 0.0, end: progressValue),
                          curve: Curves.easeOutCubic,
                          builder: (context, animatedValue, child) {
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: animatedValue.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      statusColor,
                                      statusColor.withValues(alpha: 0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    effectiveHeight / 2,
                                  ),
                                  boxShadow: progressValue > 0.1
                                      ? [
                                          BoxShadow(
                                            color: statusColor.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            );
                          },
                        )
                      : FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progressValue.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  statusColor,
                                  statusColor.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                effectiveHeight / 2,
                              ),
                              boxShadow: progressValue > 0.1
                                  ? [
                                      BoxShadow(
                                        color: statusColor.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                ),
              ),

              // Additional info for non-compact mode
              if (!compact && showLabel && availableWidth > 300) ...[
                const SizedBox(height: 2),
                Text(
                  _getStatusDescription(projectStatus, progressValue),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  double _getDefaultProgress(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 0.2;
      case ProjectStatus.active:
        return 0.6;
      case ProjectStatus.onHold:
        return 0.4;
      case ProjectStatus.completed:
        return 1.0;
      case ProjectStatus.cancelled:
        return 0.0;
    }
  }

  String _getStatusDescription(ProjectStatus status, double progress) {
    final percentage = (progress * 100).toInt();

    switch (status) {
      case ProjectStatus.planning:
        return 'Project in planning phase';
      case ProjectStatus.active:
        return '$percentage% complete';
      case ProjectStatus.onHold:
        return 'Project temporarily paused';
      case ProjectStatus.completed:
        return 'Project completed successfully';
      case ProjectStatus.cancelled:
        return 'Project has been cancelled';
    }
  }
}

/// Circular progress indicator for project status
class ProjectStatusCircle extends StatelessWidget {
  const ProjectStatusCircle({
    super.key,
    required this.status,
    this.progress,
    this.size = 40.0,
    this.strokeWidth = 3.0,
    this.showIcon = true,
    this.showPercentage = false,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  final String status;
  final double? progress;
  final double size;
  final double strokeWidth;
  final bool showIcon;
  final bool showPercentage;
  final bool animated;
  final Duration animationDuration;

  /// Creates a responsive ProjectStatusCircle that adapts to screen size
  factory ProjectStatusCircle.responsive({
    Key? key,
    required String status,
    required BuildContext context,
    double? progress,
    bool showIcon = true,
    bool showPercentage = false,
    bool animated = true,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = screenWidth < 360
        ? 32.0
        : screenWidth < 480
        ? 36.0
        : 40.0;
    final strokeWidth = screenWidth < 360 ? 2.0 : 3.0;

    return ProjectStatusCircle(
      key: key,
      status: status,
      progress: progress,
      size: size,
      strokeWidth: strokeWidth,
      showIcon: showIcon,
      showPercentage: showPercentage && screenWidth > 360,
      animated: animated,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectStatus = ProjectStatusExtension.fromString(status);
    final statusColor = projectStatus.color;
    final progressValue = progress ?? _getDefaultProgress(projectStatus);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                statusColor.withValues(alpha: 0.2),
              ),
              backgroundColor: Colors.transparent,
            ),
          ),

          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: animated
                ? TweenAnimationBuilder<double>(
                    duration: animationDuration,
                    tween: Tween(begin: 0.0, end: progressValue),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, child) {
                      return CircularProgressIndicator(
                        value: animatedValue.clamp(0.0, 1.0),
                        strokeWidth: strokeWidth,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        backgroundColor: Colors.transparent,
                      );
                    },
                  )
                : CircularProgressIndicator(
                    value: progressValue.clamp(0.0, 1.0),
                    strokeWidth: strokeWidth,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    backgroundColor: Colors.transparent,
                  ),
          ),

          // Center content
          if (showIcon && !showPercentage) ...[
            Icon(projectStatus.icon, color: statusColor, size: size * 0.4),
          ] else if (showPercentage) ...[
            Text(
              '${(progressValue * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.25,
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _getDefaultProgress(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 0.2;
      case ProjectStatus.active:
        return 0.6;
      case ProjectStatus.onHold:
        return 0.4;
      case ProjectStatus.completed:
        return 1.0;
      case ProjectStatus.cancelled:
        return 0.0;
    }
  }
}

/// Grid layout for multiple status indicators
class ProjectStatusGrid extends StatelessWidget {
  const ProjectStatusGrid({
    super.key,
    required this.statuses,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.5,
    this.spacing = 8.0,
    this.showProgress = true,
    this.animated = true,
  });

  final List<ProjectStatusData> statuses;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;
  final bool showProgress;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final effectiveCrossAxisCount = screenWidth < 480 ? 1 : crossAxisCount;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: effectiveCrossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemCount: statuses.length,
          itemBuilder: (context, index) {
            final statusData = statuses[index];
            return Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showProgress) ...[
                      ProjectStatusCircle.responsive(
                        status: statusData.status,
                        context: context,
                        progress: statusData.progress,
                        showPercentage: true,
                        animated: animated,
                      ),
                      const SizedBox(height: 8),
                    ] else ...[
                      ProjectStatusChip.responsive(
                        status: statusData.status,
                        context: context,
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (statusData.label != null) ...[
                      Text(
                        statusData.label!,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Data class for project status information
class ProjectStatusData {
  const ProjectStatusData({required this.status, this.progress, this.label});

  final String status;
  final double? progress;
  final String? label;
}
