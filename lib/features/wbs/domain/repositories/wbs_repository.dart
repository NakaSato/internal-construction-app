import 'package:dartz/dartz.dart';
import '../../../../common/models/errors/failures.dart';
import '../entities/wbs_task.dart';
import '../entities/wbs_progress.dart';
import '../entities/wbs_structure.dart';

/// Repository interface for WBS operations
abstract class WbsRepository {
  /// Get complete Work Breakdown Structure for a project
  Future<Either<Failure, WbsStructure>> getProjectWbs({
    required String projectId,
    int? level,
    WbsTaskStatus? status,
    String? assignedTo,
    bool includeChildren = true,
    bool includeEvidence = false,
  });

  /// Get detailed information about a specific WBS task
  Future<Either<Failure, WbsTask>> getWbsTask(String taskId);

  /// Create a new task in the Work Breakdown Structure
  Future<Either<Failure, WbsTask>> createWbsTask({required String projectId, required WbsTask task});

  /// Update an existing WBS task
  Future<Either<Failure, WbsTask>> updateWbsTask({required String taskId, required WbsTask task});

  /// Update only the status of a WBS task
  Future<Either<Failure, WbsTask>> updateTaskStatus({
    required String taskId,
    required WbsTaskStatus status,
    String? completionNotes,
    String? completedBy,
  });

  /// Delete a WBS task (only if no dependencies exist)
  Future<Either<Failure, void>> deleteWbsTask(String taskId);

  /// Upload evidence files for a WBS task
  Future<Either<Failure, WbsAttachment>> uploadEvidence({
    required String taskId,
    required String filePath,
    required String description,
    required String evidenceType,
  });

  /// Get comprehensive progress information for a project
  Future<Either<Failure, WbsProgressSummary>> getProjectProgress(String projectId);

  /// Get dependency information for a specific task
  Future<Either<Failure, WbsTaskDependency>> getTaskDependencies(String taskId);

  /// Bulk update multiple tasks in a single request
  Future<Either<Failure, List<WbsTask>>> bulkUpdateTasks({
    required String projectId,
    required List<WbsBulkUpdate> updates,
  });

  /// Get tasks filtered by various criteria
  Future<Either<Failure, List<WbsTask>>> getFilteredTasks({
    required String projectId,
    WbsTaskType? taskType,
    WbsTaskStatus? status,
    WbsTaskPriority? priority,
    String? assignedTo,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
  });

  /// Get critical path tasks for a project
  Future<Either<Failure, List<WbsTask>>> getCriticalPathTasks(String projectId);

  /// Get overdue tasks for a project
  Future<Either<Failure, List<WbsTask>>> getOverdueTasks(String projectId);

  /// Get tasks assigned to a specific user
  Future<Either<Failure, List<WbsTask>>> getTasksByAssignee({required String assigneeId, WbsTaskStatus? status});

  /// Get upcoming milestones for a project
  Future<Either<Failure, List<WbsMilestone>>> getUpcomingMilestones({required String projectId, int daysAhead = 30});

  /// Search tasks by name or description
  Future<Either<Failure, List<WbsTask>>> searchTasks({
    required String projectId,
    required String searchQuery,
    WbsTaskType? taskType,
    WbsTaskStatus? status,
  });

  /// Get task hierarchy (parent and children) for a specific task
  Future<Either<Failure, WbsTaskHierarchy>> getTaskHierarchy(String taskId);

  /// Clone/duplicate a task with its structure
  Future<Either<Failure, WbsTask>> cloneTask({
    required String sourceTaskId,
    required String newProjectId,
    required String newTaskName,
    bool includeChildren = true,
  });

  /// Get task templates for quick task creation
  Future<Either<Failure, List<WbsTaskTemplate>>> getTaskTemplates({WbsTaskType? taskType, String? category});

  /// Generate WBS code for a new task
  Future<Either<Failure, String>> generateWbsCode({required String projectId, String? parentTaskId});
}

/// Bulk update operation
class WbsBulkUpdate {
  const WbsBulkUpdate({
    required this.taskId,
    this.progressPercentage,
    this.status,
    this.actualDuration,
    this.actualCost,
    this.notes,
    this.completedAt,
  });

  final String taskId;
  final int? progressPercentage;
  final WbsTaskStatus? status;
  final int? actualDuration;
  final double? actualCost;
  final String? notes;
  final DateTime? completedAt;
}

/// Task hierarchy structure
class WbsTaskHierarchy {
  const WbsTaskHierarchy({required this.task, this.parent, required this.children, required this.siblings});

  final WbsTask task;
  final WbsTask? parent;
  final List<WbsTask> children;
  final List<WbsTask> siblings;
}

/// Task template for quick creation
class WbsTaskTemplate {
  const WbsTaskTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.taskType,
    required this.category,
    required this.estimatedDuration,
    required this.deliverables,
    required this.acceptanceCriteria,
    required this.materialsRequired,
    required this.equipmentRequired,
    required this.safetyRequirements,
    required this.qualityStandards,
    required this.evidenceRequired,
  });

  final String id;
  final String name;
  final String description;
  final WbsTaskType taskType;
  final String category;
  final int estimatedDuration;
  final List<String> deliverables;
  final List<String> acceptanceCriteria;
  final List<String> materialsRequired;
  final List<String> equipmentRequired;
  final List<String> safetyRequirements;
  final List<String> qualityStandards;
  final List<String> evidenceRequired;
}
