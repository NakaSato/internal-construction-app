import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/project_management/application/project_bloc.dart';
import '../../../features/project_management/application/project_state.dart';
import '../../../features/project_management/domain/entities/project.dart';
import 'dashboard_constants.dart';

/// Statistics section similar to the status counts in the image
class ProjectStatisticsSection extends StatelessWidget {
  const ProjectStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoaded) {
          final projects = state.projects;
          final allCount = projects.length;
          final completedCount = projects
              .where((p) => p.projectStatus == ProjectStatus.completed)
              .length;
          final inProgressCount = projects
              .where((p) => p.projectStatus == ProjectStatus.inProgress)
              .length;
          final onHoldCount = projects
              .where((p) => p.projectStatus == ProjectStatus.onHold)
              .length;

          return Row(
            children: [
              Expanded(
                child: _StatCard(
                  count: allCount,
                  label: 'All',
                  color: Theme.of(context).colorScheme.primary,
                  isSelected: true,
                ),
              ),
              const SizedBox(width: DashboardConstants.smallSpacing),
              Expanded(
                child: _StatCard(
                  count: completedCount,
                  label: 'Normal',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: DashboardConstants.smallSpacing),
              Expanded(
                child: _StatCard(
                  count: inProgressCount,
                  label: 'Faulty',
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: DashboardConstants.smallSpacing),
              Expanded(
                child: _StatCard(
                  count: onHoldCount,
                  label: 'Offline',
                  color: Colors.grey,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Individual statistic card widget
class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final bool isSelected;

  const _StatCard({
    required this.count,
    required this.label,
    required this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DashboardConstants.borderRadius),
        border: isSelected ? Border.all(color: color, width: 2) : null,
      ),
      child: Column(
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
          ),
        ],
      ),
    );
  }
}
