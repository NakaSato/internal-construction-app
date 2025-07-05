import 'package:equatable/equatable.dart';
import 'wbs_task.dart';

/// Work Breakdown Structure container that holds the complete WBS tree
class WbsStructure extends Equatable {
  const WbsStructure({
    required this.projectId,
    required this.projectName,
    required this.rootTasks,
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.notStartedTasks,
    this.lastUpdated,
    this.version,
  });

  /// ID of the project this WBS belongs to
  final String projectId;

  /// Name of the project
  final String projectName;

  /// Top-level WBS tasks (Level 1)
  final List<WbsTask> rootTasks;

  /// Total number of tasks in the WBS
  final int totalTasks;

  /// Number of completed tasks
  final int completedTasks;

  /// Number of tasks in progress
  final int inProgressTasks;

  /// Number of not started tasks
  final int notStartedTasks;

  /// When the WBS was last updated
  final DateTime? lastUpdated;

  /// Version of the WBS structure
  final String? version;

  /// Calculate completion percentage
  double get completionPercentage {
    if (totalTasks == 0) return 0.0;
    return (completedTasks / totalTasks) * 100.0;
  }

  /// Get all tasks flattened from the tree structure
  List<WbsTask> getAllTasks() {
    final List<WbsTask> allTasks = [];

    void collectTasks(List<WbsTask> tasks) {
      for (final task in tasks) {
        allTasks.add(task);
        if (task.children.isNotEmpty) {
          collectTasks(task.children);
        }
      }
    }

    collectTasks(rootTasks);
    return allTasks;
  }

  /// Get tasks by status
  List<WbsTask> getTasksByStatus(WbsTaskStatus status) {
    return getAllTasks().where((task) => task.status == status).toList();
  }

  /// Get critical path tasks (tasks with high priority)
  List<WbsTask> getCriticalPathTasks() {
    return getAllTasks().where((task) => task.priority == WbsTaskPriority.critical).toList();
  }

  /// Get overdue tasks
  List<WbsTask> getOverdueTasks() {
    return getAllTasks().where((task) => task.isOverdue).toList();
  }

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    rootTasks,
    totalTasks,
    completedTasks,
    inProgressTasks,
    notStartedTasks,
    lastUpdated,
    version,
  ];

  WbsStructure copyWith({
    String? projectId,
    String? projectName,
    List<WbsTask>? rootTasks,
    int? totalTasks,
    int? completedTasks,
    int? inProgressTasks,
    int? notStartedTasks,
    DateTime? lastUpdated,
    String? version,
  }) {
    return WbsStructure(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      rootTasks: rootTasks ?? this.rootTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      inProgressTasks: inProgressTasks ?? this.inProgressTasks,
      notStartedTasks: notStartedTasks ?? this.notStartedTasks,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      version: version ?? this.version,
    );
  }
}
