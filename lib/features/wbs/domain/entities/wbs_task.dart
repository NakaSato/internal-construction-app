import 'package:equatable/equatable.dart';

/// Work Breakdown Structure task entity
/// Represents a hierarchical task in the solar PV installation WBS
/// Aligned with the new WBS API specification
class WbsTask extends Equatable {
  const WbsTask({
    required this.wbsId,
    required this.taskNameEN,
    required this.taskNameTH,
    required this.projectId,
    required this.status,
    required this.weightPercent,
    required this.createdAt,
    required this.updatedAt,
    this.parentWbsId,
    this.description,
    this.installationArea,
    this.acceptanceCriteria,
    this.plannedStartDate,
    this.actualStartDate,
    this.plannedEndDate,
    this.actualEndDate,
    this.assignedUserId,
    this.assignedUserName,
    this.dependencies = const [],
    this.evidenceCount = 0,
    this.children = const [],
    this.taskType = WbsTaskType.workPackage,
    this.priority = WbsTaskPriority.medium,
    this.progressPercentage = 0,
    this.estimatedCost,
    this.actualCost,
    this.wbsCode, // For backward compatibility
    this.assignedTo, // For backward compatibility
    this.estimatedDuration, // For backward compatibility
    this.actualDuration, // For backward compatibility
    this.startDate, // For backward compatibility
    this.endDate, // For backward compatibility
    this.completedAt, // For backward compatibility
    this.evidenceAttachments = const [], // For evidence files
  });

  // Core fields from new API
  final String wbsId;
  final String? parentWbsId;
  final String taskNameEN;
  final String taskNameTH;
  final String? description;
  final WbsTaskStatus status;
  final double weightPercent;
  final String? installationArea;
  final String? acceptanceCriteria;
  final DateTime? plannedStartDate;
  final DateTime? actualStartDate;
  final DateTime? plannedEndDate;
  final DateTime? actualEndDate;
  final String projectId;
  final String? assignedUserId;
  final String? assignedUserName;
  final List<String> dependencies;
  final int evidenceCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields for compatibility and extended functionality
  final List<WbsTask> children;
  final WbsTaskType taskType;
  final WbsTaskPriority priority;
  final int progressPercentage;
  final double? estimatedCost;
  final double? actualCost;
  final String? wbsCode; // For backward compatibility
  final String? assignedTo; // For backward compatibility
  final int? estimatedDuration; // For backward compatibility
  final int? actualDuration; // For backward compatibility
  final DateTime? startDate; // For backward compatibility
  final DateTime? endDate; // For backward compatibility
  final DateTime? completedAt; // For backward compatibility
  final List<WbsAttachment> evidenceAttachments; // For evidence files

  /// Check if task can be started based on dependencies
  bool get canStart {
    return status != WbsTaskStatus.blocked;
  }

  /// Check if task is currently blocking other tasks
  bool get isBlocking {
    return children.any((child) => child.status == WbsTaskStatus.blocked && child.dependencies.contains(wbsId));
  }

  /// Check if task is overdue
  bool get isOverdue {
    if (status == WbsTaskStatus.completed) return false;
    if (plannedEndDate == null) return false;
    return DateTime.now().isAfter(plannedEndDate!);
  }

  /// Check if task is on schedule
  bool get isOnSchedule {
    if (status == WbsTaskStatus.completed) {
      return actualEndDate != null && plannedEndDate != null && !actualEndDate!.isAfter(plannedEndDate!);
    }

    if (plannedStartDate == null || plannedEndDate == null) return true;

    final now = DateTime.now();
    final totalDuration = plannedEndDate!.difference(plannedStartDate!).inDays;
    final elapsed = now.difference(plannedStartDate!).inDays;

    if (totalDuration == 0) return true;

    final expectedProgress = (elapsed / totalDuration * 100).clamp(0, 100);
    return progressPercentage >= expectedProgress;
  }

  /// Calculate schedule variance in days
  int get scheduleVarianceDays {
    if (plannedEndDate == null) return 0;
    if (status == WbsTaskStatus.completed && actualEndDate != null) {
      return actualEndDate!.difference(plannedEndDate!).inDays;
    }

    if (DateTime.now().isAfter(plannedEndDate!)) {
      return DateTime.now().difference(plannedEndDate!).inDays;
    }

    return 0;
  }

  /// Calculate cost variance
  double get costVariance {
    if (estimatedCost == null || actualCost == null) return 0.0;
    return actualCost! - estimatedCost!;
  }

  /// Calculate cost variance percentage
  double get costVariancePercentage {
    if (estimatedCost == null || estimatedCost == 0) return 0.0;
    if (actualCost == null) return 0.0;
    return ((actualCost! - estimatedCost!) / estimatedCost!) * 100;
  }

