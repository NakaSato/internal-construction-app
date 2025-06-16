import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import 'api_project_repository.dart';
import 'mock_project_repository.dart';

/// Repository that tries API first, then falls back to mock data
class FallbackProjectRepository implements ProjectRepository {
  const FallbackProjectRepository(this._apiRepository, this._mockRepository);

  final ApiProjectRepository _apiRepository;
  final MockProjectRepository _mockRepository;

  @override
  Future<List<Project>> getAllProjects() async {
    try {
      return await _apiRepository.getAllProjects();
    } on DioException catch (e) {
      debugPrint('API error, falling back to mock data: ${e.message}');
      return await _mockRepository.getAllProjects();
    } catch (e) {
      debugPrint('Unexpected error, falling back to mock data: $e');
      return await _mockRepository.getAllProjects();
    }
  }

  @override
  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async {
    try {
      return await _apiRepository.getProjectsByStatus(status);
    } on DioException catch (e) {
      debugPrint('API error, falling back to mock data: ${e.message}');
      return await _mockRepository.getProjectsByStatus(status);
    } catch (e) {
      debugPrint('Unexpected error, falling back to mock data: $e');
      return await _mockRepository.getProjectsByStatus(status);
    }
  }

  @override
  Future<Project?> getProjectById(String id) async {
    try {
      return await _apiRepository.getProjectById(id);
    } on DioException catch (e) {
      debugPrint('API error, falling back to mock data: ${e.message}');
      return await _mockRepository.getProjectById(id);
    } catch (e) {
      debugPrint('Unexpected error, falling back to mock data: $e');
      return await _mockRepository.getProjectById(id);
    }
  }

  @override
  Future<Project> createProject(Project project) async {
    try {
      return await _apiRepository.createProject(project);
    } on DioException catch (e) {
      debugPrint('API error, falling back to mock data: ${e.message}');
      return await _mockRepository.createProject(project);
    } catch (e) {
      debugPrint('Unexpected error, falling back to mock data: $e');
      return await _mockRepository.createProject(project);
    }
  }

  @override
  Future<Project> updateProject(Project project) async {
    try {
      return await _apiRepository.updateProject(project);
    } on DioException catch (e) {
      debugPrint('API error, falling back to mock data: ${e.message}');
      return await _mockRepository.updateProject(project);
    } catch (e) {
      debugPrint('Unexpected error, falling back to mock data: $e');
      return await _mockRepository.updateProject(project);
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      await _apiRepository.deleteProject(id);
    } on DioException catch (e) {
      debugPrint('API error, falling back to mock data: ${e.message}');
      await _mockRepository.deleteProject(id);
    } catch (e) {
      debugPrint('Unexpected error, falling back to mock data: $e');
      await _mockRepository.deleteProject(id);
    }
  }

  @override
  Future<List<Project>> searchProjects(String query) async {
    try {
      return await _apiRepository.searchProjects(query);
    } on DioException catch (e) {
      debugPrint('API error, falling back to mock data: ${e.message}');
      return await _mockRepository.searchProjects(query);
    } catch (e) {
      debugPrint('Unexpected error, falling back to mock data: $e');
      return await _mockRepository.searchProjects(query);
    }
  }

  @override
  Future<List<Project>> getProjectsByUserId(String userId) async {
    try {
      return await _apiRepository.getProjectsByUserId(userId);
    } on DioException catch (e) {
      debugPrint('API error, falling back to mock data: ${e.message}');
      return await _mockRepository.getProjectsByUserId(userId);
    } catch (e) {
      debugPrint('Unexpected error, falling back to mock data: $e');
      return await _mockRepository.getProjectsByUserId(userId);
    }
  }

  /// Get projects with pagination (custom method for API compatibility)
  Future<List<Project>> getProjects({
    int pageNumber = 1,
    int pageSize = 10,
    String? managerId,
  }) async {
    try {
      return await _apiRepository.getProjects(
        pageNumber: pageNumber,
        pageSize: pageSize,
        managerId: managerId,
      );
    } on DioException catch (e) {
      debugPrint('API error, falling back to mock data: ${e.message}');
      // For mock data, just return all projects with simple pagination simulation
      final allProjects = await _mockRepository.getAllProjects();
      final startIndex = (pageNumber - 1) * pageSize;
      return allProjects.skip(startIndex).take(pageSize).toList();
    } catch (e) {
      debugPrint('Unexpected error, falling back to mock data: $e');
      // For mock data, just return all projects with simple pagination simulation
      final allProjects = await _mockRepository.getAllProjects();
      final startIndex = (pageNumber - 1) * pageSize;
      return allProjects.skip(startIndex).take(pageSize).toList();
    }
  }
}
