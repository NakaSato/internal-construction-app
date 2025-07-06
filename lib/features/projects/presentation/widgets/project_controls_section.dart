import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/project_bloc.dart';
import '../../domain/entities/project_api_models.dart';
import 'project_search_bar.dart';
import 'project_filter_bottom_sheet.dart';
import 'project_status_bar.dart';

/// Widget that encapsulates the search controls and status bar
class ProjectControlsSection extends StatelessWidget {
  final TextEditingController searchController;
  final ProjectsQuery currentQuery;
  final bool isRealtimeConnected;
  final bool isLiveReloadEnabled;
  final bool isSilentRefreshing;
  final void Function(String) onSearchChanged;
  final void Function(ProjectsQuery) onFilterApplied;
  final VoidCallback onToggleLiveReload;
  final VoidCallback onManualSync;

  const ProjectControlsSection({
    super.key,
    required this.searchController,
    required this.currentQuery,
    required this.isRealtimeConnected,
    required this.isLiveReloadEnabled,
    required this.isSilentRefreshing,
    required this.onSearchChanged,
    required this.onFilterApplied,
    required this.onToggleLiveReload,
    required this.onManualSync,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProjectStatusBar(
          isRealtimeConnected: isRealtimeConnected,
          isLiveReloadEnabled: isLiveReloadEnabled,
          isSilentRefreshing: isSilentRefreshing,
          onToggleLiveReload: onToggleLiveReload,
          onManualSync: onManualSync,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: ProjectSearchBar(
            controller: searchController,
            onChanged: onSearchChanged,
            onFilterTap: () => _showFilterBottomSheet(context),
            hintText: 'Search projects by name, client, or address...',
            onClearSearch: () {
              context.read<ProjectBloc>().add(LoadProjectsRequested(query: currentQuery));
            },
            showActiveFilters: currentQuery.hasActiveFilters,
            activeFilterCount: currentQuery.activeFilterCount,
            currentQuery: currentQuery,
            onQueryChanged: (newQuery) {
              onFilterApplied(newQuery);
              context.read<ProjectBloc>().add(LoadProjectsRequested(query: newQuery));
            },
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet<ProjectsQuery>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectFilterBottomSheet(currentQuery: currentQuery, onApplyFilters: onFilterApplied),
    );
  }
}
