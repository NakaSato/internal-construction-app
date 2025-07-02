import 'package:injectable/injectable.dart';
import '../../domain/entities/project_api_models.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_api_service.dart';
import '../models/project_response.dart';

/// API implementation of the enhanced project repository
@Injectable(as: EnhancedProjectRepository, env: [Environment.prod])
class ApiProjectRepository implements EnhancedProjectRepository {
  const ApiProjectRepository(this._apiService);

  final ProjectApiService _apiService;

  @override
  Future<ProjectsResponse> getAllProjects(ProjectsQuery query) async {
    // Convert ProjectsQuery to API response format
    final response = await _apiService.getProjects(query.toQueryParameters());
    return _convertToProjectsResponse(response);
  }

  @override
  Future<EnhancedProject> getProjectById(String id) async {
    final response = await _apiService.getProject(id);
    return _convertToEnhancedProject(response);
  }

  @override
  Future<EnhancedProject> createProject(
    Map<String, dynamic> projectData,
  ) async {
    // For now, return a mock implementation
    // This will need to be implemented when the API has a create endpoint
    throw UnimplementedError('Create project API endpoint not yet implemented');
  }

  @override
  Future<EnhancedProject> updateProject(
    String id,
    Map<String, dynamic> projectData,
  ) async {
    // For now, return a mock implementation
    // This will need to be implemented when the API has an update endpoint
    throw UnimplementedError('Update project API endpoint not yet implemented');
  }

  @override
  Future<void> deleteProject(String id) async {
    // For now, return a mock implementation
    // This will need to be implemented when the API has a delete endpoint
    throw UnimplementedError('Delete project API endpoint not yet implemented');
  }

  @override
  Future<ProjectsResponse> getProjectsByManager(
    String managerId,
    ProjectsQuery query,
  ) async {
    final updatedQuery = query.copyWith(managerId: managerId);
    return getAllProjects(updatedQuery);
  }

  @override
  Future<ProjectsResponse> getProjectsByStatus(
    String status,
    ProjectsQuery query,
  ) async {
    final updatedQuery = query.copyWith(status: status);
    return getAllProjects(updatedQuery);
  }

  @override
  Future<ProjectsResponse> searchProjects(
    String searchQuery,
    ProjectsQuery query,
  ) async {
    final updatedQuery = query.copyWith(filter: searchQuery);
    return getAllProjects(updatedQuery);
  }

  @override
  Future<Map<String, dynamic>> getProjectStatistics() async {
    // For now, return a basic implementation
    // This can be enhanced when the API provides a dedicated statistics endpoint
    return {'total': 0, 'active': 0, 'completed': 0};
  }

  @override
  Future<ProjectsResponse> getProjectsNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
    ProjectsQuery query,
  ) async {
    final locationFilter = 'location:$latitude,$longitude,$radiusKm';
    final updatedQuery = query.copyWith(filter: locationFilter);
    return getAllProjects(updatedQuery);
  }

  // Helper method to convert API response to domain model
  ProjectsResponse _convertToProjectsResponse(ProjectResponse response) {
    // Extract project data from the API response
    final projects = response.data.items
        .map((item) => EnhancedProject.fromJson(item.toJson()))
        .toList();

    return ProjectsResponse(
      items: projects,
      totalCount: response.data.totalCount,
      pageNumber: response.data.pageNumber,
      pageSize: response.data.pageSize,
      totalPages: response.data.totalPages,
      hasPreviousPage: response.data.pageNumber > 1,
      hasNextPage: response.data.pageNumber < response.data.totalPages,
    );
  }

  // Helper method to convert single project response to domain model
  EnhancedProject _convertToEnhancedProject(dynamic projectData) {
    // If it's a ProjectResponse with data, extract the first project
    if (projectData is ProjectResponse && projectData.data.items.isNotEmpty) {
      final project = projectData.data.items.first;
      return EnhancedProject.fromJson(project.toJson());
    }

    throw ArgumentError('Invalid project data format or no projects found');
  }
}