  /// Check if task is over budget
  bool get isOverBudget {
    return costVariancePercentage > 0;
  }

  /// Create WbsTask from JSON with PascalCase field names (new API format)
  factory WbsTask.fromJson(Map<String, dynamic> json) {
    return WbsTask(
      wbsId: json['WbsId'] as String? ?? json['wbsId'] as String? ?? '',
      parentWbsId: json['ParentWbsId'] as String? ?? json['parentWbsId'] as String?,
      taskNameEN: json['TaskNameEN'] as String? ?? json['taskNameEN'] as String? ?? '',
      taskNameTH: json['TaskNameTH'] as String? ?? json['taskNameTH'] as String? ?? '',
      description: json['Description'] as String? ?? json['description'] as String?,
      status: parseTaskStatus(json['Status'] as String? ?? json['status'] as String?),
      weightPercent: (json['WeightPercent'] as num?)?.toDouble() ?? (json['weightPercent'] as num?)?.toDouble() ?? 0.0,
      installationArea: json['InstallationArea'] as String? ?? json['installationArea'] as String?,
      acceptanceCriteria: json['AcceptanceCriteria'] as String? ?? json['acceptanceCriteria'] as String?,
      plannedStartDate: json['PlannedStartDate'] != null
          ? DateTime.tryParse(json['PlannedStartDate'] as String)
          : (json['plannedStartDate'] != null ? DateTime.tryParse(json['plannedStartDate'] as String) : null),
      actualStartDate: json['ActualStartDate'] != null
          ? DateTime.tryParse(json['ActualStartDate'] as String)
          : (json['actualStartDate'] != null ? DateTime.tryParse(json['actualStartDate'] as String) : null),
      plannedEndDate: json['PlannedEndDate'] != null
          ? DateTime.tryParse(json['PlannedEndDate'] as String)
          : (json['plannedEndDate'] != null ? DateTime.tryParse(json['plannedEndDate'] as String) : null),
      actualEndDate: json['ActualEndDate'] != null
          ? DateTime.tryParse(json['ActualEndDate'] as String)
          : (json['actualEndDate'] != null ? DateTime.tryParse(json['actualEndDate'] as String) : null),
      projectId: json['ProjectId'] as String? ?? json['projectId'] as String? ?? '',
      assignedUserId: json['AssignedUserId'] as String? ?? json['assignedUserId'] as String?,
      assignedUserName: json['AssignedUserName'] as String? ?? json['assignedUserName'] as String?,
      dependencies:
          (json['Dependencies'] as List<dynamic>?)?.cast<String>() ??
          (json['dependencies'] as List<dynamic>?)?.cast<String>() ??
          [],
      evidenceCount: json['EvidenceCount'] as int? ?? json['evidenceCount'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['CreatedAt'] as String? ?? json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['UpdatedAt'] as String? ?? json['updatedAt'] as String? ?? '') ?? DateTime.now(),

      // Additional fields for compatibility
      children:
          (json['children'] as List<dynamic>?)
              ?.map((item) => WbsTask.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      taskType: parseTaskType(json['TaskType'] as String? ?? json['taskType'] as String?),
      priority: parseTaskPriority(json['Priority'] as String? ?? json['priority'] as String?),
      progressPercentage: json['ProgressPercentage'] as int? ?? json['progressPercentage'] as int? ?? 0,
      estimatedCost: (json['EstimatedCost'] as num?)?.toDouble() ?? (json['estimatedCost'] as num?)?.toDouble(),
      actualCost: (json['ActualCost'] as num?)?.toDouble() ?? (json['actualCost'] as num?)?.toDouble(),
      wbsCode: json['WbsCode'] as String? ?? json['wbsCode'] as String?,
      assignedTo: json['AssignedTo'] as String? ?? json['assignedTo'] as String?,
      estimatedDuration: json['EstimatedDuration'] as int? ?? json['estimatedDuration'] as int?,
      actualDuration: json['ActualDuration'] as int? ?? json['actualDuration'] as int?,
      startDate: json['StartDate'] != null
          ? DateTime.tryParse(json['StartDate'] as String)
          : (json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null),
      endDate: json['EndDate'] != null
          ? DateTime.tryParse(json['EndDate'] as String)
          : (json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null),
      completedAt: json['CompletedAt'] != null
          ? DateTime.tryParse(json['CompletedAt'] as String)
          : (json['completedAt'] != null ? DateTime.tryParse(json['completedAt'] as String) : null),
      evidenceAttachments:
          (json['EvidenceAttachments'] as List<dynamic>?)
              ?.map((item) => WbsAttachment.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convert WbsTask to JSON with PascalCase field names (new API format)
  Map<String, dynamic> toJson() {
    return {
      'WbsId': wbsId,
      'ParentWbsId': parentWbsId,
      'TaskNameEN': taskNameEN,
      'TaskNameTH': taskNameTH,
      'Description': description,
      'Status': status.name,
      'WeightPercent': weightPercent,
      'InstallationArea': installationArea,
      'AcceptanceCriteria': acceptanceCriteria,
      'PlannedStartDate': plannedStartDate?.toIso8601String(),
      'ActualStartDate': actualStartDate?.toIso8601String(),
      'PlannedEndDate': plannedEndDate?.toIso8601String(),
      'ActualEndDate': actualEndDate?.toIso8601String(),
      'ProjectId': projectId,
      'AssignedUserId': assignedUserId,
      'AssignedUserName': assignedUserName,
      'Dependencies': dependencies,
      'EvidenceCount': evidenceCount,
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt.toIso8601String(),
      'TaskType': taskType.name,
      'Priority': priority.name,
      'ProgressPercentage': progressPercentage,
      'EstimatedCost': estimatedCost,
      'ActualCost': actualCost,
      'WbsCode': wbsCode,
      'AssignedTo': assignedTo,
      'EstimatedDuration': estimatedDuration,
      'ActualDuration': actualDuration,
      'StartDate': startDate?.toIso8601String(),
      'EndDate': endDate?.toIso8601String(),
      'CompletedAt': completedAt?.toIso8601String(),
      'EvidenceAttachments': evidenceAttachments.map((e) => e.toJson()).toList(),
    };
  }

  /// Parse task status from string
  static WbsTaskStatus parseTaskStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'not_started':
      case 'notstarted':
        return WbsTaskStatus.notStarted;
      case 'in_progress':
      case 'inprogress':
        return WbsTaskStatus.inProgress;
      case 'completed':
        return WbsTaskStatus.completed;
      case 'blocked':
        return WbsTaskStatus.blocked;
      case 'on_hold':
      case 'onhold':
        return WbsTaskStatus.onHold;
      case 'cancelled':
        return WbsTaskStatus.cancelled;
      case 'under_review':
      case 'underreview':
        return WbsTaskStatus.underReview;
      case 'approved':
        return WbsTaskStatus.approved;
      default:
        return WbsTaskStatus.notStarted;
    }
  }

  /// Parse task type from string
  static WbsTaskType parseTaskType(String? type) {
    switch (type?.toLowerCase()) {
      case 'phase':
        return WbsTaskType.phase;
      case 'deliverable':
        return WbsTaskType.deliverable;
      case 'work_package':
      case 'workpackage':
        return WbsTaskType.workPackage;
      case 'activity':
        return WbsTaskType.activity;
      default:
        return WbsTaskType.workPackage;
    }
  }

  /// Parse task priority from string
  static WbsTaskPriority parseTaskPriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'low':
        return WbsTaskPriority.low;
      case 'medium':
        return WbsTaskPriority.medium;
      case 'high':
        return WbsTaskPriority.high;
      case 'critical':
        return WbsTaskPriority.critical;
      default:
        return WbsTaskPriority.medium;
    }
  }

