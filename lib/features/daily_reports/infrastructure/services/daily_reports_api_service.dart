import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/api_response.dart';
import 'package:equatable/equatable.dart';

/// Data transfer object for daily report information
class DailyReportDto extends Equatable {
  const DailyReportDto({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.reportDate,
    required this.workDescription,
    required this.hoursWorked,
    required this.createdAt,
    required this.updatedAt,
    this.issues,
    this.achievements,
    this.materials,
    this.equipment,
    this.safety,
    this.weather,
    this.notes,
    this.images,
  });

  final String id;
  final String projectId;
  final String userId;
  final DateTime reportDate;
  final String workDescription;
  final double hoursWorked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? issues;
  final String? achievements;
  final String? materials;
  final String? equipment;
  final String? safety;
  final String? weather;
  final String? notes;
  final List<String>? images;

  factory DailyReportDto.fromJson(Map<String, dynamic> json) {
    return DailyReportDto(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      userId: json['user_id'] as String,
      reportDate: DateTime.parse(json['report_date'] as String),
      workDescription: json['work_description'] as String,
      hoursWorked: (json['hours_worked'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      issues: json['issues'] as String?,
      achievements: json['achievements'] as String?,
      materials: json['materials'] as String?,
      equipment: json['equipment'] as String?,
      safety: json['safety'] as String?,
      weather: json['weather'] as String?,
      notes: json['notes'] as String?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'user_id': userId,
      'report_date': reportDate.toIso8601String(),
      'work_description': workDescription,
      'hours_worked': hoursWorked,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (issues != null) 'issues': issues,
      if (achievements != null) 'achievements': achievements,
      if (materials != null) 'materials': materials,
      if (equipment != null) 'equipment': equipment,
      if (safety != null) 'safety': safety,
      if (weather != null) 'weather': weather,
      if (notes != null) 'notes': notes,
      if (images != null) 'images': images,
    };
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    userId,
    reportDate,
    workDescription,
    hoursWorked,
    createdAt,
    updatedAt,
    issues,
    achievements,
    materials,
    equipment,
    safety,
    weather,
    notes,
    images,
  ];
}

/// Request model for creating a new daily report
class CreateDailyReportRequest extends Equatable {
  const CreateDailyReportRequest({
    required this.projectId,
    required this.reportDate,
    required this.workDescription,
    required this.hoursWorked,
    this.issues,
    this.achievements,
    this.materials,
    this.equipment,
    this.safety,
    this.weather,
    this.notes,
    this.images,
  });

  final String projectId;
  final DateTime reportDate;
  final String workDescription;
  final double hoursWorked;
  final String? issues;
  final String? achievements;
  final String? materials;
  final String? equipment;
  final String? safety;
  final String? weather;
  final String? notes;
  final List<String>? images;

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'report_date': reportDate.toIso8601String(),
      'work_description': workDescription,
      'hours_worked': hoursWorked,
      if (issues != null) 'issues': issues,
      if (achievements != null) 'achievements': achievements,
      if (materials != null) 'materials': materials,
      if (equipment != null) 'equipment': equipment,
      if (safety != null) 'safety': safety,
      if (weather != null) 'weather': weather,
      if (notes != null) 'notes': notes,
      if (images != null) 'images': images,
    };
  }

  @override
  List<Object?> get props => [
    projectId,
    reportDate,
    workDescription,
    hoursWorked,
    issues,
    achievements,
    materials,
    equipment,
    safety,
    weather,
    notes,
    images,
  ];
}

/// Request model for updating a daily report
class UpdateDailyReportRequest extends Equatable {
  const UpdateDailyReportRequest({
    this.workDescription,
    this.hoursWorked,
    this.issues,
    this.achievements,
    this.materials,
    this.equipment,
    this.safety,
    this.weather,
    this.notes,
    this.images,
  });

  final String? workDescription;
  final double? hoursWorked;
  final String? issues;
  final String? achievements;
  final String? materials;
  final String? equipment;
  final String? safety;
  final String? weather;
  final String? notes;
  final List<String>? images;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (workDescription != null) json['work_description'] = workDescription;
    if (hoursWorked != null) json['hours_worked'] = hoursWorked;
    if (issues != null) json['issues'] = issues;
    if (achievements != null) json['achievements'] = achievements;
    if (materials != null) json['materials'] = materials;
    if (equipment != null) json['equipment'] = equipment;
    if (safety != null) json['safety'] = safety;
    if (weather != null) json['weather'] = weather;
    if (notes != null) json['notes'] = notes;
    if (images != null) json['images'] = images;
    return json;
  }

  @override
  List<Object?> get props => [
    workDescription,
    hoursWorked,
    issues,
    achievements,
    materials,
    equipment,
    safety,
    weather,
    notes,
    images,
  ];
}

