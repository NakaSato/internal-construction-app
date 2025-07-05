import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../common/utils/error_extensions.dart';
import '../../domain/entities/project_api_models.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_api_service.dart';
import '../models/project_response.dart';

/// API implementation of the enhanced project repository
@Injectable(as: EnhancedProjectRepository, env: [Environment.dev, Environment.prod])
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

  /// Validates if the project ID format is correct (UUID)
  /// Returns error message if invalid, null if valid
  String? _validateProjectId(String id) {
    if (id.isEmpty) {
      return 'Project ID cannot be empty.';
    }

    if (id.length != 36) {
      return 'Project ID must be 36 characters long (UUID format).';
    }

    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

    if (!uuidRegex.hasMatch(id)) {
      return 'Invalid project ID format. Expected format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
    }

    return null; // Valid
  }

  @override
  Future<EnhancedProject> getProjectById(String id) async {
    try {
      // Validate project ID format with descriptive error messages
      final validationError = _validateProjectId(id);
      if (validationError != null) {
        throw ArgumentError(validationError);
      }

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
      // Use the enhanced error handling
      final errorResponse = ErrorResponse.fromDioException(e);

      if (kDebugMode) {
        debugPrint('❌ DioException in getProjectById for ID $id:');
        debugPrint('  📄 User message: ${errorResponse.message}');
        debugPrint('  � Is retryable: ${errorResponse.isRetryable}');
        debugPrint('  📊 Status code: ${errorResponse.statusCode}');
        debugPrint('  🔍 Error code: ${errorResponse.errorCode}');
        if (errorResponse.debugInfo != null) {
          debugPrint('  � Debug info:\n${errorResponse.debugInfo}');
        }
        debugPrint('  🔍 Stack trace: $stackTrace');
      }

      // Throw a more user-friendly error with the enhanced message
      throw Exception(errorResponse.message);
    } on ArgumentError catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Invalid project ID format: $e');
      }
      throw Exception(e.message);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ General exception in getProjectById for ID $id: $e');
        debugPrint('🔍 Stack trace: $stackTrace');
      }
      throw Exception('Failed to load project details. Please try again.');
    }
  }

  @override
  Future<EnhancedProject> createProject(Map<String, dynamic> projectData) async {
    // For now, return a mock implementation
    // This will need to be implemented when the API has a create endpoint
    throw UnimplementedError('Create project API endpoint not yet implemented');
  }

  @override
  Future<EnhancedProject> updateProject(String id, Map<String, dynamic> projectData) async {
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
  Future<ProjectsResponse> getProjectsByManager(String managerId, ProjectsQuery query) async {
    final updatedQuery = query.copyWith(managerId: managerId);
    return getAllProjects(updatedQuery);
  }

  @override
  Future<ProjectsResponse> getProjectsByStatus(String status, ProjectsQuery query) async {
    final updatedQuery = query.copyWith(status: status);
    return getAllProjects(updatedQuery);
  }

  @override
  Future<ProjectsResponse> searchProjects(String searchQuery, ProjectsQuery query) async {
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
        debugPrint('📊 Response data items count: ${response.data.items.length}');
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
            createdAt: item.startDate, // Use startDate as fallback for createdAt
            updatedAt: DateTime.now(), // Use current time as fallback for updatedAt
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
  EnhancedProject _convertSingleProjectToEnhanced(Map<String, dynamic> projectData) {
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
          ? DateTime.tryParse(projectData['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      estimatedEndDate: projectData['estimatedEndDate'] != null
          ? DateTime.tryParse(projectData['estimatedEndDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      actualEndDate: projectData['actualEndDate'] != null
          ? DateTime.tryParse(projectData['actualEndDate'].toString())
          : null,
      createdAt: projectData['createdAt'] != null
          ? DateTime.tryParse(projectData['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: projectData['updatedAt'] != null
          ? DateTime.tryParse(projectData['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      projectManager: projectData['projectManager'] != null
          ? ProjectManager.fromJson(projectData['projectManager'] as Map<String, dynamic>)
          : null,
      taskCount: (projectData['taskCount'] as num?)?.toInt() ?? 0,
      completedTaskCount: (projectData['completedTaskCount'] as num?)?.toInt() ?? 0,
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
