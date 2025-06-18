import 'package:flutter/material.dart';
import '../../../domain/entities/project.dart';

class ProjectHeaderWidget extends StatelessWidget {
  const ProjectHeaderWidget({
    super.key,
    required this.project,
    this.onEdit,
    this.onShare,
    this.onDelete,
  });

  final Project project;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 320.0, // Increased height for better text layout
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      // Enhanced leading icon
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: null, // We'll handle title in the background
        titlePadding: EdgeInsets.zero,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background image or gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
              child: ClipRRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
                      Image.network(
                        project.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/images/header.jpg', fit: BoxFit.cover),
                      )
                    else
                      Image.asset('assets/images/header.jpg', fit: BoxFit.cover),
                    
                    // Animated shimmer overlay for visual enhancement
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.transparent,
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Enhanced gradient overlay with multiple layers
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.7, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),

            // Subtle pattern overlay
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Enhanced project info overlay with optimized positioning
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and Progress Row - Compact top section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildStatusChip(context, project),
                        // Removed progress indicator from here
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Project Title Section - Main focal point
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: _buildProjectTitle(context, project.projectName),
                  ),
                  
                  // Progress Bar Container - Below title container
                  if (project.progressPercentage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildProjectProgressBar(context, project),
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Info Details Container - Compact bottom section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location info
                        if (project.location != null && project.location!.isNotEmpty)
                          _buildInfoRow(
                            icon: Icons.location_on_outlined,
                            text: project.location!,
                            iconColor: theme.colorScheme.secondary,
                          ),
                        
                        if (project.location != null && project.location!.isNotEmpty)
                          const SizedBox(height: 10),
                        
                        // Date range info
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          text: '${_formatDate(project.startDate)} - ${_formatDate(project.estimatedEndDate)}',
                          iconColor: theme.colorScheme.tertiary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: onEdit,
            tooltip: 'Edit Project',
            color: Colors.white,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
            color: theme.colorScheme.surface,
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit?.call();
                  break;
                case 'share':
                  onShare?.call();
                  break;
                case 'delete':
                  onDelete?.call();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (onEdit != null)
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      const Text('Edit Project'),
                    ],
                  ),
                ),
              if (onShare != null)
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share_outlined, color: theme.colorScheme.secondary),
                      const SizedBox(width: 12),
                      const Text('Share Project'),
                    ],
                  ),
                ),
              if (onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: theme.colorScheme.error),
                      const SizedBox(width: 12),
                      const Text('Delete Project'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectTitle(BuildContext context, String projectName) {
    // Split project name into parts for better line breaking
    final parts = projectName.split(' ');
    final firstPart = parts.isNotEmpty ? parts[0] : '';
    final remainingPart = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    
    // Display project number and title with improved alignment
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Project number/ID part - if exists
        if (firstPart.isNotEmpty && _isProjectId(firstPart))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 8, bottom: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              firstPart,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2.0,
                    color: Color.fromARGB(120, 0, 0, 0),
                  ),
                ],
              ),
            ),
          ),
        
        // Project title with better spacing
        Flexible(
          child: Text(
            _isProjectId(firstPart) ? remainingPart : projectName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              height: 1.3,
              shadows: [
                const Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 8.0,
                  color: Color.fromARGB(180, 0, 0, 0),
                ),
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 4.0,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  bool _isProjectId(String text) {
    // Check if the first part looks like a project ID (numbers, short text)
    return text.length <= 5 && (RegExp(r'^\d+$').hasMatch(text) || text.length <= 3);
  }

  Widget _buildStatusChip(BuildContext context, Project project) {
    final theme = Theme.of(context);
    final status = project.status.toLowerCase();
    Color chipColor;
    Color borderColor;
    double statusProgress;

    if (status.contains('active') || status.contains('in progress')) {
      chipColor = const Color(0xFF4CAF50);
      borderColor = const Color(0xFF81C784);
      statusProgress = 0.7; // 70% progress for active projects
    } else if (status.contains('planning')) {
      chipColor = const Color(0xFF2196F3);
      borderColor = const Color(0xFF64B5F6);
      statusProgress = 0.2; // 20% progress for planning
    } else if (status.contains('hold')) {
      chipColor = const Color(0xFFFF9800);
      borderColor = const Color(0xFFFFB74D);
      statusProgress = 0.5; // 50% progress for on hold
    } else if (status.contains('completed')) {
      chipColor = const Color(0xFF009688);
      borderColor = const Color(0xFF4DB6AC);
      statusProgress = 1.0; // 100% progress for completed
    } else if (status.contains('cancelled')) {
      chipColor = const Color(0xFF9E9E9E);
      borderColor = const Color(0xFFBDBDBD);
      statusProgress = 0.0; // 0% progress for cancelled
    } else {
      chipColor = theme.colorScheme.primary;
      borderColor = theme.colorScheme.primary.withValues(alpha: 0.5);
      statusProgress = 0.3; // Default 30% progress
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: chipColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status text
          Text(
            project.status.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              height: 1.1,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3.0,
                  color: Color.fromARGB(150, 0, 0, 0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tab-style progress bar
          Container(
            width: 80,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: statusProgress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectProgressBar(BuildContext context, Project project) {
    final theme = Theme.of(context);
    final progress = project.progressPercentage ?? 0.0;
    
    return Row(
      children: [
        // Progress percentage text
        Text(
          '${progress.toStringAsFixed(1)}%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Progress bar
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(BuildContext context, Project project) {
    final theme = Theme.of(context);
    final progress = project.progressPercentage ?? 0.0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pie_chart_outline,
                color: theme.colorScheme.secondary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '${progress.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 4.0,
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 60,
            height: 4,
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.secondary,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 2.0,
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              height: 1.2,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 3.0,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year.toString();
    return '$day $month $year';
  }
}
