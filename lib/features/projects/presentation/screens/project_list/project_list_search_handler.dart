import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/project_bloc.dart';
import '../../../domain/entities/project_api_models.dart';

/// Handles search functionality for the project list screen
///
/// This class manages:
/// - Search input processing
/// - Search term validation
/// - BLoC event dispatching for search operations
/// - Search state management
class ProjectListSearchHandler {
  final BuildContext context;
  final TextEditingController searchController;
  final void Function(ProjectsQuery) onQueryChanged;

  ProjectsQuery _currentQuery;

  ProjectListSearchHandler({
    required this.context,
    required this.searchController,
    required this.onQueryChanged,
    ProjectsQuery? initialQuery,
  }) : _currentQuery = initialQuery ?? const ProjectsQuery();

  /// Handle search input changes
  void onSearchChanged(String searchTerm) {
    final trimmedTerm = searchTerm.trim();

    if (trimmedTerm.isEmpty) {
      // Load all projects if search is empty
      context.read<ProjectBloc>().add(
        LoadProjectsRequested(
          query: _currentQuery,
          skipLoadingState: true, // Skip loading state for better UX during search
        ),
      );
    } else {
      // Search projects with current filters
      context.read<ProjectBloc>().add(SearchProjectsRequested(searchTerm: trimmedTerm, filters: _currentQuery));
    }
  }

  /// Clear search and reload projects
  void clearSearch() {
    searchController.clear();
    context.read<ProjectBloc>().add(LoadProjectsRequested(query: _currentQuery));
  }

  /// Update current query (used when filters change)
  void updateQuery(ProjectsQuery newQuery) {
    _currentQuery = newQuery;
    onQueryChanged(newQuery);
  }

  /// Get current query
  ProjectsQuery get currentQuery => _currentQuery;

  /// Check if search is active
  bool get isSearchActive => searchController.text.trim().isNotEmpty;

  /// Get current search term
  String get searchTerm => searchController.text.trim();

  /// Perform search with the current term and new query
  void searchWithQuery(ProjectsQuery newQuery) {
    _currentQuery = newQuery;
    onQueryChanged(newQuery);

    final searchTerm = this.searchTerm;
    if (searchTerm.isNotEmpty) {
      context.read<ProjectBloc>().add(SearchProjectsRequested(searchTerm: searchTerm, filters: newQuery));
    } else {
      context.read<ProjectBloc>().add(
        LoadProjectsRequested(
          query: newQuery,
          skipLoadingState: false, // Show loading state when applying filters
          forceRefresh: true, // Always get fresh data when filters change
        ),
      );
    }
  }
}
