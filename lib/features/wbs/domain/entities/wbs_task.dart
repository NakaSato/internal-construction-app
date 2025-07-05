import 'package:equatable/equatable.dart';

/// Work Breakdown Structure task entity
/// Represents a hierarchical task in the solar PV installation WBS
class WbsTask extends Equatable {
  const WbsTask({
    required this.id,
    required this.wbsCode,
    required this.taskName,
    required this.projectId,
    required this.taskType,
    required this.status,
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.progressPercentage,
    required this.weight,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.parentTaskId,
    this.estimatedDuration,
    this.actualDuration,
    this.assignedTo,
    this.assignedTeam,
    this.estimatedCost,
    this.actualCost,
    this.deliverables = const [],
    this.acceptanceCriteria = const [],
    this.dependencies = const [],
    this.materialsRequired = const [],
    this.equipmentRequired = const [],
    this.safetyRequirements = const [],
    this.qualityStandards = const [],
    this.evidenceRequired = const [],
    this.evidenceAttachments = const [],
    this.notes,
    this.completedAt,
    this.completedBy,
    this.children = const [],
  });

  final String id;
  final String wbsCode;
  final String taskName;
  final String? description;
  final String projectId;
  final String? parentTaskId;
  final WbsTaskType taskType;
  final WbsTaskStatus status;
  final WbsTaskPriority priority;
  final DateTime startDate;
  final DateTime endDate;
  final int? estimatedDuration;
  final int? actualDuration;
  final int progressPercentage;
  final double weight;
  final String? assignedTo;
  final String? assignedTeam;
  final double? estimatedCost;
  final double? actualCost;
  final List<String> deliverables;
  final List<String> acceptanceCriteria;
  final List<String> dependencies;
  final List<String> materialsRequired;
  final List<String> equipmentRequired;
  final List<String> safetyRequirements;
  final List<String> qualityStandards;
  final List<String> evidenceRequired;
  final List<WbsAttachment> evidenceAttachments;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String? completedBy;
  final List<WbsTask> children;

  /// Check if task can be started based on dependencies
  bool get canStart {
    // Implementation would check if all prerequisite tasks are completed
    return status != WbsTaskStatus.blocked;
  }

  /// Check if task is currently blocking other tasks
  bool get isBlocking {
    return children.any((child) => child.status == WbsTaskStatus.blocked && child.dependencies.contains(id));
  }

  /// Check if task is overdue
  bool get isOverdue {
    if (status == WbsTaskStatus.completed) return false;
    return DateTime.now().isAfter(endDate);
  }

  /// Check if task is on schedule
  bool get isOnSchedule {
    if (status == WbsTaskStatus.completed) {
      return completedAt != null && !completedAt!.isAfter(endDate);
    }

    final now = DateTime.now();
    final totalDuration = endDate.difference(startDate).inDays;
    final elapsedDuration = now.difference(startDate).inDays;
    final expectedProgress = totalDuration > 0 ? (elapsedDuration / totalDuration * 100).clamp(0, 100) : 0;

    return progressPercentage >= expectedProgress - 10; // 10% tolerance
  }