  /// Create a copy of this task with some values changed
  WbsTask copyWith({
    String? wbsId,
    String? parentWbsId,
    String? taskNameEN,
    String? taskNameTH,
    String? description,
    WbsTaskStatus? status,
    double? weightPercent,
    String? installationArea,
    String? acceptanceCriteria,
    DateTime? plannedStartDate,
    DateTime? actualStartDate,
    DateTime? plannedEndDate,
    DateTime? actualEndDate,
    String? projectId,
    String? assignedUserId,
    String? assignedUserName,
    List<String>? dependencies,
    int? evidenceCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<WbsTask>? children,
    WbsTaskType? taskType,
    WbsTaskPriority? priority,
    int? progressPercentage,
    double? estimatedCost,
    double? actualCost,
    String? wbsCode, // For backward compatibility
    String? assignedTo, // For backward compatibility
    int? estimatedDuration, // For backward compatibility
    int? actualDuration, // For backward compatibility
    DateTime? startDate, // For backward compatibility
    DateTime? endDate, // For backward compatibility
    DateTime? completedAt, // For backward compatibility
    List<WbsAttachment>? evidenceAttachments, // For evidence files
  }) {
    return WbsTask(
      wbsId: wbsId ?? this.wbsId,
      parentWbsId: parentWbsId ?? this.parentWbsId,
      taskNameEN: taskNameEN ?? this.taskNameEN,
      taskNameTH: taskNameTH ?? this.taskNameTH,
      description: description ?? this.description,
      status: status ?? this.status,
      weightPercent: weightPercent ?? this.weightPercent,
      installationArea: installationArea ?? this.installationArea,
      acceptanceCriteria: acceptanceCriteria ?? this.acceptanceCriteria,
      plannedStartDate: plannedStartDate ?? this.plannedStartDate,
      actualStartDate: actualStartDate ?? this.actualStartDate,
      plannedEndDate: plannedEndDate ?? this.plannedEndDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      projectId: projectId ?? this.projectId,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      assignedUserName: assignedUserName ?? this.assignedUserName,
      dependencies: dependencies ?? this.dependencies,
      evidenceCount: evidenceCount ?? this.evidenceCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      children: children ?? this.children,
      taskType: taskType ?? this.taskType,
      priority: priority ?? this.priority,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      wbsCode: wbsCode ?? this.wbsCode,
      assignedTo: assignedTo ?? this.assignedTo,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      completedAt: completedAt ?? this.completedAt,
      evidenceAttachments: evidenceAttachments ?? this.evidenceAttachments,
    );
  }

