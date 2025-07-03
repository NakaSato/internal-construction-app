import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/api_response.dart';
import '../models/project_models.dart';

/// Enhanced Project API service with all endpoints from Swagger
class ProjectApiService {
  final ApiClient _apiClient;

  ProjectApiService(this._apiClient);

  /// Get all projects with advanced filtering
  Future<ApiResponse<EnhancedPagedResult<ProjectDto>>> getProjects({
    String? projectName,
    String? status,
    String? clientInfo,
    DateTime? startDateAfter,
    DateTime? startDateBefore,
    DateTime? estimatedEndDateAfter,
    DateTime? estimatedEndDateBefore,
    String? managerId,
    String? address,
    List<FilterParameter>? filters,
    int? pageNumber,
    int? pageSize,
    String? sortBy,
    String? sortOrder,
    String? search,
    String? fields,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (projectName != null) queryParams['ProjectName'] = projectName;
      if (status != null) queryParams['Status'] = status;
      if (clientInfo != null) queryParams['ClientInfo'] = clientInfo;
      if (startDateAfter != null)
        queryParams['StartDateAfter'] = startDateAfter.toIso8601String();
      if (startDateBefore != null)
        queryParams['StartDateBefore'] = startDateBefore.toIso8601String();
      if (estimatedEndDateAfter != null)
        queryParams['EstimatedEndDateAfter'] = estimatedEndDateAfter
            .toIso8601String();
      if (estimatedEndDateBefore != null)
        queryParams['EstimatedEndDateBefore'] = estimatedEndDateBefore
            .toIso8601String();
      if (managerId != null) queryParams['ManagerId'] = managerId;
      if (address != null) queryParams['Address'] = address;
      if (filters != null)
        queryParams['Filters'] = filters.map((f) => f.toJson()).toList();
      if (pageNumber != null) queryParams['PageNumber'] = pageNumber;
      if (pageSize != null) queryParams['PageSize'] = pageSize;
      if (sortBy != null) queryParams['SortBy'] = sortBy;
      if (sortOrder != null) queryParams['SortOrder'] = sortOrder;
      if (search != null) queryParams['Search'] = search;
      if (fields != null) queryParams['Fields'] = fields;

      final response = await _apiClient.dio.get(
        ApiConfig.projectsPath,
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => EnhancedPagedResult.fromJson(
          json as Map<String, dynamic>,
          (item) => ProjectDto.fromJson(item as Map<String, dynamic>),
        ),
      );
    } on DioException catch (e) {
      return _handleError<EnhancedPagedResult<ProjectDto>>(e);
    }
  }

  /// Create a new project
  Future<ApiResponse<ProjectDto>> createProject(
    CreateProjectRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.projectsPath,
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => ProjectDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleError<ProjectDto>(e);
    }
  }

  /// Get specific project by ID
  Future<ApiResponse<ProjectDto>> getProject(String projectId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConfig.projectsPath}/$projectId',
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => ProjectDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleError<ProjectDto>(e);
    }
  }

  /// Update project
  Future<ApiResponse<ProjectDto>> updateProject(
    String projectId,
    UpdateProjectRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConfig.projectsPath}/$projectId',
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => ProjectDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleError<ProjectDto>(e);
    }
  }

  /// Partially update project
  Future<ApiResponse<ProjectDto>> patchProject(
    String projectId,
    PatchProjectRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.patch(
        '${ApiConfig.projectsPath}/$projectId',
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => ProjectDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleError<ProjectDto>(e);
    }
  }

  /// Delete project
  Future<ApiResponse<bool>> deleteProject(String projectId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConfig.projectsPath}/$projectId',
      );

      return ApiResponse.fromJson(response.data, (json) => json as bool);
    } on DioException catch (e) {
      return _handleError<bool>(e);
    }
  }

  /// Get projects for current user
  Future<ApiResponse<EnhancedPagedResult<ProjectDto>>> getMyProjects({
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (pageNumber != null) queryParams['pageNumber'] = pageNumber;
      if (pageSize != null) queryParams['pageSize'] = pageSize;

      final response = await _apiClient.dio.get(
        '${ApiConfig.projectsPath}/me',
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => EnhancedPagedResult.fromJson(
          json as Map<String, dynamic>,
          (item) => ProjectDto.fromJson(item as Map<String, dynamic>),
        ),
      );
    } on DioException catch (e) {
      return _handleError<EnhancedPagedResult<ProjectDto>>(e);
    }
  }

  /// Get projects with rich data
  Future<ApiResponse<List<ProjectDto>>> getRichProjects({
    int? page,
    int? pageSize,
    String? managerId,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['pageSize'] = pageSize;
      if (managerId != null) queryParams['managerId'] = managerId;
      if (status != null) queryParams['status'] = status;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final response = await _apiClient.dio.get(
        '${ApiConfig.projectsPath}/rich',
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => (json as List<dynamic>)
            .map((item) => ProjectDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return _handleError<List<ProjectDto>>(e);
    }
  }

  /// Get project status
  Future<ApiResponse<ProjectStatusDto>> getProjectStatus(
    String projectId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConfig.projectsPath}/$projectId/status',
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => ProjectStatusDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleError<ProjectStatusDto>(e);
    }
  }

  /// Test endpoint
  Future<ApiResponse<void>> testProject() async {
    try {
      await _apiClient.dio.get('${ApiConfig.projectsPath}/test');
      return const ApiResponse(success: true, message: 'Test successful');
    } on DioException catch (e) {
      return _handleError<void>(e);
    }
  }

  /// Handle API errors with proper error mapping
  ApiResponse<T> _handleError<T>(DioException error) {
    String message = 'An error occurred';
    List<String> errors = [];

    switch (error.response?.statusCode) {
      case 400:
        message = 'Bad request';
        break;
      case 401:
        message = 'Unauthorized';
        break;
      case 403:
        message = 'Forbidden';
        break;
      case 404:
        message = 'Project not found';
        break;
      case 422:
        message = 'Validation failed';
        if (error.response?.data != null) {
          final data = error.response!.data;
          if (data['errors'] != null) {
            errors = (data['errors'] as List).cast<String>();
          }
        }
        break;
      case 500:
        message = 'Server error';
        break;
      default:
        message = error.message ?? 'Network error';
    }

    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors.isNotEmpty ? errors : null,
      error: error.response?.data,
    );
  }
}
