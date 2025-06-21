import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../domain/entities/project_api_models.dart';

/// Remote data source for Project Management API
abstract class ProjectRemoteDataSource {
  /// Get all projects with filtering and pagination
  Future<ProjectsResponse> getAllProjects(ProjectsQuery query);

  /// Get project by ID
  Future<EnhancedProject> getProjectById(String id);

  /// Create a new project
  Future<EnhancedProject> createProject(Map<String, dynamic> projectData);

  /// Update an existing project
  Future<EnhancedProject> updateProject(String id, Map<String, dynamic> projectData);

  /// Delete a project
  Future<void> deleteProject(String id);

  /// Get project statistics
  Future<Map<String, dynamic>> getProjectStatistics();
}

/// Implementation of ProjectRemoteDataSource
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  const ProjectRemoteDataSourceImpl({
    required this.dio,
  });

  final Dio dio;

  static const String _baseUrl = '/api/v1/projects';

  @override
  Future<ProjectsResponse> getAllProjects(ProjectsQuery query) async {
    try {
      final response = await dio.get(
        _baseUrl,
        queryParameters: query.toQueryParameters(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ProjectsResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to get projects: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error while fetching projects: $e');
    }
  }

  @override
  Future<EnhancedProject> getProjectById(String id) async {
    try {
      final response = await dio.get(
        '$_baseUrl/$id',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return EnhancedProject.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to get project: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error while fetching project: $e');
    }
  }

  @override
  Future<EnhancedProject> createProject(Map<String, dynamic> projectData) async {
    try {
      final response = await dio.post(
        _baseUrl,
        data: jsonEncode(projectData),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return EnhancedProject.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to create project: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error while creating project: $e');
    }
  }

  @override
  Future<EnhancedProject> updateProject(
    String id,
    Map<String, dynamic> projectData,
  ) async {
    try {
      final response = await dio.put(
        '$_baseUrl/$id',
        data: jsonEncode(projectData),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return EnhancedProject.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to update project: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error while updating project: $e');
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      final response = await dio.delete(
        '$_baseUrl/$id',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to delete project: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error while deleting project: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getProjectStatistics() async {
    try {
      final response = await dio.get(
        '$_baseUrl/statistics',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to get project statistics: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error while fetching project statistics: $e');
    }
  }

  /// Handle Dio exceptions and convert to appropriate error messages
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout - please check your internet connection');
      case DioExceptionType.sendTimeout:
        return Exception('Request timeout - please try again');
      case DioExceptionType.receiveTimeout:
        return Exception('Server response timeout - please try again');
      case DioExceptionType.badResponse:
        return _handleBadResponse(e);
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      case DioExceptionType.connectionError:
        return Exception('Connection error - please check your internet connection');
      default:
        return Exception('Network error: ${e.message}');
    }
  }

  /// Handle bad response errors with specific status codes
  Exception _handleBadResponse(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    switch (statusCode) {
      case 400:
        final message = _extractErrorMessage(data) ?? 'Bad request - invalid data provided';
        return Exception(message);
      case 401:
        return Exception('Unauthorized - please sign in again');
      case 403:
        return Exception('Forbidden - insufficient permissions');
      case 404:
        return Exception('Project not found');
      case 409:
        final message = _extractErrorMessage(data) ?? 'Conflict - project already exists';
        return Exception(message);
      case 422:
        final message = _extractErrorMessage(data) ?? 'Validation error - please check your input';
        return Exception(message);
      case 500:
        return Exception('Server error - please try again later');
      case 502:
        return Exception('Bad gateway - service temporarily unavailable');
      case 503:
        return Exception('Service unavailable - please try again later');
      default:
        final message = _extractErrorMessage(data) ?? 'Unknown error occurred';
        return Exception('HTTP $statusCode: $message');
    }
  }

  /// Extract error message from response data
  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Try common error message fields
      return data['message'] as String? ??
          data['error'] as String? ??
          data['details'] as String? ??
          (data['errors'] as List?)?.first as String?;
    }
    return null;
  }
}

/// Local data source for caching project data
abstract class ProjectLocalDataSource {
  /// Cache projects response
  Future<void> cacheProjects(ProjectsResponse response);

  /// Get cached projects
  Future<ProjectsResponse?> getCachedProjects();

  /// Cache single project
  Future<void> cacheProject(EnhancedProject project);

  /// Get cached project by ID
  Future<EnhancedProject?> getCachedProject(String id);

  /// Clear all cached data
  Future<void> clearCache();

  /// Check if cache is valid (not expired)
  Future<bool> isCacheValid();
}

/// Implementation of ProjectLocalDataSource using shared preferences or local storage
class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  const ProjectLocalDataSourceImpl();

  // For now, we'll use in-memory storage
  // In a real implementation, you would use SharedPreferences, Hive, or SQLite
  static final Map<String, dynamic> _cache = {};
  static DateTime? _lastCacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  @override
  Future<void> cacheProjects(ProjectsResponse response) async {
    _cache['projects'] = response.toJson();
    _lastCacheTime = DateTime.now();
  }

  @override
  Future<ProjectsResponse?> getCachedProjects() async {
    if (!await isCacheValid()) return null;
    
    final data = _cache['projects'] as Map<String, dynamic>?;
    if (data == null) return null;
    
    return ProjectsResponse.fromJson(data);
  }

  @override
  Future<void> cacheProject(EnhancedProject project) async {
    _cache['project_${project.projectId}'] = project.toJson();
    _lastCacheTime = DateTime.now();
  }

  @override
  Future<EnhancedProject?> getCachedProject(String id) async {
    if (!await isCacheValid()) return null;
    
    final data = _cache['project_$id'] as Map<String, dynamic>?;
    if (data == null) return null;
    
    return EnhancedProject.fromJson(data);
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
    _lastCacheTime = null;
  }

  @override
  Future<bool> isCacheValid() async {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheValidDuration;
  }
}

/// Extension to add toJson method to ProjectsResponse
extension ProjectsResponseJson on ProjectsResponse {
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalCount': totalCount,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalPages': totalPages,
      'hasPreviousPage': hasPreviousPage,
      'hasNextPage': hasNextPage,
      'metadata': metadata,
    };
  }
}