  @override
  List<Object?> get props => [
    wbsId,
    parentWbsId,
    taskNameEN,
    taskNameTH,
    description,
    status,
    weightPercent,
    installationArea,
    acceptanceCriteria,
    plannedStartDate,
    actualStartDate,
    plannedEndDate,
    actualEndDate,
    projectId,
    assignedUserId,
    assignedUserName,
    dependencies,
    evidenceCount,
    createdAt,
    updatedAt,
    children,
    taskType,
    priority,
    progressPercentage,
    estimatedCost,
    actualCost,
    wbsCode,
    assignedTo,
    estimatedDuration,
    actualDuration,
    startDate,
    endDate,
    completedAt,
    evidenceAttachments,
  ];
}

/// Task status enumeration with all API-supported statuses
enum WbsTaskStatus {
  notStarted,
  inProgress,
  completed,
  blocked,
  onHold,
  cancelled,
  underReview,
  approved;

  String get displayName {
    switch (this) {
      case WbsTaskStatus.notStarted:
        return 'Not Started';
      case WbsTaskStatus.inProgress:
        return 'In Progress';
      case WbsTaskStatus.completed:
        return 'Completed';
      case WbsTaskStatus.blocked:
        return 'Blocked';
      case WbsTaskStatus.onHold:
        return 'On Hold';
      case WbsTaskStatus.cancelled:
        return 'Cancelled';
      case WbsTaskStatus.underReview:
        return 'Under Review';
      case WbsTaskStatus.approved:
        return 'Approved';
    }
  }
}

/// Task type enumeration
enum WbsTaskType {
  phase,
  deliverable,
  workPackage,
  activity;

  String get displayName {
    switch (this) {
      case WbsTaskType.phase:
        return 'Phase';
      case WbsTaskType.deliverable:
        return 'Deliverable';
      case WbsTaskType.workPackage:
        return 'Work Package';
      case WbsTaskType.activity:
        return 'Activity';
    }
  }
}

/// Task priority enumeration
enum WbsTaskPriority {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case WbsTaskPriority.low:
        return 'Low';
      case WbsTaskPriority.medium:
        return 'Medium';
      case WbsTaskPriority.high:
        return 'High';
      case WbsTaskPriority.critical:
        return 'Critical';
    }
  }
}

/// WBS attachment entity for evidence files
class WbsAttachment extends Equatable {
  const WbsAttachment({
    required this.id,
    required this.filename,
    required this.url,
    required this.uploadedAt,
    this.description,
    this.fileSize,
    this.fileType,
  });

  final String id;
  final String filename;
  final String url;
  final String? description;
  final int? fileSize;
  final WbsAttachmentType? fileType;
  final DateTime uploadedAt;

  factory WbsAttachment.fromJson(Map<String, dynamic> json) {
    return WbsAttachment(
      id: json['id'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      url: json['url'] as String? ?? '',
      description: json['description'] as String?,
      fileSize: json['file_size'] as int?,
      fileType: json['file_type'] != null
          ? WbsAttachmentType.values.firstWhere(
              (e) => e.name == json['file_type'],
              orElse: () => WbsAttachmentType.other,
            )
          : null,
      uploadedAt: DateTime.tryParse(json['uploaded_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'url': url,
      'description': description,
      'file_size': fileSize,
      'file_type': fileType?.name,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, filename, url, description, fileSize, fileType, uploadedAt];
}

/// Attachment file type enumeration
enum WbsAttachmentType {
  image,
  document,
  video,
  other;

  String get displayName {
    switch (this) {
      case WbsAttachmentType.image:
        return 'Image';
      case WbsAttachmentType.document:
        return 'Document';
      case WbsAttachmentType.video:
        return 'Video';
      case WbsAttachmentType.other:
        return 'Other';
    }
  }
}
