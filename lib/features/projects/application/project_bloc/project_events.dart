import 'package:equatable/equatable.dart';
import '../../domain/entities/project_api_models.dart';

/// Events for Project BLoC
abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

/// Load projects with optional query and user role filtering
class LoadProjectsRequested extends ProjectEvent {
  const LoadProjectsRequested({this.query, this.userRole, this.skipLoadingState = false, this.forceRefresh = false});

  final ProjectsQuery? query;
  final String? userRole;
  final bool skipLoadingState;
  final bool forceRefresh;

  @override
  List<Object?> get props => [query, userRole, skipLoadingState, forceRefresh];
}

/// Search projects with term and optional filters
class SearchProjectsRequested extends ProjectEvent {
  const SearchProjectsRequested({required this.searchTerm, this.filters, this.userRole});

  final String searchTerm;
  final ProjectsQuery? filters;
  final String? userRole;

  @override
  List<Object?> get props => [searchTerm, filters, userRole];
}

/// Load specific project details
class LoadProjectDetailsRequested extends ProjectEvent {
  const LoadProjectDetailsRequested({required this.projectId, this.userRole});

  final String projectId;
  final String? userRole;

  @override
  List<Object?> get props => [projectId, userRole];
}

/// Create a new project
class CreateProjectRequested extends ProjectEvent {
  const CreateProjectRequested({required this.projectData, this.userRole});

  final Map<String, dynamic> projectData;
  final String? userRole;

  @override
  List<Object?> get props => [projectData, userRole];
}

/// Update an existing project
class UpdateProjectRequested extends ProjectEvent {
  const UpdateProjectRequested({required this.projectId, required this.projectData, this.userRole});

  final String projectId;
  final Map<String, dynamic> projectData;
  final String? userRole;

  @override
  List<Object?> get props => [projectId, projectData, userRole];
}

/// Delete a project
class DeleteProjectRequested extends ProjectEvent {
  const DeleteProjectRequested({required this.projectId});

  final String projectId;

  @override
  List<Object?> get props => [projectId];
}

/// Load project statistics
class LoadProjectStatisticsRequested extends ProjectEvent {
  const LoadProjectStatisticsRequested({this.userRole, this.managerId});

  final String? userRole;
  final String? managerId;

  @override
  List<Object?> get props => [userRole, managerId];
}

/// Load projects by manager
class LoadProjectsByManagerRequested extends ProjectEvent {
  const LoadProjectsByManagerRequested({required this.managerId, this.userRole});

  final String managerId;
  final String? userRole;

  @override
  List<Object?> get props => [managerId, userRole];
}

// Real-time events
/// Receive real-time project update
class RealTimeProjectUpdateReceived extends ProjectEvent {
  const RealTimeProjectUpdateReceived({required this.project});

  final Project project;

  @override
  List<Object?> get props => [project];
}

/// Receive real-time project creation notification
class RealTimeProjectCreatedReceived extends ProjectEvent {
  const RealTimeProjectCreatedReceived({required this.project});

  final Project project;

  @override
  List<Object?> get props => [project];
}

/// Receive real-time project deletion notification
class RealTimeProjectDeletedReceived extends ProjectEvent {
  const RealTimeProjectDeletedReceived({required this.projectId});

  final String projectId;

  @override
  List<Object?> get props => [projectId];
}

/// Initialize real-time connection
class InitializeRealTimeConnection extends ProjectEvent {}

/// Refresh projects with cache clear
class RefreshProjectsWithCacheClear extends ProjectEvent {
  const RefreshProjectsWithCacheClear({this.userRole, this.query, this.skipLoadingState = false});

  final String? userRole;
  final ProjectsQuery? query;
  final bool skipLoadingState;

  @override
  List<Object?> get props => [userRole, query, skipLoadingState];
}

/// Start live project updates
class StartLiveProjectUpdates extends ProjectEvent {
  const StartLiveProjectUpdates({this.userRole, this.query, this.maxRetries = 3});

  final String? userRole;
  final ProjectsQuery? query;
  final int maxRetries;

  @override
  List<Object?> get props => [userRole, query, maxRetries];
}

/// Stop live project updates
class StopLiveProjectUpdates extends ProjectEvent {}

/// Receive live project update
class LiveProjectUpdateReceived extends ProjectEvent {
  const LiveProjectUpdateReceived({required this.projectsResponse});

  final ProjectsResponse projectsResponse;

  @override
  List<Object?> get props => [projectsResponse];
}

/// Receive project realtime update
class ProjectRealtimeUpdateReceived extends ProjectEvent {
  const ProjectRealtimeUpdateReceived({required this.projectsResponse});

  final ProjectsResponse projectsResponse;

  @override
  List<Object?> get props => [projectsResponse];
}

/// Start project realtime updates
class StartProjectRealtimeUpdates extends ProjectEvent {
  const StartProjectRealtimeUpdates({this.userRole, this.query});

  final String? userRole;
  final ProjectsQuery? query;

  @override
  List<Object?> get props => [userRole, query];
}

/// Stop project realtime updates
class StopProjectRealtimeUpdates extends ProjectEvent {}

/// Refresh projects after detail view
class RefreshProjectsAfterDetailView extends ProjectEvent {
  const RefreshProjectsAfterDetailView({this.userRole});

  final String? userRole;

  @override
  List<Object?> get props => [userRole];
}
