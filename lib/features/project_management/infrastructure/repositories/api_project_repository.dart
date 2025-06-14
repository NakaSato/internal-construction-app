import 'package:dio/dio.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../services/project_api_service.dart';
import '../models/project_response.dart';

/// API-based implementation of ProjectRepository
class ApiProjectRepository implements ProjectRepository {
  const ApiProjectRepository(this._apiService);

  final ProjectApiService _apiService;

  @override
  Future<List<Project>> getAllProjects() async {
    return getProjects();
  }

  @override
  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async {
    // Note: This would need to be implemented based on API capabilities
    // For now, get all projects and filter client-side
    final projects = await getProjects();
    return projects
        .where((project) => project.projectStatus == status)
        .toList();
  }

  @override
  Future<Project?> getProjectById(String id) async {
    try {
      final response = await _apiService.getProject(id);

      if (response.success && response.data.items.isNotEmpty) {
        return response.data.items.first.toEntity();
      }

      return null;
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<Project> createProject(Project project) async {
    // TODO: Implement when create API is available
    throw UnimplementedError('Create project not yet implemented');
  }

  @override
  Future<Project> updateProject(Project project) async {
    // TODO: Implement when update API is available
    throw UnimplementedError('Update project not yet implemented');
  }

  @override
  Future<void> deleteProject(String id) async {
    // TODO: Implement when delete API is available
    throw UnimplementedError('Delete project not yet implemented');
  }

  @override
  Future<List<Project>> searchProjects(String query) async {
    // Note: This would need to be implemented based on API capabilities
    // For now, get all projects and filter client-side
    final projects = await getProjects();
    return projects
        .where(
          (project) =>
              project.projectName.toLowerCase().contains(query.toLowerCase()) ||
              project.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<List<Project>> getProjectsByUserId(String userId) async {
    // Use managerId parameter to filter by user
    return getProjects(managerId: userId);
  }

  /// Get projects with pagination and optional filtering
  Future<List<Project>> getProjects({
    int pageNumber = 1,
    int pageSize = 10,
    String? managerId,
  }) async {
    try {
      final request = ProjectsListRequest(
        pageNumber: pageNumber,
        pageSize: pageSize,
        managerId: managerId,
      );

      final response = await _apiService.getProjects(
        request.toQueryParameters(),
      );

      if (response.success) {
        return response.data.items.map((dto) => dto.toEntity()).toList();
      } else {
        throw Exception('Failed to fetch projects: ${response.message}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get projects with pagination metadata
  Future<ProjectData> getProjectsWithPagination({
    int pageNumber = 1,
    int pageSize = 10,
    String? managerId,
  }) async {
    try {
      final request = ProjectsListRequest(
        pageNumber: pageNumber,
        pageSize: pageSize,
        managerId: managerId,
      );

      final response = await _apiService.getProjects(
        request.toQueryParameters(),
      );

      if (response.success) {
        return response.data;
      } else {
        throw Exception('Failed to fetch projects: ${response.message}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
