import 'package:equatable/equatable.dart';
import 'wbs_task.dart';

/// Project progress summary with comprehensive metrics
class WbsProgressSummary extends Equatable {
  const WbsProgressSummary({
    required this.projectId,
    required this.overallProgress,
    required this.phaseProgress,
    required this.tasksSummary,
    required this.schedulePerformance,
    required this.costPerformance,
    this.criticalPath = const [],
    this.upcomingMilestones = const [],
  });

  final String projectId;
  final double overallProgress;
  final WbsPhaseProgress phaseProgress;
  final WbsTasksSummary tasksSummary;
  final WbsSchedulePerformance schedulePerformance;
  final WbsCostPerformance costPerformance;
  final List<WbsCriticalPathItem> criticalPath;
  final List<WbsMilestone> upcomingMilestones;

  @override
  List<Object?> get props => [
    projectId,
    overallProgress,
    phaseProgress,
    tasksSummary,
    schedulePerformance,
    costPerformance,
    criticalPath,
    upcomingMilestones,
  ];
}

/// Progress breakdown by project phases
class WbsPhaseProgress extends Equatable {
  const WbsPhaseProgress({
    required this.initiation,
    required this.planning,
    required this.execution,
    required this.monitoring,
    required this.closure,
  });

  final double initiation;
  final double planning;
  final double execution;
  final double monitoring;
  final double closure;

  /// Get the current active phase based on progress
  WbsProjectPhase get currentPhase {
    if (closure > 0) return WbsProjectPhase.closure;
    if (monitoring > 0) return WbsProjectPhase.monitoring;
    if (execution > 0) return WbsProjectPhase.execution;
    if (planning > 0) return WbsProjectPhase.planning;
    return WbsProjectPhase.initiation;
  }

  @override
  List<Object?> get props => [initiation, planning, execution, monitoring, closure];
}

/// Task summary counts by status
class WbsTasksSummary extends Equatable {
  const WbsTasksSummary({
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.notStartedTasks,
    required this.blockedTasks,
  });

  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int notStartedTasks;
  final int blockedTasks;

  /// Calculate completion percentage
  double get completionPercentage {
    if (totalTasks == 0) return 0.0;
    return (completedTasks / totalTasks) * 100;
  }

  /// Calculate active tasks percentage
  double get activePercentage {
    if (totalTasks == 0) return 0.0;
    return (inProgressTasks / totalTasks) * 100;
  }

  /// Check if project has blocked tasks
  bool get hasBlockedTasks => blockedTasks > 0;

  @override
  List<Object?> get props => [totalTasks, completedTasks, inProgressTasks, notStartedTasks, blockedTasks];
}

/// Schedule performance metrics
class WbsSchedulePerformance extends Equatable {
  const WbsSchedulePerformance({required this.onSchedule, required this.behindSchedule, required this.aheadSchedule});

  final int onSchedule;
  final int behindSchedule;
  final int aheadSchedule;

  /// Calculate total tasks
  int get totalTasks => onSchedule + behindSchedule + aheadSchedule;

  /// Calculate on-time percentage
  double get onTimePercentage {
    if (totalTasks == 0) return 100.0;
    return (onSchedule / totalTasks) * 100;
  }

  /// Check if project is generally on schedule
  bool get isOnSchedule => onTimePercentage >= 80.0;

  @override
  List<Object?> get props => [onSchedule, behindSchedule, aheadSchedule];
}

/// Cost performance metrics
class WbsCostPerformance extends Equatable {
  const WbsCostPerformance({
    required this.estimatedTotal,
    required this.actualSpent,
    required this.variance,
    required this.variancePercentage,
  });

  final double estimatedTotal;
  final double actualSpent;
  final double variance;
  final double variancePercentage;

  /// Check if project is over budget
  bool get isOverBudget => variance > 0;

  /// Check if project is significantly over budget (>10%)
  bool get isSignificantlyOverBudget => variancePercentage > 10.0;

  /// Get budget utilization percentage
  double get budgetUtilization {
    if (estimatedTotal == 0) return 0.0;
    return (actualSpent / estimatedTotal) * 100;
  }

  @override
  List<Object?> get props => [estimatedTotal, actualSpent, variance, variancePercentage];
}

/// Critical path item
class WbsCriticalPathItem extends Equatable {
  const WbsCriticalPathItem({
    required this.taskId,
    required this.taskName,
    required this.status,
    required this.daysBehind,
  });

