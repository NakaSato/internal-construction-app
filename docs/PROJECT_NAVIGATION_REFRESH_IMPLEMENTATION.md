# Project Navigation Refresh Implementation

## Overview
This document details the implementation of enhanced data refresh capabilities when navigating between project list and detail screens in the Solar Mana app.

## Problem
When users navigated from project detail screens back to the project list, or when switching between different project details, the app would sometimes:

1. Display stale data
2. Not reflect recent changes made on detail screens
3. Not properly maintain context of recently viewed projects
4. Unnecessarily trigger full reloads causing UI flicker

## Solution

### 1. Navigation State Tracking

We implemented a comprehensive navigation state tracking system that:

```dart
void _setupNavigationListener() {
  AppRouter.router.routeInformationProvider.addListener(_handleRouteChange);
}

void _handleRouteChange() {
  final location = AppRouter.router.routeInformationProvider.value.uri.path;
  final isProjectDetail = location.contains('/projects/') && !location.endsWith('/projects');
  
  if (isProjectDetail && !_isInProjectDetailView) {
    // Entering project detail
    _isInProjectDetailView = true;
    _lastProjectDetailVisit = DateTime.now();
  } else if (!isProjectDetail && _isInProjectDetailView) {
    // Returning from project detail
    _isInProjectDetailView = false;
    _handleReturnFromProjectDetail();
  }
}
```

### 2. Intelligent Refresh Logic

When returning from project detail screens, we implemented smarter refresh logic:

```dart
void _handleReturnFromProjectDetail() {
  // Only refresh if enough time has passed on the detail screen
  final timeSinceVisit = _lastProjectDetailVisit != null
      ? DateTime.now().difference(_lastProjectDetailVisit!)
      : const Duration(seconds: 0);

  if (timeSinceVisit.inSeconds > 2) {
    // Extract recently viewed project ID
    final location = AppRouter.router.routeInformationProvider.value.uri.path;
    final recentProjectId = _extractProjectIdFromRoute(location);
    
    // Use specialized refresh event
    projectBloc.add(RefreshProjectsAfterDetailView(recentProjectId: recentProjectId));
  }
}
```

### 3. Specialized Event for Detail-to-List Navigation

We added a dedicated event to handle the specific case of returning from detail views:

```dart
class RefreshProjectsAfterDetailView extends ProjectEvent {
  const RefreshProjectsAfterDetailView({this.recentProjectId});
  final String? recentProjectId;
}
```

The handler for this event uses optimized refresh logic:

```dart
Future<void> _onRefreshProjectsAfterDetailView(RefreshProjectsAfterDetailView event, Emitter<ProjectState> emit) async {
  // Skip loading state for better UX
  if (state is ProjectsLoaded) {
    // Keep showing current data while fetching fresh data
    final projectsResponse = await _repository.getAllProjects(const ProjectsQuery());
    emit(ProjectsLoaded(projectsResponse: projectsResponse));
  }
}
```

### 4. App Lifecycle Integration

We also enhanced app lifecycle handling to refresh data properly when resuming the app:

```dart
void _onAppResumed() {
  _validateSessionOnResume();
  
  // Get current route
  final currentLocation = AppRouter.router.routeInformationProvider.value.uri.path;
  final isProjectDetail = currentLocation.contains('/projects/') && !currentLocation.endsWith('/projects');
  
  if (isProjectDetail) {
    // If on project detail, refresh that specific project
    _refreshCurrentProjectDetail(currentLocation);
  } else {
    // Otherwise refresh the project list
    _forceRefreshDashboard();
  }
}
```

## Benefits

- **Smoother Navigation**: Transitions between project list and detail views are now more seamless
- **Context Awareness**: The app maintains context of recently viewed projects
- **Optimized Loading**: Uses skipLoadingState for better UX during navigation
- **Reduced Flickering**: Smarter refresh logic prevents unnecessary UI reloads
- **Improved Data Consistency**: Users always see the most up-to-date project data

## Testing

This implementation has been tested in various navigation scenarios:

1. Quick navigation between list and detail views
2. Longer detail view sessions followed by returning to list
3. App backgrounding/resuming while on different project screens
4. Multiple rapid transitions between different project details

The improvements ensure data consistency while maintaining optimal performance and user experience.
