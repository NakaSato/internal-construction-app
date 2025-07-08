import 'package:flutter/material.dart';

import '../../../domain/entities/project_api_models.dart';
import '../../widgets/project_filter_bottom_sheet.dart';

/// Handles filtering functionality for the project list screen
///
/// This class manages:
/// - Filter bottom sheet display
/// - Filter state management
/// - Filter application logic
/// - Filter count tracking
class ProjectListFilterHandler {
  final BuildContext context;
  final void Function(ProjectsQuery) onFilterApplied;

  ProjectsQuery _currentQuery;

  ProjectListFilterHandler({required this.context, required this.onFilterApplied, ProjectsQuery? initialQuery})
    : _currentQuery = initialQuery ?? const ProjectsQuery();

  /// Show filter bottom sheet
  void showFilterBottomSheet() {
    showModalBottomSheet<ProjectsQuery>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectFilterBottomSheet(currentQuery: _currentQuery, onApplyFilters: _applyFilters),
    );
  }

  /// Apply filters and update query
  void _applyFilters(ProjectsQuery newQuery) {
    _currentQuery = newQuery;
    onFilterApplied(newQuery);
  }

  /// Update current query
  void updateQuery(ProjectsQuery newQuery) {
    _currentQuery = newQuery;
  }

  /// Get current query
  ProjectsQuery get currentQuery => _currentQuery;

  /// Check if filters are active
  bool get hasActiveFilters => _currentQuery.hasActiveFilters;

  /// Get active filter count
  int get activeFilterCount => _currentQuery.activeFilterCount;

  /// Clear all filters
  void clearAllFilters() {
    const clearedQuery = ProjectsQuery();
    _currentQuery = clearedQuery;
    onFilterApplied(clearedQuery);
  }
}