  final String taskId;
  final String taskName;
  final WbsTaskStatus status;
  final int daysBehind;

  /// Check if task is significantly behind
  bool get isSignificantlyBehind => daysBehind > 3;

  @override
  List<Object?> get props => [taskId, taskName, status, daysBehind];
}

/// Upcoming milestone
class WbsMilestone extends Equatable {
  const WbsMilestone({required this.taskId, required this.taskName, required this.dueDate, required this.daysUntilDue});

  final String taskId;
  final String taskName;
  final DateTime dueDate;
  final int daysUntilDue;

  /// Check if milestone is due soon (within 7 days)
  bool get isDueSoon => daysUntilDue <= 7 && daysUntilDue >= 0;

  /// Check if milestone is overdue
  bool get isOverdue => daysUntilDue < 0;

  @override
  List<Object?> get props => [taskId, taskName, dueDate, daysUntilDue];
}

/// Project phases enumeration
enum WbsProjectPhase {
  initiation,
  planning,
  execution,
  monitoring,
  closure;

  String get displayName {
    switch (this) {
      case WbsProjectPhase.initiation:
        return 'Initiation';
      case WbsProjectPhase.planning:
        return 'Planning';
      case WbsProjectPhase.execution:
        return 'Execution';
      case WbsProjectPhase.monitoring:
        return 'Monitoring';
      case WbsProjectPhase.closure:
        return 'Closure';
    }
  }

  String get description {
    switch (this) {
      case WbsProjectPhase.initiation:
        return 'Project start-up, feasibility, and initial planning';
      case WbsProjectPhase.planning:
        return 'Detailed planning, design, and preparation';
      case WbsProjectPhase.execution:
        return 'Implementation and construction activities';
      case WbsProjectPhase.monitoring:
        return 'Quality control, testing, and commissioning';
      case WbsProjectPhase.closure:
        return 'Project completion, handover, and documentation';
    }
  }

  int get sortOrder {
    switch (this) {
      case WbsProjectPhase.initiation:
        return 1;
      case WbsProjectPhase.planning:
        return 2;
      case WbsProjectPhase.execution:
        return 3;
      case WbsProjectPhase.monitoring:
        return 4;
      case WbsProjectPhase.closure:
        return 5;
    }
  }
}

/// WBS structure summary
class WbsStructureSummary extends Equatable {
  const WbsStructureSummary({required this.totalTasks, required this.completedTasks, required this.overallProgress});

  final int totalTasks;
  final int completedTasks;
  final double overallProgress;

  @override
  List<Object?> get props => [totalTasks, completedTasks, overallProgress];
}

/// Task dependency information
class WbsTaskDependency extends Equatable {
  const WbsTaskDependency({
    required this.taskId,
    required this.prerequisites,
    required this.dependents,
    required this.canStart,
    this.blockingReason,
  });

  final String taskId;
  final List<WbsPrerequisite> prerequisites;
  final List<WbsDependent> dependents;
  final bool canStart;
  final String? blockingReason;

  /// Check if all prerequisites are completed
  bool get allPrerequisitesCompleted {
    return prerequisites.every((prereq) => prereq.status == WbsTaskStatus.completed);
  }

  /// Get pending prerequisites
  List<WbsPrerequisite> get pendingPrerequisites {
    return prerequisites.where((prereq) => prereq.status != WbsTaskStatus.completed).toList();
  }

  @override
  List<Object?> get props => [taskId, prerequisites, dependents, canStart, blockingReason];
}

/// Prerequisite task information
class WbsPrerequisite extends Equatable {
  const WbsPrerequisite({
    required this.id,
    required this.taskName,
    required this.status,
    this.completionDate,
    this.expectedCompletion,
  });

  final String id;
  final String taskName;
  final WbsTaskStatus status;
  final DateTime? completionDate;
  final DateTime? expectedCompletion;

  @override
  List<Object?> get props => [id, taskName, status, completionDate, expectedCompletion];
}

/// Dependent task information
class WbsDependent extends Equatable {
  const WbsDependent({required this.id, required this.taskName, required this.status, required this.blockedByCurrent});

  final String id;
  final String taskName;
  final WbsTaskStatus status;
  final bool blockedByCurrent;

  @override
  List<Object?> get props => [id, taskName, status, blockedByCurrent];
}
