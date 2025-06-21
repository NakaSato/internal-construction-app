import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/project_management/application/project_bloc.dart';
import '../../../features/project_management/application/project_state.dart';
import '../../../features/project_management/domain/entities/project.dart';
import 'dashboard_constants.dart';

/// Project statistics section displaying status-based project counts
/// Provides an overview of projects grouped by their status with color-coded indicators
class ProjectStatisticsSection extends StatefulWidget {
  const ProjectStatisticsSection({
    super.key,
    this.onStatusSelected,
    this.selectedStatus,
  });

  /// Callback triggered when a status card is tapped
  final ValueChanged<ProjectStatus?>? onStatusSelected;

  /// Currently selected status for filtering (null means all projects)
  final ProjectStatus? selectedStatus;

  @override
  State<ProjectStatisticsSection> createState() =>
      _ProjectStatisticsSectionState();
}

class _ProjectStatisticsSectionState extends State<ProjectStatisticsSection> {
  ProjectStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.selectedStatus;
  }

  @override
  void didUpdateWidget(ProjectStatisticsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedStatus != oldWidget.selectedStatus) {
      _selectedStatus = widget.selectedStatus;
    }
  }

  void _handleStatusTap(ProjectStatus? status) {
    setState(() {
      _selectedStatus = _selectedStatus == status ? null : status;
    });
    widget.onStatusSelected?.call(_selectedStatus);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoading) {
          return _buildLoadingState(context);
        }

        if (state is ProjectError) {
          return _buildErrorState(context, state.message);
        }

        if (state is ProjectLoaded) {
          return _buildStatisticsCards(context, state.projects);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DashboardConstants.borderRadius),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(DashboardConstants.smallSpacing),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(DashboardConstants.borderRadius),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 20,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(height: 4),
            Text(
              'Failed to load statistics',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, List<Project> projects) {
    final statistics = _calculateStatistics(projects);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatCard(
            count: statistics.total,
            label: 'All Projects',
            color: Theme.of(context).colorScheme.primary,
            isSelected: _selectedStatus == null,
            onTap: () => _handleStatusTap(null),
          ),
          const SizedBox(width: DashboardConstants.smallSpacing),
          _StatCard(
            count: statistics.inProgress,
            label: 'In Progress',
            color: Theme.of(context).colorScheme.tertiary,
            isSelected: _selectedStatus == ProjectStatus.inProgress,
            onTap: () => _handleStatusTap(ProjectStatus.inProgress),
          ),
          const SizedBox(width: DashboardConstants.smallSpacing),
          _StatCard(
            count: statistics.completed,
            label: 'Completed',
            color: const Color(0xFF4CAF50), // Material Design Green
            isSelected: _selectedStatus == ProjectStatus.completed,
            onTap: () => _handleStatusTap(ProjectStatus.completed),
          ),
          const SizedBox(width: DashboardConstants.smallSpacing),
          _StatCard(
            count: statistics.planning,
            label: 'Planning',
            color: Theme.of(context).colorScheme.secondary,
            isSelected: _selectedStatus == ProjectStatus.planning,
            onTap: () => _handleStatusTap(ProjectStatus.planning),
          ),
          const SizedBox(width: DashboardConstants.smallSpacing),
          _StatCard(
            count: statistics.onHold,
            label: 'On Hold',
            color: const Color(0xFFFF9800), // Material Design Orange
            isSelected: _selectedStatus == ProjectStatus.onHold,
            onTap: () => _handleStatusTap(ProjectStatus.onHold),
          ),
          if (statistics.cancelled > 0) ...[
            const SizedBox(width: DashboardConstants.smallSpacing),
            _StatCard(
              count: statistics.cancelled,
              label: 'Cancelled',
              color: Theme.of(context).colorScheme.error,
              isSelected: _selectedStatus == ProjectStatus.cancelled,
              onTap: () => _handleStatusTap(ProjectStatus.cancelled),
            ),
          ],
        ],
      ),
    );
  }

  ProjectStatistics _calculateStatistics(List<Project> projects) {
    return ProjectStatistics(
      total: projects.length,
      planning: projects
          .where((p) => p.projectStatus == ProjectStatus.planning)
          .length,
      inProgress: projects
          .where((p) => p.projectStatus == ProjectStatus.inProgress)
          .length,
      onHold: projects
          .where((p) => p.projectStatus == ProjectStatus.onHold)
          .length,
      completed: projects
          .where((p) => p.projectStatus == ProjectStatus.completed)
          .length,
      cancelled: projects
          .where((p) => p.projectStatus == ProjectStatus.cancelled)
          .length,
    );
  }
}

/// Data class to hold project statistics
class ProjectStatistics {
  const ProjectStatistics({
    required this.total,
    required this.planning,
    required this.inProgress,
    required this.onHold,
    required this.completed,
    required this.cancelled,
  });

  final int total;
  final int planning;
  final int inProgress;
  final int onHold;
  final int completed;
  final int cancelled;
}

/// Individual statistic card widget
class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _StatCard({
    required this.count,
    required this.label,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DashboardConstants.borderRadius),
        child: Container(
          width: 120, // Fixed width for horizontal scrolling
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(
              DashboardConstants.borderRadius,
            ),
            border: isSelected
                ? Border.all(color: color, width: 2)
                : Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: isSelected
                      ? color
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? color
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