  /// Get task status color
  WbsTaskStatusColor get statusColor {
    switch (status) {
      case WbsTaskStatus.notStarted:
        return WbsTaskStatusColor.grey;
      case WbsTaskStatus.inProgress:
        return isOnSchedule ? WbsTaskStatusColor.blue : WbsTaskStatusColor.orange;
      case WbsTaskStatus.completed:
        return WbsTaskStatusColor.green;
      case WbsTaskStatus.blocked:
        return WbsTaskStatusColor.red;
      case WbsTaskStatus.cancelled:
        return WbsTaskStatusColor.darkGrey;
    }
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

  /// Create WbsTask from JSON with snake_case field names (API format)
  factory WbsTask.fromJson(Map<String, dynamic> json) {
    return WbsTask(
      id: json['id'] as String,
      wbsCode: json['wbs_code'] as String? ?? '',
      taskName: json['task_name'] as String? ?? '',
      description: json['description'] as String?,
      projectId: json['project_id'] as String? ?? '',
      parentTaskId: json['parent_task_id'] as String?,
      taskType: parseTaskType(json['task_type'] as String?),
      status: parseTaskStatus(json['status'] as String?),
      priority: parseTaskPriority(json['priority'] as String?),
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? DateTime.now().add(const Duration(days: 7)),
      estimatedDuration: json['estimated_duration'] as int?,
      actualDuration: json['actual_duration'] as int?,
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      assignedTo: json['assigned_to'] as String?,
      assignedTeam: json['assigned_team'] as String?,
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble(),
      actualCost: (json['actual_cost'] as num?)?.toDouble(),
      deliverables: (json['deliverables'] as List<dynamic>?)?.cast<String>() ?? [],
      acceptanceCriteria: (json['acceptance_criteria'] as List<dynamic>?)?.cast<String>() ?? [],
      dependencies: (json['dependencies'] as List<dynamic>?)?.cast<String>() ?? [],
      materialsRequired: (json['materials_required'] as List<dynamic>?)?.cast<String>() ?? [],
      equipmentRequired: (json['equipment_required'] as List<dynamic>?)?.cast<String>() ?? [],
      safetyRequirements: (json['safety_requirements'] as List<dynamic>?)?.cast<String>() ?? [],
      qualityStandards: (json['quality_standards'] as List<dynamic>?)?.cast<String>() ?? [],
      evidenceRequired: (json['evidence_required'] as List<dynamic>?)?.cast<String>() ?? [],
      evidenceAttachments:
          (json['evidence_attachments'] as List<dynamic>?)
              ?.map((item) => WbsAttachment.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
      completedBy: json['completed_by'] as String?,
      children:
          (json['children'] as List<dynamic>?)
              ?.map((item) => WbsTask.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convert WbsTask to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wbs_code': wbsCode,
      'task_name': taskName,
      'description': description,
      'project_id': projectId,
      'parent_task_id': parentTaskId,
      'task_type': taskType.name,
      'status': status.name,
      'priority': priority.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'estimated_duration': estimatedDuration,
      'actual_duration': actualDuration,
      'progress_percentage': progressPercentage,
      'weight': weight,
      'assigned_to': assignedTo,
      'assigned_team': assignedTeam,
      'estimated_cost': estimatedCost,
      'actual_cost': actualCost,
      'deliverables': deliverables,
      'acceptance_criteria': acceptanceCriteria,
      'dependencies': dependencies,
      'materials_required': materialsRequired,
      'equipment_required': equipmentRequired,
      'safety_requirements': safetyRequirements,
      'quality_standards': qualityStandards,
      'evidence_required': evidenceRequired,
      'evidence_attachments': evidenceAttachments.map((e) => e.toJson()).toList(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'completed_by': completedBy,
      'children': children.map((e) => e.toJson()).toList(),
    };
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
      case 'cancelled':
        return WbsTaskStatus.cancelled;
      default:
        return WbsTaskStatus.notStarted;
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

  WbsTask copyWith({
    String? id,
    String? wbsCode,
    String? taskName,
    String? description,
    String? projectId,
    String? parentTaskId,
    WbsTaskType? taskType,
    WbsTaskStatus? status,
    WbsTaskPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    int? estimatedDuration,
    int? actualDuration,
    int? progressPercentage,
    double? weight,
    String? assignedTo,
    String? assignedTeam,
    double? estimatedCost,
    double? actualCost,
    List<String>? deliverables,
    List<String>? acceptanceCriteria,
    List<String>? dependencies,
    List<String>? materialsRequired,
    List<String>? equipmentRequired,
    List<String>? safetyRequirements,
    List<String>? qualityStandards,
    List<String>? evidenceRequired,
    List<WbsAttachment>? evidenceAttachments,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? completedBy,
    List<WbsTask>? children,
  }) {
    return WbsTask(
      id: id ?? this.id,
      wbsCode: wbsCode ?? this.wbsCode,
      taskName: taskName ?? this.taskName,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      taskType: taskType ?? this.taskType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      weight: weight ?? this.weight,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedTeam: assignedTeam ?? this.assignedTeam,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      deliverables: deliverables ?? this.deliverables,
      acceptanceCriteria: acceptanceCriteria ?? this.acceptanceCriteria,
      dependencies: dependencies ?? this.dependencies,
      materialsRequired: materialsRequired ?? this.materialsRequired,
      equipmentRequired: equipmentRequired ?? this.equipmentRequired,
      safetyRequirements: safetyRequirements ?? this.safetyRequirements,
      qualityStandards: qualityStandards ?? this.qualityStandards,
      evidenceRequired: evidenceRequired ?? this.evidenceRequired,
      evidenceAttachments: evidenceAttachments ?? this.evidenceAttachments,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      children: children ?? this.children,
    );
  }

  @override
  List<Object?> get props => [
    id,
    wbsCode,
    taskName,
    description,
    projectId,
    parentTaskId,
    taskType,
    status,
    priority,
    startDate,
    endDate,
    estimatedDuration,
    actualDuration,
    progressPercentage,
    weight,
    assignedTo,
    assignedTeam,
    estimatedCost,
    actualCost,
    deliverables,
    acceptanceCriteria,
    dependencies,
    materialsRequired,
    equipmentRequired,
    safetyRequirements,
    qualityStandards,
    evidenceRequired,
    evidenceAttachments,
    notes,
    createdAt,
    updatedAt,
    completedAt,
    completedBy,
    children,
  ];
}

/// WBS task types based on hierarchical structure
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

  String get description {
    switch (this) {
      case WbsTaskType.phase:
        return 'High-level project phases (Initiation, Planning, Execution, Monitoring, Closure)';
      case WbsTaskType.deliverable:
        return 'Major project deliverables or outcomes';
      case WbsTaskType.workPackage:
        return 'Specific work items that can be assigned and tracked';
      case WbsTaskType.activity:
        return 'Detailed activities within work packages';
    }
  }
}

/// WBS task status following the defined flow
enum WbsTaskStatus {
  notStarted,
  inProgress,
  completed,
  blocked,
  cancelled;

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
      case WbsTaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive {
    return this == WbsTaskStatus.inProgress || this == WbsTaskStatus.notStarted;
  }

  bool get isCompleted {
    return this == WbsTaskStatus.completed;
  }

  bool get canTransitionTo {
    switch (this) {
      case WbsTaskStatus.notStarted:
        return true; // Can transition to any state
      case WbsTaskStatus.inProgress:
        return true; // Can transition to any state
      case WbsTaskStatus.completed:
        return false; // Cannot transition from completed
      case WbsTaskStatus.blocked:
        return true; // Can be unblocked
      case WbsTaskStatus.cancelled:
        return false; // Cannot transition from cancelled
    }
  }
}

/// WBS task priority levels
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

  String get description {
    switch (this) {
      case WbsTaskPriority.low:
        return 'Tasks that can be delayed if necessary';
      case WbsTaskPriority.medium:
        return 'Standard priority tasks';
      case WbsTaskPriority.high:
        return 'Important tasks with tight deadlines';
      case WbsTaskPriority.critical:
        return 'Tasks that block project completion';
    }
  }

  int get sortOrder {
    switch (this) {
      case WbsTaskPriority.critical:
        return 4;
      case WbsTaskPriority.high:
        return 3;
      case WbsTaskPriority.medium:
        return 2;
      case WbsTaskPriority.low:
        return 1;
    }
  }
}

/// WBS task status colors for UI
enum WbsTaskStatusColor { grey, blue, green, orange, red, darkGrey }

/// Evidence attachment for WBS tasks
class WbsAttachment extends Equatable {
  const WbsAttachment({
    required this.id,
    required this.filename,
    required this.fileType,
    required this.fileSize,
    required this.url,
    required this.uploadedBy,
    required this.uploadedAt,
    this.thumbnailUrl,
    this.description,
  });

  final String id;
  final String filename;
  final WbsAttachmentType fileType;
  final int fileSize;
  final String url;
  final String? thumbnailUrl;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String? description;

  /// Get file size in human readable format
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Create WbsAttachment from JSON
  factory WbsAttachment.fromJson(Map<String, dynamic> json) {
    return WbsAttachment(
      id: json['id'] as String,
      filename: json['filename'] as String? ?? 'unknown',
      fileType: WbsAttachment.parseFileType(json['file_type'] as String?),
      fileSize: json['file_size'] as int? ?? 0,
      url: json['url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      uploadedBy: json['uploaded_by'] as String? ?? 'unknown',
      uploadedAt: DateTime.tryParse(json['uploaded_at'] as String? ?? '') ?? DateTime.now(),
      description: json['description'] as String?,
    );
  }

  /// Convert WbsAttachment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'file_type': fileType.name,
      'file_size': fileSize,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'uploaded_by': uploadedBy,
      'uploaded_at': uploadedAt.toIso8601String(),
      'description': description,
    };
  }

  /// Parse file type from string
  static WbsAttachmentType parseFileType(String? type) {
    switch (type?.toLowerCase()) {
      case 'image':
        return WbsAttachmentType.image;
      case 'document':
        return WbsAttachmentType.document;
      case 'video':
        return WbsAttachmentType.video;
      default:
        return WbsAttachmentType.document;
    }
  }

  /// Get file size in human readable format
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  List<Object?> get props => [id, filename, fileType, fileSize, url, thumbnailUrl, uploadedBy, uploadedAt, description];
}

/// Attachment file types
enum WbsAttachmentType {
  image,
  document,
  video;

  String get displayName {
    switch (this) {
      case WbsAttachmentType.image:
        return 'Image';
      case WbsAttachmentType.document:
        return 'Document';
      case WbsAttachmentType.video:
        return 'Video';
    }
  }

  List<String> get allowedExtensions {
    switch (this) {
      case WbsAttachmentType.image:
        return ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      case WbsAttachmentType.document:
        return ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'xls'];
      case WbsAttachmentType.video:
        return ['mp4', 'mov', 'avi', 'mkv', 'webm'];
    }
  }
}
