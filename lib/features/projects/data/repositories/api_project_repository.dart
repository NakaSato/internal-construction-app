import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../common/utils/error_extensions.dart';
import '../../domain/entities/project_api_models.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_api_service.dart';
import '../models/project_response.dart';

/// API implementation of the project repository
@Injectable()
class ApiProjectRepository implements ProjectRepository {
  ApiProjectRepository(this._apiService);

  final ProjectApiService _apiService;

  // Cache control flag - when true, next requests will bypass cache
  bool _bypassCache = false;

  @override
  Future<ProjectsResponse> getAllProjects(ProjectsQuery query) async {
    if (kDebugMode) {
      debugPrint('🚀 ApiProjectRepository.getAllProjects called');
      debugPrint('📝 Query parameters: ${query.toQueryParameters()}');
      if (_bypassCache) {
        debugPrint('🗑️ Cache bypass requested - will add cache-busting parameter');
      }
    }

    try {
      // Add cache-busting parameter if cache bypass is requested
      final queryParams = query.toQueryParameters();
      if (_bypassCache) {
        queryParams['_cacheBuster'] = DateTime.now().millisecondsSinceEpoch.toString();
        _resetCacheBypass(); // Reset flag after use
      }

      // Convert ProjectsQuery to API response format
      final response = await _apiService.getProjects(queryParams);

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
  Future<Project> getProjectById(String id) async {
    try {
      // Validate project ID format with descriptive error messages
      final validationError = _validateProjectId(id);
      if (validationError != null) {
        throw ArgumentError(validationError);
      }

      if (kDebugMode) {
        debugPrint('🔍 [API_REPO] Loading project details for ID: $id');
        debugPrint('🔍 [API_REPO] API Service base URL: ${_apiService.toString()}');
      }

      final response = await _apiService.getProject(id);

      if (kDebugMode) {
        debugPrint('✅ Received project detail response: success=${response.success}, message=${response.message}');
      }

      // Check if the response was successful
      if (!response.success || response.data == null) {
        final errorMessage = response.errors.isNotEmpty
            ? response.errors.join(', ')
            : response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve project details';

        if (kDebugMode) {
          debugPrint('❌ API returned unsuccessful response: $errorMessage');
        }

        // Check if it's a null reference error that we can handle with fallback
        if (response.errors.any((error) => error.contains('Object reference not set to an instance of an object'))) {
          if (kDebugMode) {
            debugPrint('🔄 Server null reference error detected, trying fallback approach...');
          }

          try {
            return await _getProjectByIdFallback(id);
          } catch (fallbackError) {
            if (kDebugMode) {
              debugPrint('❌ Fallback also failed: $fallbackError');
            }
            throw Exception('Project data is temporarily unavailable. Please try again or contact support.');
          }
        }

        throw Exception('Failed to load project details: $errorMessage');
      }

      // Convert the single project response data directly to Project
      return _convertSingleProjectToEnhanced(response.data!);
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

      // Extract more specific error messages from the API response
      String userFriendlyMessage = errorResponse.message;

      // Check for specific API error patterns
      if (e.response?.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;

        // Look for errors array with specific messages
        if (responseData.containsKey('errors') && responseData['errors'] is List) {
          final errors = responseData['errors'] as List;
          if (errors.isNotEmpty) {
            final firstError = errors.first.toString();

            // If it's a server error (null reference), try fallback approach
            if (firstError.contains('Object reference not set to an instance of an object')) {
              if (kDebugMode) {
                debugPrint('🔄 Server error detected, trying fallback approach...');
              }

              try {
                return await _getProjectByIdFallback(id);
              } catch (fallbackError) {
                if (kDebugMode) {
                  debugPrint('❌ Fallback also failed: $fallbackError');
                }
                userFriendlyMessage = 'Project data is temporarily unavailable. Please try again or contact support.';
              }
            } else if (firstError.contains('not found')) {
              userFriendlyMessage = 'Project not found. It may have been deleted or moved.';
            } else if (firstError.contains('access') || firstError.contains('permission')) {
              userFriendlyMessage = 'You don\'t have permission to view this project.';
            } else {
              // Use the actual error message if it's user-friendly
              userFriendlyMessage = firstError;
            }
          }
        }

        // Also check the main message field
        if (responseData.containsKey('message') && responseData['message'] is String) {
          final apiMessage = responseData['message'] as String;
          if (apiMessage != 'Operation failed' && apiMessage.isNotEmpty) {
            userFriendlyMessage = apiMessage;
          }
        }
      }

      // Throw a more user-friendly error with the enhanced message
      throw Exception(userFriendlyMessage);
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
  Future<Project> createProject(Map<String, dynamic> projectData) async {
    // For now, return a mock implementation
    // This will need to be implemented when the API has a create endpoint
    throw UnimplementedError('Create project API endpoint not yet implemented');
  }

  @override
  Future<Project> updateProject(String id, Map<String, dynamic> projectData) async {
    // For now, return a mock implementation
    // This will need to be implemented when the API has an update endpoint
    throw UnimplementedError('Update project API endpoint not yet implemented');
  }

  @override
  Future<void> deleteProject(String id) async {
    if (kDebugMode) {
      debugPrint('🗑️ ApiProjectRepository.deleteProject called with ID: $id');
    }

    try {
      await _apiService.deleteProject(id);

      if (kDebugMode) {
        debugPrint('✅ Project deleted successfully: $id');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DioException in deleteProject:');
        debugPrint('  Status Code: ${e.response?.statusCode}');
        debugPrint('  Request URL: ${e.requestOptions.uri}');
        debugPrint('  Error Message: ${e.message}');
        debugPrint('  Response Data: ${e.response?.data}');
      }
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ General exception in deleteProject: $e');
        debugPrint('🔍 Stack trace: $stackTrace');
      }
      rethrow;
    }
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
      final projects = <Project>[];
      for (int i = 0; i < response.data.items.length; i++) {
        try {
          final item = response.data.items[i];
          if (kDebugMode) {
            debugPrint('🔄 Converting item $i: ${item.runtimeType}');
          }

          // Convert ProjectDto to Project directly without toJson() conversion
          final project = Project(
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
            debugPrint('✅ Successfully converted item $i to Project');
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
  Project _convertSingleProjectToEnhanced(Map<String, dynamic> projectData) {
    if (kDebugMode) {
      debugPrint('🔄 Converting single project data: ${projectData.keys}');
    }

    return Project(
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

  /// Fallback method to get project by ID from the list endpoint
  /// This is used when the individual project endpoint has server issues
  Future<Project> _getProjectByIdFallback(String id) async {
    if (kDebugMode) {
      debugPrint('🔄 Using fallback approach: searching for project $id in list');
    }

    // Get all projects and find the one with matching ID
    final query = ProjectsQuery();
    final projectsResponse = await getAllProjects(query);

    // Search through first page
    for (final project in projectsResponse.items) {
      if (project.projectId == id) {
        if (kDebugMode) {
          debugPrint('✅ Found project $id in list fallback');
        }
        return project;
      }
    }

    // If not found in first page, try searching with larger page size or all pages
    if (projectsResponse.totalPages > 1) {
      if (kDebugMode) {
        debugPrint('🔍 Project not found in first page, searching all pages...');
      }

      // Search through all pages
      for (int page = 2; page <= projectsResponse.totalPages; page++) {
        final pageQuery = ProjectsQuery(pageNumber: page, pageSize: projectsResponse.pageSize);
        final pageResponse = await getAllProjects(pageQuery);

        for (final project in pageResponse.items) {
          if (project.projectId == id) {
            if (kDebugMode) {
              debugPrint('✅ Found project $id in page $page fallback');
            }
            return project;
          }
        }
      }
    }

    // If still not found, throw an error
    throw Exception('Project with ID $id not found in fallback search');
  }

  @override
  Future<void> clearProjectCache() async {
    if (kDebugMode) {
      debugPrint('🗑️ ApiProjectRepository: Clearing project cache');
    }

    // Set flag to bypass cache on next request
    _bypassCache = true;
  }

  @override
  Stream<ProjectsResponse> getLiveProjectUpdates(
    ProjectsQuery query, {
    Duration updateInterval = const Duration(seconds: 10),
    bool includeDeltas = false,
  }) async* {
    if (kDebugMode) {
      debugPrint('🔴 Starting live project updates with ${updateInterval.inSeconds}s interval');
    }

    ProjectsResponse? lastResponse;
    DateTime? lastUpdate;

    while (true) {
      try {
        // Add live update specific query parameters
        final liveQuery = query.copyWith();
        final queryParams = liveQuery.toQueryParameters();

        // Add parameters for live updates
        queryParams['_live'] = 'true';
        queryParams['_timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();

        if (includeDeltas && lastUpdate != null) {
          queryParams['_since'] = lastUpdate.millisecondsSinceEpoch.toString();
        }

        if (kDebugMode) {
          debugPrint('🔄 Fetching live project update...');
        }

        // Fetch fresh data
        final response = await _apiService.getProjects(queryParams);
        final projectsResponse = _convertToProjectsResponse(response);

        // Update last fetch time
        lastUpdate = DateTime.now();

        // Only yield if there are changes (optimization)
        if (lastResponse == null || !_areResponsesEqual(lastResponse, projectsResponse)) {
          if (kDebugMode) {
            debugPrint('✅ Live update: Changes detected, yielding new data');
            debugPrint('📊 Projects count: ${projectsResponse.items.length}');
          }

          lastResponse = projectsResponse;
          yield projectsResponse;
        } else if (kDebugMode) {
          debugPrint('⚪ Live update: No changes detected');
        }

        // Wait for next update
        await Future.delayed(updateInterval);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Live update error: $e');
        }

        // On error, wait a bit longer before retry
        await Future.delayed(Duration(seconds: updateInterval.inSeconds * 2));
      }
    }
  }

  /// Helper method to compare responses for changes
  bool _areResponsesEqual(ProjectsResponse a, ProjectsResponse b) {
    if (a.totalCount != b.totalCount || a.items.length != b.items.length) {
      return false;
    }

    // Quick comparison by project IDs, status, and task completion
    for (int i = 0; i < a.items.length; i++) {
      final itemA = a.items[i];
      final itemB = b.items[i];

      if (itemA.projectId != itemB.projectId ||
          itemA.status != itemB.status ||
          itemA.taskCount != itemB.taskCount ||
          itemA.completedTaskCount != itemB.completedTaskCount ||
          itemA.updatedAt != itemB.updatedAt) {
        return false;
      }
    }

    return true;
  }

  /// Reset cache bypass flag after use
  void _resetCacheBypass() {
    _bypassCache = false;
  }
}