/// API service class for daily report operations
@Injectable()
class DailyReportsApiService {
  const DailyReportsApiService(this._apiClient);

  final ApiClient _apiClient;

  /// Get all daily reports with optional filtering
  Future<ApiResponse<List<DailyReportDto>>> getDailyReports({
    String? projectId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (projectId != null) queryParams['project_id'] = projectId;
      if (userId != null) queryParams['user_id'] = userId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(ApiConfig.dailyReports, queryParameters: queryParams);

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => (json as List<dynamic>).map((item) => DailyReportDto.fromJson(item as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return _handleError<List<DailyReportDto>>(e);
    }
  }

  /// Get a specific daily report by ID
  Future<ApiResponse<DailyReportDto>> getDailyReport(String reportId) async {
    try {
      final response = await _apiClient.get('${ApiConfig.dailyReports}/$reportId');

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => DailyReportDto.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError<DailyReportDto>(e);
    }
  }

  /// Create a new daily report
  Future<ApiResponse<DailyReportDto>> createDailyReport(CreateDailyReportRequest request) async {
    try {
      final response = await _apiClient.post(ApiConfig.dailyReports, data: request.toJson());

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => DailyReportDto.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError<DailyReportDto>(e);
    }
  }

  /// Update an existing daily report
  Future<ApiResponse<DailyReportDto>> updateDailyReport(String reportId, UpdateDailyReportRequest request) async {
    try {
      final response = await _apiClient.put('${ApiConfig.dailyReports}/$reportId', data: request.toJson());

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => DailyReportDto.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError<DailyReportDto>(e);
    }
  }

  /// Delete a daily report
  Future<ApiResponse<void>> deleteDailyReport(String reportId) async {
    try {
      await _apiClient.delete('${ApiConfig.dailyReports}/$reportId');
      return const ApiResponse(success: true, data: null);
    } catch (e) {
      return _handleError<void>(e);
    }
  }

  /// Get daily reports by project
  Future<ApiResponse<List<DailyReportDto>>> getDailyReportsByProject(
    String projectId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiClient.get(
        '${ApiConfig.projects}/$projectId/daily-reports',
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => (json as List<dynamic>).map((item) => DailyReportDto.fromJson(item as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return _handleError<List<DailyReportDto>>(e);
    }
  }

  /// Get daily reports by user
  Future<ApiResponse<List<DailyReportDto>>> getDailyReportsByUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiClient.get(
        '${ApiConfig.userPermissions}/$userId/daily-reports',
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => (json as List<dynamic>).map((item) => DailyReportDto.fromJson(item as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return _handleError<List<DailyReportDto>>(e);
    }
  }

  /// Get daily reports for a specific date
  Future<ApiResponse<List<DailyReportDto>>> getDailyReportsByDate(DateTime date) async {
    try {
      final response = await _apiClient.get('${ApiConfig.dailyReports}/date/${date.toIso8601String().split('T')[0]}');

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => (json as List<dynamic>).map((item) => DailyReportDto.fromJson(item as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return _handleError<List<DailyReportDto>>(e);
    }
  }

  /// Generic error handler
  ApiResponse<T> _handleError<T>(dynamic error) {
    String message = 'An unexpected error occurred';

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Connection timeout. Please check your internet connection.';
          break;
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;

          if (statusCode == 401) {
            message = 'Authentication required. Please log in again.';
          } else if (statusCode == 403) {
            message = 'Access denied. You don\'t have permission to perform this action.';
          } else if (statusCode == 404) {
            message = 'Daily report not found.';
          } else if (statusCode == 422) {
            message = 'Invalid report data provided.';
          } else if (responseData is Map && responseData.containsKey('message')) {
            message = responseData['message'].toString();
          } else {
            message = 'Server error (${statusCode ?? 'unknown'})';
          }
          break;
        case DioExceptionType.cancel:
          message = 'Request was cancelled';
          break;
        case DioExceptionType.connectionError:
          message = 'Network error. Please check your internet connection.';
          break;
        case DioExceptionType.unknown:
          message = error.message ?? 'Unknown network error occurred';
          break;
        case DioExceptionType.badCertificate:
          message = 'Security certificate error';
          break;
      }
    }

    return ApiResponse<T>(success: false, message: message, data: null);
  }
}
