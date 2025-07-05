import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/mixins/realtime_api_mixin.dart';
import '../../../../core/services/realtime_api_streams.dart';
import '../repositories/api_project_repository.dart';
import '../../domain/entities/project_api_models.dart';
import '../../domain/repositories/project_repository.dart';

/// Enhanced API repository wrapper that adds real-time updates to existing repository
/// Decorator pattern to add real-time capabilities without modifying existing code
@Injectable(as: EnhancedProjectRepository, env: [Environment.dev, Environment.prod])
class RealtimeProjectRepositoryWrapper with RealtimeApiMixin implements EnhancedProjectRepository {
  RealtimeProjectRepositoryWrapper(this._baseRepository);

  final ApiProjectRepository _baseRepository;

  // Real-time update stream controller
  final StreamController<RealtimeProjectUpdate> _projectUpdatesController =
      StreamController<RealtimeProjectUpdate>.broadcast();

  @override
  String get endpointName => 'projects';

  /// Stream of real-time project updates
  Stream<RealtimeProjectUpdate> get projectUpdatesStream => _projectUpdatesController.stream;

  /// Initialize real-time updates for this repository
  Future<void> initializeRealtimeUpdates() async {
    startRealtimeUpdates<RealtimeProjectUpdate>(
      onUpdate: (update) {
        if (kDebugMode) {
          debugPrint('📡 RealtimeProjectRepositoryWrapper: Received real-time update: ${update.type}');
        }
        _projectUpdatesController.add(update);
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('❌ RealtimeProjectRepositoryWrapper: Real-time error: $error');
        }
      },
    );
  }

  // Delegate all methods to base repository while adding real-time markers

  @override
  Future<ProjectsResponse> getAllProjects(ProjectsQuery query) async {
    if (kDebugMode) {
      debugPrint('� RealtimeProjectRepositoryWrapper.getAllProjects called with real-time support');
    }
    return await _baseRepository.getAllProjects(query);
  }

  @override
  Future<EnhancedProject> getProjectById(String id) async {
    if (kDebugMode) {
      debugPrint('🔍 RealtimeProjectRepositoryWrapper.getProjectById called with real-time support');
    }
    return await _baseRepository.getProjectById(id);
  }

  @override
  Future<EnhancedProject> createProject(Map<String, dynamic> projectData) async {
    if (kDebugMode) {
      debugPrint('🆕 RealtimeProjectRepositoryWrapper.createProject called with real-time notifications');
    }

    // Add real-time notification flags
    final enhancedData = Map<String, dynamic>.from(projectData);
    enhancedData['_realtime'] = 'true';
    enhancedData['_notifyClients'] = 'true';

    return await _baseRepository.createProject(enhancedData);
  }

  @override
  Future<EnhancedProject> updateProject(String id, Map<String, dynamic> projectData) async {
    if (kDebugMode) {
      debugPrint('🔄 RealtimeProjectRepositoryWrapper.updateProject called with real-time notifications');
    }

    // Add real-time notification flags
    final enhancedData = Map<String, dynamic>.from(projectData);
    enhancedData['_realtime'] = 'true';
    enhancedData['_notifyClients'] = 'true';

    return await _baseRepository.updateProject(id, enhancedData);
  }

  @override
  Future<void> deleteProject(String id) async {
    if (kDebugMode) {
      debugPrint('🗑️ RealtimeProjectRepositoryWrapper.deleteProject called with real-time notifications');
    }
    return await _baseRepository.deleteProject(id);
  }

  @override
  Future<ProjectsResponse> searchProjects(String searchQuery, ProjectsQuery query) async {
    if (kDebugMode) {
      debugPrint('🔍 RealtimeProjectRepositoryWrapper.searchProjects called with real-time support');
    }
    return await _baseRepository.searchProjects(searchQuery, query);
  }

  @override
  Future<ProjectsResponse> getProjectsByManager(String managerId, ProjectsQuery query) async {
    if (kDebugMode) {
      debugPrint('👤 RealtimeProjectRepositoryWrapper.getProjectsByManager called with real-time support');
    }
    return await _baseRepository.getProjectsByManager(managerId, query);
  }

  @override
  Future<ProjectsResponse> getProjectsByStatus(String status, ProjectsQuery query) async {
    if (kDebugMode) {
      debugPrint('📊 RealtimeProjectRepositoryWrapper.getProjectsByStatus called with real-time support');
    }
    return await _baseRepository.getProjectsByStatus(status, query);
  }

  @override
  Future<Map<String, dynamic>> getProjectStatistics() async {
    if (kDebugMode) {
      debugPrint('📈 RealtimeProjectRepositoryWrapper.getProjectStatistics called with real-time support');
    }
    return await _baseRepository.getProjectStatistics();
  }

  @override
  Future<ProjectsResponse> getProjectsNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
    ProjectsQuery query,
  ) async {
    if (kDebugMode) {
      debugPrint('🗺️ RealtimeProjectRepositoryWrapper.getProjectsNearLocation called with real-time support');
    }
    return await _baseRepository.getProjectsNearLocation(latitude, longitude, radiusKm, query);
  }

  @override
  Future<void> clearProjectCache() async {
    if (kDebugMode) {
      debugPrint('🗑️ RealtimeProjectRepositoryWrapper: Clearing project cache');
    }
    return await _baseRepository.clearProjectCache();
  }

  @override
  Stream<ProjectsResponse> getLiveProjectUpdates(
    ProjectsQuery query, {
    Duration updateInterval = const Duration(seconds: 10),
    bool includeDeltas = false,
  }) {
    if (kDebugMode) {
      debugPrint('🔴 RealtimeProjectRepositoryWrapper: Starting live project updates');
    }
    return _baseRepository.getLiveProjectUpdates(query, updateInterval: updateInterval, includeDeltas: includeDeltas);
  }

  /// Dispose resources including real-time updates
  void dispose() {
    stopRealtimeUpdates();
    _projectUpdatesController.close();
  }
}
