import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/project_api_models.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_api_service.dart';
import '../models/project_response.dart';

/// API implementation of the enhanced project repository
@Injectable(
  as: EnhancedProjectRepository,
  env: [Environment.dev, Environment.prod],
)
class ApiProjectRepository implements EnhancedProjectRepository {
  const ApiProjectRepository(this._apiService);

  final ProjectApiService _apiService;

  @override
  Future<ProjectsResponse> getAllProjects(ProjectsQuery query) async {
    if (kDebugMode) {
      debugPrint('🚀 ApiProjectRepository.getAllProjects called');
      debugPrint('📝 Query parameters: ${query.toQueryParameters()}');
    }

    try {
      // Convert ProjectsQuery to API response format
      final response = await _apiService.getProjects(query.toQueryParameters());

      if (kDebugMode) {
        debugPrint('✅ API call successful');
        debugPrint('📊 Response: ${response.toString()}');
        debugPrint('📊 Response Type: ${response.runtimeType}');
        debugPrint('📊 Response Data Type: ${response.data.runtimeType}');
        debugPrint('📊 Response Items Count: ${response.data.items.length}');
      }

      return _convertToProjectsResponse(response);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DioException in getAllProjects:');
        debugPrint('  Status Code: ${e.response?.statusCode}');
        debugPrint('  Request URL: ${e.requestOptions.uri}');
        debugPrint('  Request Headers: ${e.requestOptions.headers}');
        debugPrint('  Error Message: ${e.message}');
        debugPrint('  Response Data: ${e.response?.data}');
      }
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ General exception in getAllProjects: $e');
        debugPrint('🔍 Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  @override
  Future<EnhancedProject> getProjectById(String id) async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 Loading project details for ID: $id');
      }

      final response = await _apiService.getProject(id);

      if (kDebugMode) {
        debugPrint('✅ Received project detail response: ${response.data}');
      }

      // Convert the single project response data directly to EnhancedProject
      return _convertSingleProjectToEnhanced(response.data);
    } on DioException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ DioException in getProjectById for ID $id: ${e.message}');
        debugPrint('🔍 Response: ${e.response?.data}');
        debugPrint('🔍 Status code: ${e.response?.statusCode}');
        debugPrint('🔍 Stack trace: $stackTrace');
      }
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ General exception in getProjectById for ID $id: $e');
        debugPrint('🔍 Stack trace: $stackTrace');
      }
      rethrow;
    }
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
    try {
      if (kDebugMode) {
        debugPrint('🔄 Converting ProjectResponse to ProjectsResponse');
        debugPrint(
          '📊 Response data items count: ${response.data.items.length}',
        );
      }

      // Extract project data from the API response with safety checks
      final projects = <EnhancedProject>[];
      for (int i = 0; i < response.data.items.length; i++) {
        try {
          final item = response.data.items[i];
          if (kDebugMode) {
            debugPrint('🔄 Converting item $i: ${item.runtimeType}');
          }

          // Convert ProjectDto to EnhancedProject directly without toJson() conversion
          final project = EnhancedProject(
            projectId: item.projectId,
            projectName: item.projectName,
            address: item.address,
            clientInfo: item.clientInfo,
            status: item.status,
            startDate: item.startDate,
            estimatedEndDate: item.estimatedEndDate,
            actualEndDate: item.actualEndDate,
            createdAt:
                item.startDate, // Use startDate as fallback for createdAt
            updatedAt:
                DateTime.now(), // Use current time as fallback for updatedAt
            projectManager: item.projectManager != null
                ? ProjectManager(
                    userId: item.projectManager!.userId,
                    username: item.projectManager!.username,
                    fullName: item.projectManager!.fullName,
                    email: item.projectManager!.email,
                  )
                : null,
            taskCount: item.taskCount,
            completedTaskCount: item.completedTaskCount,
          );
          projects.add(project);

          if (kDebugMode) {
            debugPrint('✅ Successfully converted item $i to EnhancedProject');
          }
        } catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint('❌ Error converting item $i: $e');
            debugPrint('🔍 Item data: ${response.data.items[i]}');
            debugPrint('🔍 Stack trace: $stackTrace');
          }
          // Skip this item and continue with others
          continue;
        }
      }

      final result = ProjectsResponse(
        items: projects,
        totalCount: response.data.totalCount,
        pageNumber: response.data.pageNumber,
        pageSize: response.data.pageSize,
        totalPages: response.data.totalPages,
        hasPreviousPage: response.data.pageNumber > 1,
        hasNextPage: response.data.pageNumber < response.data.totalPages,
      );

      if (kDebugMode) {
        debugPrint('✅ Successfully converted ${projects.length} projects');
      }

      return result;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error in _convertToProjectsResponse: $e');
        debugPrint('🔍 Stack trace: $stackTrace');
        debugPrint('🔍 Response data: ${response.data}');
      }
      rethrow;
    }
  }

  // Helper method to convert single project response to domain model
  EnhancedProject _convertSingleProjectToEnhanced(
    Map<String, dynamic> projectData,
  ) {
    if (kDebugMode) {
      debugPrint('🔄 Converting single project data: ${projectData.keys}');
    }

    return EnhancedProject(
      projectId: projectData['projectId']?.toString() ?? '',
      projectName: projectData['projectName']?.toString() ?? '',
      address: projectData['address']?.toString() ?? '',
      clientInfo: projectData['clientInfo']?.toString() ?? '',
      status: projectData['status']?.toString() ?? 'planning',
      startDate: projectData['startDate'] != null
          ? DateTime.tryParse(projectData['startDate'].toString()) ??
                DateTime.now()
          : DateTime.now(),
      estimatedEndDate: projectData['estimatedEndDate'] != null
          ? DateTime.tryParse(projectData['estimatedEndDate'].toString()) ??
                DateTime.now()
          : DateTime.now(),
      actualEndDate: projectData['actualEndDate'] != null
          ? DateTime.tryParse(projectData['actualEndDate'].toString())
          : null,
      createdAt: projectData['createdAt'] != null
          ? DateTime.tryParse(projectData['createdAt'].toString()) ??
                DateTime.now()
          : DateTime.now(),
      updatedAt: projectData['updatedAt'] != null
          ? DateTime.tryParse(projectData['updatedAt'].toString()) ??
                DateTime.now()
          : DateTime.now(),
      projectManager: projectData['projectManager'] != null
          ? ProjectManager.fromJson(
              projectData['projectManager'] as Map<String, dynamic>,
            )
          : null,
      taskCount: (projectData['taskCount'] as num?)?.toInt() ?? 0,
      completedTaskCount:
          (projectData['completedTaskCount'] as num?)?.toInt() ?? 0,
      team: projectData['team']?.toString(),
      connectionType: projectData['connectionType']?.toString(),
      connectionNotes: projectData['connectionNotes']?.toString(),
      totalCapacityKw: (projectData['totalCapacityKw'] as num?)?.toDouble(),
      pvModuleCount: (projectData['pvModuleCount'] as num?)?.toInt(),
      equipmentDetails: null, // Would need proper parsing for this
      ftsValue: (projectData['ftsValue'] as num?)?.toDouble(),
      revenueValue: (projectData['revenueValue'] as num?)?.toDouble(),
      pqmValue: (projectData['pqmValue'] as num?)?.toDouble(),
      locationCoordinates: null, // Would need proper parsing for this
    );
  }
}
