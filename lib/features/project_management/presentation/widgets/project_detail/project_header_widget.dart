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
      expandedHeight: 240.0,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          project.projectName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(130, 0, 0, 0),
              ),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background image or gradient
            if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
              Image.network(
                project.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset('assets/images/header.jpg', fit: BoxFit.cover),
              )
            else
              Image.asset('assets/images/header.jpg', fit: BoxFit.cover),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // Project info overlay
            Positioned(
              bottom: 60,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusChip(context, project),
                  const SizedBox(height: 8),
                  if (project.location != null && project.location!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            project.location!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatDate(project.startDate)} - ${_formatDate(project.estimatedEndDate)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (project.progressPercentage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.pie_chart,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${project.progressPercentage!.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: onShare,
          tooltip: 'Share Project',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'delete':
                onDelete?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            if (onEdit != null)
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Project'),
                  ],
                ),
              ),
            if (onDelete != null)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 8),
                    Text('Delete Project'),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, Project project) {
    final theme = Theme.of(context);
    final status = project.status.toLowerCase();
    Color chipColor;
    IconData statusIcon;

    if (status.contains('active') || status.contains('in progress')) {
      chipColor = Colors.green;
      statusIcon = Icons.trending_up;
    } else if (status.contains('planning')) {
      chipColor = Colors.blue;
      statusIcon = Icons.edit_calendar;
    } else if (status.contains('hold')) {
      chipColor = Colors.orange;
      statusIcon = Icons.pause_circle;
    } else if (status.contains('completed')) {
      chipColor = Colors.teal;
      statusIcon = Icons.check_circle;
    } else if (status.contains('cancelled')) {
      chipColor = Colors.grey;
      statusIcon = Icons.cancel;
    } else {
      chipColor = theme.colorScheme.primary;
      statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            project.status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
