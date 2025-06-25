import 'package:dio/dio.dart';
import '../../domain/entities/project_api_models.dart';

/// Remote data source for Project Management API
abstract class ProjectRemoteDataSource {
  /// Get all projects with filtering and pagination
  Future<ProjectsResponse> getProjects({
    ProjectsQuery? query,
    String? userRole,
  });

  /// Get project by ID
  Future<EnhancedProject> getProjectById(String id, {String? userRole});

  /// Search projects by term
  Future<ProjectsResponse> searchProjects(
    String searchTerm, {
    ProjectsQuery? filters,
    String? userRole,
  });

  /// Create a new project
  Future<EnhancedProject> createProject(
    Map<String, dynamic> projectData, {
    String? userRole,
  });

  /// Update an existing project
  Future<EnhancedProject> updateProject(
    String id,
    Map<String, dynamic> projectData, {
    String? userRole,
  });

  /// Delete a project
  Future<void> deleteProject(String id, {String? userRole});

  /// Get project statistics
  Future<Map<String, dynamic>> getProjectStatistics({
    String? userRole,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get projects by manager
  Future<List<EnhancedProject>> getProjectsByManager(
    String managerId, {
    String? userRole,
  });

  /// Get projects by status
  Future<List<EnhancedProject>> getProjectsByStatus(
    String status, {
    String? userRole,
  });

  /// Get projects by date range
  Future<List<EnhancedProject>> getProjectsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userRole,
  });

  /// Assign project manager
  Future<EnhancedProject> assignProjectManager(
    String projectId,
    String managerId, {
    String? userRole,
  });

  /// Update project status
  Future<EnhancedProject> updateProjectStatus(
    String projectId,
    String status, {
    String? userRole,
  });

  /// Clear cache
  Future<void> clearCache();

  /// Refresh cache
  Future<void> refreshCache();
}

