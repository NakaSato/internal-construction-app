import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/wbs_task.dart';
import '../../domain/entities/wbs_progress.dart';
import '../../domain/entities/wbs_structure.dart';
import '../../domain/repositories/wbs_repository.dart';
import '../services/wbs_api_service.dart';
import '../../../../common/models/errors/failures.dart';

@LazySingleton(as: WbsRepository)
class WbsRepositoryImpl implements WbsRepository {
  final WBSApiService _apiService;

  WbsRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, WbsStructure>> getProjectWbs({
    required String projectId,
    int? level,
    WbsTaskStatus? status,
    String? assignedTo,
    bool includeChildren = true,
    bool includeEvidence = false,
  }) async {
    try {
      final response = await _apiService.getProjectWBS(
        projectId,
        level: level,
        status: status?.name,
        assignedTo: assignedTo,
        includeChildren: includeChildren,
        includeEvidence: includeEvidence,
      );

      final data = response['data'] as Map<String, dynamic>;
      final tasksData = data['wbs_structure'] as List<dynamic>? ?? [];
      final summaryData = data['summary'] as Map<String, dynamic>? ?? {};

      final rootTasks = tasksData.map((taskJson) => WbsTask.fromJson(taskJson as Map<String, dynamic>)).toList();

      final wbsStructure = WbsStructure(
        projectId: data['project_id'] as String? ?? projectId,
        projectName: data['project_name'] as String? ?? 'Unknown Project',
        rootTasks: rootTasks,
        totalTasks: summaryData['total_tasks'] as int? ?? 0,
        completedTasks: summaryData['completed_tasks'] as int? ?? 0,
        inProgressTasks: summaryData['in_progress_tasks'] as int? ?? 0,
        notStartedTasks: summaryData['not_started_tasks'] as int? ?? 0,
        lastUpdated: data['last_updated'] != null ? DateTime.tryParse(data['last_updated'] as String) : null,
        version: data['version'] as String?,
      );

      return Right(wbsStructure);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch project WBS: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WbsTask>> getWbsTask(String taskId) async {
    try {
      final response = await _apiService.getWBSTaskDetails(taskId);

      final taskData = response['data'] as Map<String, dynamic>;
      final task = WbsTask.fromJson(taskData);

      return Right(task);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch task details: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WbsTask>> createWbsTask({required String projectId, required WbsTask task}) async {
    try {
      final response = await _apiService.createWBSTask(projectId, task.toJson());

      final createdTaskData = response['data'] as Map<String, dynamic>;
      final createdTask = WbsTask.fromJson(createdTaskData);

      return Right(createdTask);
    } catch (e) {
      return Left(ServerFailure('Failed to create task: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WbsTask>> updateWbsTask({required String taskId, required WbsTask task}) async {
    try {
      final response = await _apiService.updateWBSTask(taskId, task.toJson());

      final updatedTaskData = response['data'] as Map<String, dynamic>;
      final updatedTask = WbsTask.fromJson(updatedTaskData);

      return Right(updatedTask);
    } catch (e) {
      return Left(ServerFailure('Failed to update task: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WbsTask>> updateTaskStatus({
    required String taskId,
    required WbsTaskStatus status,
    String? completionNotes,
    String? completedBy,
  }) async {
    try {
      final response = await _apiService.updateTaskStatus(
        taskId,
        status: status.name,
        completionNotes: completionNotes,
        completedBy: completedBy,
      );

      final updatedTaskData = response['data'] as Map<String, dynamic>;
      final updatedTask = WbsTask.fromJson(updatedTaskData);

      return Right(updatedTask);
    } catch (e) {
      return Left(ServerFailure('Failed to update task status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWbsTask(String taskId) async {
    try {
      await _apiService.deleteWBSTask(taskId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete task: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WbsAttachment>> uploadEvidence({
    required String taskId,
    required String filePath,
    required String description,
    required String evidenceType,
  }) async {
    try {
      final response = await _apiService.uploadTaskEvidence(
        taskId,
        filePath: filePath,
        description: description,
        evidenceType: evidenceType,
      );

      final attachmentData = response['data'] as Map<String, dynamic>;
      final attachment = WbsAttachment.fromJson(attachmentData);

      return Right(attachment);
    } catch (e) {
      return Left(ServerFailure('Failed to upload evidence: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WbsProgressSummary>> getProjectProgress(String projectId) async {
    try {
      final response = await _apiService.getProjectProgress(projectId);

      final progressData = response['data'] as Map<String, dynamic>;

      final phaseProgressData = progressData['phase_progress'] as Map<String, dynamic>? ?? {};
      final phaseProgress = WbsPhaseProgress(
        initiation: (phaseProgressData['initiation'] as num?)?.toDouble() ?? 0.0,
        planning: (phaseProgressData['planning'] as num?)?.toDouble() ?? 0.0,
        execution: (phaseProgressData['execution'] as num?)?.toDouble() ?? 0.0,
        monitoring: (phaseProgressData['monitoring'] as num?)?.toDouble() ?? 0.0,
        closure: (phaseProgressData['closure'] as num?)?.toDouble() ?? 0.0,
      );

      final tasksData = progressData['tasks_summary'] as Map<String, dynamic>? ?? {};
      final tasksSummary = WbsTasksSummary(
        totalTasks: tasksData['total_tasks'] as int? ?? 0,
        completedTasks: tasksData['completed_tasks'] as int? ?? 0,
        inProgressTasks: tasksData['in_progress_tasks'] as int? ?? 0,
        notStartedTasks: tasksData['not_started_tasks'] as int? ?? 0,
        blockedTasks: tasksData['blocked_tasks'] as int? ?? 0,
      );

      final scheduleData = progressData['schedule_performance'] as Map<String, dynamic>? ?? {};
      final schedulePerformance = WbsSchedulePerformance(
        onSchedule: scheduleData['tasks_on_schedule'] as int? ?? 0,
        behindSchedule: scheduleData['overdue_tasks'] as int? ?? 0,
        aheadSchedule: scheduleData['ahead_schedule_tasks'] as int? ?? 0,
      );

      final costData = progressData['cost_performance'] as Map<String, dynamic>? ?? {};
      final costPerformance = WbsCostPerformance(
        estimatedTotal: (costData['budget_at_completion'] as num?)?.toDouble() ?? 0.0,
        actualSpent: (costData['actual_cost'] as num?)?.toDouble() ?? 0.0,
        variance: (costData['budget_variance'] as num?)?.toDouble() ?? 0.0,
        variancePercentage: (costData['variance_percentage'] as num?)?.toDouble() ?? 0.0,
      );

      final progress = WbsProgressSummary(
        projectId: projectId,
        overallProgress: (progressData['overall_progress'] as num?)?.toDouble() ?? 0.0,
        phaseProgress: phaseProgress,
        tasksSummary: tasksSummary,
        schedulePerformance: schedulePerformance,
        costPerformance: costPerformance,
      );

      return Right(progress);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch project progress: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WbsTaskDependency>> getTaskDependencies(String taskId) async {
    try {
      final response = await _apiService.getTaskDependencies(taskId);

      final data = response['data'] as Map<String, dynamic>;

      final prerequisitesData = data['prerequisites'] as List<dynamic>? ?? [];
      final prerequisites = prerequisitesData
          .map(
            (item) => WbsPrerequisite(
              id: item['id'] as String,
              taskName: item['task_name'] as String,
              status: WbsTask.parseTaskStatus(item['status'] as String?),
              completionDate: item['completion_date'] != null
                  ? DateTime.tryParse(item['completion_date'] as String)
                  : null,
              expectedCompletion: item['expected_completion'] != null
                  ? DateTime.tryParse(item['expected_completion'] as String)
                  : null,
            ),
          )
          .toList();

      final dependentsData = data['dependents'] as List<dynamic>? ?? [];
      final dependents = dependentsData
          .map(
            (item) => WbsDependent(
              id: item['id'] as String,
              taskName: item['task_name'] as String,
              status: WbsTask.parseTaskStatus(item['status'] as String?),
              blockedByCurrent: item['blocked_by_current'] as bool? ?? false,
            ),
          )
          .toList();

      final dependency = WbsTaskDependency(
        taskId: taskId,
        prerequisites: prerequisites,
        dependents: dependents,
        canStart: data['can_start'] as bool? ?? true,
        blockingReason: data['blocking_reason'] as String?,
      );

      return Right(dependency);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch task dependencies: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WbsTask>>> bulkUpdateTasks({
    required String projectId,
    required List<WbsBulkUpdate> updates,
  }) async {
    try {
      final updateData = updates
          .map(
            (update) => {
              'task_id': update.taskId,
              if (update.progressPercentage != null) 'progress_percentage': update.progressPercentage,
              if (update.status != null) 'status': update.status!.name,
              if (update.actualDuration != null) 'actual_duration': update.actualDuration,
              if (update.actualCost != null) 'actual_cost': update.actualCost,
              if (update.notes != null) 'notes': update.notes,
              if (update.completedAt != null) 'completed_at': update.completedAt!.toIso8601String(),
            },
          )
          .toList();

      final response = await _apiService.bulkUpdateTasks(projectId, updateData);

      final tasksData = response['data'] as List<dynamic>? ?? [];
      final updatedTasks = tasksData.map((taskJson) => WbsTask.fromJson(taskJson as Map<String, dynamic>)).toList();

      return Right(updatedTasks);
    } catch (e) {
      return Left(ServerFailure('Failed to bulk update tasks: ${e.toString()}'));
    }
  }

  @override
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
  }) async {
    try {
      // For now, use the basic WBS endpoint with filtering
      final response = await _apiService.getProjectWBS(projectId, status: status?.name, assignedTo: assignedTo);

      final data = response['data'] as Map<String, dynamic>;
      final tasksData = data['wbs_structure'] as List<dynamic>? ?? [];

      // Simple filtering on client side for now
      var tasks = tasksData.map((taskJson) => WbsTask.fromJson(taskJson as Map<String, dynamic>)).toList();

      if (taskType != null) {
        tasks = tasks.where((task) => task.taskType == taskType).toList();
      }
      if (priority != null) {
        tasks = tasks.where((task) => task.priority == priority).toList();
      }

      return Right(tasks);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch filtered tasks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WbsTask>>> getCriticalPathTasks(String projectId) async {
    try {
      // For now, get all tasks and filter by critical priority
      final response = await _apiService.getProjectWBS(projectId);

      final data = response['data'] as Map<String, dynamic>;
      final tasksData = data['wbs_structure'] as List<dynamic>? ?? [];

      final tasks = tasksData
          .map((taskJson) => WbsTask.fromJson(taskJson as Map<String, dynamic>))
          .where((task) => task.priority == WbsTaskPriority.critical)
          .toList();

      return Right(tasks);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch critical path tasks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WbsTask>>> getOverdueTasks(String projectId) async {
    try {
      // For now, get all tasks and filter by overdue status
      final response = await _apiService.getProjectWBS(projectId);

      final data = response['data'] as Map<String, dynamic>;
      final tasksData = data['wbs_structure'] as List<dynamic>? ?? [];

      final tasks = tasksData
          .map((taskJson) => WbsTask.fromJson(taskJson as Map<String, dynamic>))
          .where((task) => task.isOverdue)
          .toList();

      return Right(tasks);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch overdue tasks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WbsTask>>> getTasksByAssignee({required String assigneeId, WbsTaskStatus? status}) async {
    try {
      // For now, get all tasks and filter by assignee
      final response = await _apiService.getProjectWBS('', assignedTo: assigneeId);

      final data = response['data'] as Map<String, dynamic>;
      final tasksData = data['wbs_structure'] as List<dynamic>? ?? [];

      var tasks = tasksData
          .map((taskJson) => WbsTask.fromJson(taskJson as Map<String, dynamic>))
          .where((task) => task.assignedUserId == assigneeId || task.assignedTo == assigneeId)
          .toList();

      if (status != null) {
        tasks = tasks.where((task) => task.status == status).toList();
      }

      return Right(tasks);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch tasks by assignee: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WbsMilestone>>> getUpcomingMilestones({
    required String projectId,
    int daysAhead = 30,
  }) async {
    try {
      // For now, return empty list - would need dedicated endpoint
      final milestones = <WbsMilestone>[];

      return Right(milestones);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch upcoming milestones: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WbsTask>>> searchTasks({
    required String projectId,
    required String searchQuery,
    WbsTaskType? taskType,
    WbsTaskStatus? status,
  }) async {
    try {
      // For now, get all tasks and search on client side
      final response = await _apiService.getProjectWBS(projectId, status: status?.name);

      final data = response['data'] as Map<String, dynamic>;
      final tasksData = data['wbs_structure'] as List<dynamic>? ?? [];

      var tasks = tasksData
          .map((taskJson) => WbsTask.fromJson(taskJson as Map<String, dynamic>))
          .where(
            (task) =>
                task.taskNameEN.toLowerCase().contains(searchQuery.toLowerCase()) ||
                task.taskNameTH.toLowerCase().contains(searchQuery.toLowerCase()) ||
                (task.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false),
          )
          .toList();

      if (taskType != null) {
        tasks = tasks.where((task) => task.taskType == taskType).toList();
      }

      return Right(tasks);
    } catch (e) {
      return Left(ServerFailure('Failed to search tasks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WbsTaskHierarchy>> getTaskHierarchy(String taskId) async {
    try {
      // For now, just get the task and return minimal hierarchy
      final response = await _apiService.getWBSTaskDetails(taskId);

      final taskData = response['data'] as Map<String, dynamic>;
      final task = WbsTask.fromJson(taskData);

      final hierarchy = WbsTaskHierarchy(
        task: task,
        parent: null, // Would need parent lookup
        children: task.children,
        siblings: [], // Would need sibling lookup
      );

      return Right(hierarchy);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch task hierarchy: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WbsTask>> cloneTask({
    required String sourceTaskId,
    required String newProjectId,
    required String newTaskName,
    bool includeChildren = true,
  }) async {
    try {
      // For now, get the source task and create a copy
      final sourceResponse = await _apiService.getWBSTaskDetails(sourceTaskId);
      final sourceTaskData = sourceResponse['data'] as Map<String, dynamic>;
      final sourceTask = WbsTask.fromJson(sourceTaskData);

      // Create new task data
      final newTaskData = sourceTask.toJson();
      newTaskData['task_name'] = newTaskName;
      newTaskData.remove('id'); // Remove ID so new one is generated

      final response = await _apiService.createWBSTask(newProjectId, newTaskData);
      final createdTaskData = response['data'] as Map<String, dynamic>;
      final clonedTask = WbsTask.fromJson(createdTaskData);

      return Right(clonedTask);
    } catch (e) {
      return Left(ServerFailure('Failed to clone task: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WbsTaskTemplate>>> getTaskTemplates({WbsTaskType? taskType, String? category}) async {
    try {
      // For now, return empty list - would need dedicated endpoint
      final templates = <WbsTaskTemplate>[];

      return Right(templates);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch task templates: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> generateWbsCode({required String projectId, String? parentTaskId}) async {
    try {
      // For now, generate a simple WBS code
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final wbsCode = parentTaskId != null ? '$parentTaskId.${timestamp % 1000}' : '1.${timestamp % 1000}';

      return Right(wbsCode);
    } catch (e) {
      return Left(ServerFailure('Failed to generate WBS code: ${e.toString()}'));
    }
  }
}
