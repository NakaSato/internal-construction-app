import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/api_config.dart';

@injectable
class WBSApiService {
  final Dio _dio;

  WBSApiService(this._dio);

  /// Get the complete Work Breakdown Structure for a project
  Future<Map<String, dynamic>> getProjectWBS(
    String projectId, {
    int? level,
    String? status,
    String? assignedTo,
    bool includeChildren = true,
    bool includeEvidence = false,
  }) async {
    final queryParams = <String, dynamic>{'include_children': includeChildren, 'include_evidence': includeEvidence};

    if (level != null) queryParams['level'] = level;
    if (status != null) queryParams['status'] = status;
    if (assignedTo != null) queryParams['assigned_to'] = assignedTo;

    final response = await _dio.get('${ApiConfig.wbsEndpoint}/projects/$projectId/wbs', queryParameters: queryParams);

    return response.data;
  }

  /// Get detailed information about a specific WBS task
  Future<Map<String, dynamic>> getWBSTaskDetails(String taskId) async {
    final response = await _dio.get('${ApiConfig.wbsEndpoint}/tasks/$taskId');

    return response.data;
  }

  /// Create a new task in the Work Breakdown Structure
  Future<Map<String, dynamic>> createWBSTask(String projectId, Map<String, dynamic> taskData) async {
    final response = await _dio.post('${ApiConfig.wbsEndpoint}/projects/$projectId/wbs/tasks', data: taskData);

    return response.data;
  }

  /// Update an existing WBS task
  Future<Map<String, dynamic>> updateWBSTask(String taskId, Map<String, dynamic> updateData) async {
    final response = await _dio.put('${ApiConfig.wbsEndpoint}/tasks/$taskId', data: updateData);

    return response.data;
  }

  /// Update only the status of a WBS task
  Future<Map<String, dynamic>> updateTaskStatus(
    String taskId, {
    required String status,
    String? completionNotes,
    String? completedBy,
  }) async {
    final data = <String, dynamic>{'status': status};

    if (completionNotes != null) data['completion_notes'] = completionNotes;
    if (completedBy != null) data['completed_by'] = completedBy;

    final response = await _dio.patch('${ApiConfig.wbsEndpoint}/tasks/$taskId/status', data: data);

    return response.data;
  }

  /// Upload evidence files for a WBS task
  Future<Map<String, dynamic>> uploadEvidence(String taskId, {required FormData formData}) async {
    final response = await _dio.post(
      '${ApiConfig.wbsEndpoint}/tasks/$taskId/evidence',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return response.data;
  }

  /// Upload evidence/attachment files for a WBS task with file path
  Future<Map<String, dynamic>> uploadTaskEvidence(
    String taskId, {
    required String filePath,
    required String description,
    required String evidenceType,
  }) async {
    // Create form data for file upload
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'description': description,
      'evidence_type': evidenceType,
    });

    return await uploadEvidence(taskId, formData: formData);
  }

  /// Get comprehensive progress information for a project
  Future<Map<String, dynamic>> getProjectProgress(String projectId) async {
    final response = await _dio.get('${ApiConfig.wbsEndpoint}/projects/$projectId/progress');

    return response.data;
  }

  /// Get dependency information for a specific task
  Future<Map<String, dynamic>> getTaskDependencies(String taskId) async {
    final response = await _dio.get('${ApiConfig.wbsEndpoint}/tasks/$taskId/dependencies');

    return response.data;
  }

  /// Delete a WBS task
  Future<void> deleteWBSTask(String taskId) async {
    await _dio.delete('${ApiConfig.wbsEndpoint}/tasks/$taskId');
  }

  /// Bulk update multiple tasks
  Future<Map<String, dynamic>> bulkUpdateTasks(String projectId, List<Map<String, dynamic>> updates) async {
    final response = await _dio.patch(
      '${ApiConfig.wbsEndpoint}/projects/$projectId/wbs/bulk-update',
      data: {'updates': updates},
    );

    return response.data;
  }
}