/// Implementation of ProjectRemoteDataSource
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  ProjectRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  static const String _baseUrl = '/api/v1/projects';

  // In-memory cache for projects (simple implementation)
  final Map<String, dynamic> _cache = {};

  @override
  Future<ProjectsResponse> getProjects({
    ProjectsQuery? query,
    String? userRole,
  }) async {
    try {
      final Map<String, dynamic> queryParams = query?.toQueryParameters() ?? {};
      if (userRole != null) {
        queryParams['user_role'] = userRole;
      }

      final response = await dio.get(
        _baseUrl,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final result = ProjectsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        _cache['projects_${queryParams.hashCode}'] = result;
        return result;
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
  Future<EnhancedProject> getProjectById(String id, {String? userRole}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (userRole != null) {
        queryParams['user_role'] = userRole;
      }

      final response = await dio.get(
        '$_baseUrl/$id',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final result = EnhancedProject.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        _cache['project_$id'] = result;
        return result;
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
  Future<ProjectsResponse> searchProjects(
    String searchTerm, {
    ProjectsQuery? filters,
    String? userRole,
  }) async {
    try {
      final Map<String, dynamic> queryParams =
          filters?.toQueryParameters() ?? {};
      queryParams['search'] = searchTerm;
      if (userRole != null) {
        queryParams['user_role'] = userRole;
      }

      final response = await dio.get(
        '$_baseUrl/search',
        queryParameters: queryParams,
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
          message: 'Failed to search projects: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error while searching projects: $e');
    }
  }

  @override
  Future<EnhancedProject> createProject(
    Map<String, dynamic> projectData, {
    String? userRole,
  }) async {
    try {
      final response = await dio.post(
        _baseUrl,
        data: projectData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (userRole != null) 'X-User-Role': userRole,
          },
        ),
      );

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final result = EnhancedProject.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        _clearProjectsCache();
        return result;
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
    Map<String, dynamic> projectData, {
    String? userRole,
  }) async {
    try {
      final response = await dio.put(
        '$_baseUrl/$id',
        data: projectData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (userRole != null) 'X-User-Role': userRole,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final result = EnhancedProject.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        _cache.remove('project_$id');
        _clearProjectsCache();
        return result;
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
  Future<void> deleteProject(String id, {String? userRole}) async {
    try {
      final response = await dio.delete(
        '$_baseUrl/$id',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (userRole != null) 'X-User-Role': userRole,
          },
        ),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        _cache.remove('project_$id');
        _clearProjectsCache();
      } else {
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
  Future<Map<String, dynamic>> getProjectStatistics({
    String? userRole,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (userRole != null) queryParams['user_role'] = userRole;
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await dio.get(
        '$_baseUrl/statistics',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
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
          message: 'Failed to get statistics: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error while fetching statistics: $e');
    }
  }

  @override
  Future<List<EnhancedProject>> getProjectsByManager(
    String managerId, {
    String? userRole,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'managerId': managerId};
      if (userRole != null) queryParams['user_role'] = userRole;

      final response = await dio.get(
        _baseUrl,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final projectsData = data['data']['items'] as List;
        return projectsData
            .map(
              (json) => EnhancedProject.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to get projects by manager: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception(
        'Unexpected error while fetching projects by manager: $e',
      );
    }
  }

  @override
  Future<List<EnhancedProject>> getProjectsByStatus(
    String status, {
    String? userRole,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'status': status};
      if (userRole != null) queryParams['user_role'] = userRole;

      final response = await dio.get(
        _baseUrl,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final projectsData = data['data']['items'] as List;
        return projectsData
            .map(
              (json) => EnhancedProject.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to get projects by status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error while fetching projects by status: $e');
    }
  }

  @override
  Future<List<EnhancedProject>> getProjectsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userRole,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
      if (userRole != null) queryParams['user_role'] = userRole;

      final response = await dio.get(
        _baseUrl,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final projectsData = data['data']['items'] as List;
        return projectsData
            .map(
              (json) => EnhancedProject.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message:
              'Failed to get projects by date range: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception(
        'Unexpected error while fetching projects by date range: $e',
      );
    }
  }

  @override
  Future<EnhancedProject> assignProjectManager(
    String projectId,
    String managerId, {
    String? userRole,
  }) async {
    try {
      final response = await dio.patch(
        '$_baseUrl/$projectId/manager',
        data: {'managerId': managerId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (userRole != null) 'X-User-Role': userRole,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final result = EnhancedProject.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        _cache.remove('project_$projectId');
        _clearProjectsCache();
        return result;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to assign project manager: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error while assigning project manager: $e');
    }
  }

  @override
  Future<EnhancedProject> updateProjectStatus(
    String projectId,
    String status, {
    String? userRole,
  }) async {
    try {
      final response = await dio.patch(
        '$_baseUrl/$projectId/status',
        data: {'status': status},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (userRole != null) 'X-User-Role': userRole,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final result = EnhancedProject.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        _cache.remove('project_$projectId');
        _clearProjectsCache();
        return result;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to update project status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error while updating project status: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
  }

  @override
  Future<void> refreshCache() async {
    _cache.clear();
    // Optionally, you could pre-load some common queries here
  }

  // Private helper methods
  void _clearProjectsCache() {
    _cache.removeWhere((key, value) => key.startsWith('projects_'));
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Server error';

        switch (statusCode) {
          case 400:
            return Exception('Bad request: $message');
          case 401:
            return Exception('Unauthorized: Please log in again');
          case 403:
            return Exception(
              'Forbidden: You don\'t have permission to access this resource',
            );
          case 404:
            return Exception('Resource not found');
          case 422:
            return Exception('Validation error: $message');
          case 500:
            return Exception('Internal server error. Please try again later');
          default:
            return Exception('Server error ($statusCode): $message');
        }

      case DioExceptionType.cancel:
        return Exception('Request was cancelled');

      case DioExceptionType.unknown:
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        return Exception('Network error. Please check your connection');
    }
  }
}
