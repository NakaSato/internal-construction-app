import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../common/models/errors/failures.dart';
import '../../../../core/mixins/realtime_api_mixin.dart';
import '../../../../core/services/realtime_api_streams.dart';
import '../../domain/entities/task.dart' as task_entity;
import '../../domain/repositories/task_repository.dart';
import 'api_task_repository.dart';

/// Real-time enhanced task repository wrapper
/// Adds real-time update capabilities to task management
@Injectable(as: TaskRepository, env: [Environment.dev, Environment.prod])
class RealtimeTaskRepositoryWrapper with RealtimeApiMixin implements TaskRepository {
  RealtimeTaskRepositoryWrapper(this._baseRepository);

  final ApiTaskRepository _baseRepository;

  @override
  String get endpointName => 'tasks';

  /// Initialize real-time updates for this repository
  Future<void> initializeRealtimeCapabilities() async {
    startRealtimeUpdates<RealtimeTaskUpdate>(
      onUpdate: (update) {
        debugPrint('📋 RealtimeTaskRepositoryWrapper: Received real-time task update: ${update.type}');
        // Real-time updates will be handled by the BLoC layer
        // This repository serves as a bridge for data access
      },
      onError: (error) {
        debugPrint('❌ RealtimeTaskRepositoryWrapper: Real-time error: $error');
      },
    );
  }

  // Delegate all methods to base repository while adding real-time markers

  @override
  Future<Either<Failure, List<task_entity.Task>>> getTasks() async {
    if (kDebugMode) {
      debugPrint('📋 RealtimeTaskRepositoryWrapper.getTasks called with real-time support');
    }
    return await _baseRepository.getTasks();
  }

  @override
  Future<Either<Failure, task_entity.Task>> getTask(String id) async {
    if (kDebugMode) {
      debugPrint('🔍 RealtimeTaskRepositoryWrapper.getTask called with real-time support');
    }
    return await _baseRepository.getTask(id);
  }

  @override
  Future<Either<Failure, List<task_entity.Task>>> getTasksByProject(String projectId) async {
    if (kDebugMode) {
      debugPrint('📋 RealtimeTaskRepositoryWrapper.getTasksByProject called with real-time support');
    }
    return await _baseRepository.getTasksByProject(projectId);
  }

  @override
  Future<Either<Failure, List<task_entity.Task>>> getTasksByAssignee(String assigneeId) async {
    if (kDebugMode) {
      debugPrint('👤 RealtimeTaskRepositoryWrapper.getTasksByAssignee called with real-time support');
    }
    return await _baseRepository.getTasksByAssignee(assigneeId);
  }

  @override
  Future<Either<Failure, task_entity.Task>> createTask(task_entity.Task task) async {
    if (kDebugMode) {
      debugPrint('🆕 RealtimeTaskRepositoryWrapper.createTask called with real-time notifications');
    }

    return await _baseRepository.createTask(task);
  }

  @override
  Future<Either<Failure, task_entity.Task>> updateTask(task_entity.Task task) async {
    if (kDebugMode) {
      debugPrint('✏️ RealtimeTaskRepositoryWrapper.updateTask called with real-time notifications');
    }

    return await _baseRepository.updateTask(task);
  }

  @override
  Future<Either<Failure, bool>> deleteTask(String id) async {
    if (kDebugMode) {
      debugPrint('🗑️ RealtimeTaskRepositoryWrapper.deleteTask called with real-time notifications');
    }

    return await _baseRepository.deleteTask(id);
  }

  @override
  Future<Either<Failure, task_entity.Task>> updateTaskStatus(String id, task_entity.TaskStatus status) async {
    if (kDebugMode) {
      debugPrint('🏷️ RealtimeTaskRepositoryWrapper.updateTaskStatus called with real-time notifications');
    }

    return await _baseRepository.updateTaskStatus(id, status);
  }

  @override
  Future<Either<Failure, task_entity.Task>> updateTaskCompletion(String id, int percentage) async {
    if (kDebugMode) {
      debugPrint('📈 RealtimeTaskRepositoryWrapper.updateTaskCompletion called with real-time notifications');
    }

    return await _baseRepository.updateTaskCompletion(id, percentage);
  }

  /// Dispose real-time resources when no longer needed
  void dispose() {
    disposeRealtime();
    if (kDebugMode) {
      debugPrint('🧹 RealtimeTaskRepositoryWrapper: Disposing real-time task repository');
    }
  }
}
