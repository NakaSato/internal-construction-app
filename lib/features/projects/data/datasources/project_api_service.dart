import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import '../models/project_response.dart';
import '../models/single_project_response.dart';

part 'project_api_service.g.dart';

/// API service for project management operations
@RestApi()
@injectable
abstract class ProjectApiService {
  @factoryMethod
  factory ProjectApiService(Dio dio, {String? baseUrl}) = _ProjectApiService;

  /// Get all projects with pagination and optional filtering
  @GET('/api/v1/projects')
  Future<ProjectResponse> getProjects(@Queries() Map<String, dynamic> queries);

  /// Get a single project by ID
  @GET('/api/v1/projects/{id}')
  Future<SingleProjectResponse> getProject(@Path('id') String projectId);

  /// Delete a project by ID
  @DELETE('/api/v1/projects/{id}')
  Future<void> deleteProject(@Path('id') String projectId);
}
