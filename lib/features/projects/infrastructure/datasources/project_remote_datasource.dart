import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/project_detail_model.dart';

abstract class ProjectRemoteDataSource {
  Future<ProjectDetailModel> getProjectDetail(String projectId);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  const ProjectRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ProjectDetailModel> getProjectDetail(String projectId) async {
    try {
      final response = await _dio.get('/api/v1/projects/$projectId');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ProjectDetailModel.fromJson(data);
      } else {
        throw ServerException(
          'Failed to get project detail: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(e.message ?? 'Server error occurred');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
