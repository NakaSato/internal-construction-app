import 'package:equatable/equatable.dart';
import '../../../authentication/domain/entities/user.dart';
import 'project.dart';

/// Extended project entity specifically for solar projects
/// This includes all the API fields mentioned in the UI requirements
class SolarProject extends Equatable {
  const SolarProject({
    required this.projectId,
    required this.projectName,
    required this.address,
    required this.clientInfo,
    required this.status,
    required this.startDate,
    required this.estimatedEndDate,
    this.actualEndDate,
    this.projectManagerId,
    this.projectManager,
    this.taskCount = 0,
    this.completedTaskCount = 0,
    this.imageUrl,

    // Solar-specific technical fields
    this.totalCapacityKw,
    this.pvModuleCount,
    this.connectionType,
    this.connectionNotes,

    // Equipment fields
    this.inverter125Kw = 0,
    this.inverter80Kw = 0,
    this.inverter60Kw = 0,
    this.inverter40Kw = 0,

    // Financial fields
    this.ftsValue,
    this.revenueValue,
    this.pqmValue,

    // Location fields
    this.latitude,
    this.longitude,

    // Metadata
    this.createdAt,
    this.updatedAt,
    this.description = '',
  });

  // Core project fields
  final String projectId;
  final String projectName;
  final String address;
  final String clientInfo;
  final String status;
  final DateTime startDate;
  final DateTime estimatedEndDate;
  final DateTime? actualEndDate;
  final String? projectManagerId;
  final User? projectManager;
  final int taskCount;
  final int completedTaskCount;
  final String? imageUrl;
  final String description;

  // Solar-specific technical fields
  final double? totalCapacityKw;
  final int? pvModuleCount;
  final String? connectionType;
  final String? connectionNotes;

  // Equipment fields
  final int inverter125Kw;
  final int inverter80Kw;
  final int inverter60Kw;
  final int inverter40Kw;

  // Financial fields
  final double? ftsValue;
  final double? revenueValue;
  final double? pqmValue;

  // Location fields
  final double? latitude;
  final double? longitude;

  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Legacy getters for backward compatibility
  String get id => projectId;
  String get name => projectName;

  /// Calculate completion percentage based on tasks
  int get completionPercentage {
    if (taskCount == 0) return 0;
    return ((completedTaskCount / taskCount) * 100).round();
  }

  /// Get total project value (sum of all financial values)
  double get totalProjectValue {
    final fts = ftsValue ?? 0.0;
    final revenue = revenueValue ?? 0.0;
    final pqm = pqmValue ?? 0.0;
    return fts + revenue + pqm;
  }

  /// Get formatted coordinates string
  String get coordinatesString {
    if (latitude == null || longitude == null) return 'Not Set';
    return 'Lat: ${latitude!.toStringAsFixed(4)}, Lon: ${longitude!.toStringAsFixed(4)}';
  }

  /// Get total inverter count
  int get totalInverters {
    return inverter125Kw + inverter80Kw + inverter60Kw + inverter40Kw;
  }

  /// Check if project is overdue
  bool get isOverdue {
    if (actualEndDate != null) return false; // Project is completed
    return estimatedEndDate.isBefore(DateTime.now());
  }

  /// Convert to legacy Project entity for backward compatibility
  Project toProject() {
    return Project(
      projectId: projectId,
      projectName: projectName,
      address: address,
      clientInfo: clientInfo,
      status: status,
      startDate: startDate,
      estimatedEndDate: estimatedEndDate,
      actualEndDate: actualEndDate,
      projectManager: projectManager,
      taskCount: taskCount,
      completedTaskCount: completedTaskCount,
      imageUrl: imageUrl,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create a copy with updated values
  SolarProject copyWith({
    String? projectId,
    String? projectName,
    String? address,
    String? clientInfo,
    String? status,
    DateTime? startDate,
    DateTime? estimatedEndDate,
    DateTime? actualEndDate,
    String? projectManagerId,
    User? projectManager,
    int? taskCount,
    int? completedTaskCount,
    String? imageUrl,
    String? description,
    double? totalCapacityKw,
    int? pvModuleCount,
    String? connectionType,
    String? connectionNotes,
    int? inverter125Kw,
    int? inverter80Kw,
    int? inverter60Kw,
    int? inverter40Kw,
    double? ftsValue,
    double? revenueValue,
    double? pqmValue,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SolarProject(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      address: address ?? this.address,
      clientInfo: clientInfo ?? this.clientInfo,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      estimatedEndDate: estimatedEndDate ?? this.estimatedEndDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      projectManagerId: projectManagerId ?? this.projectManagerId,
      projectManager: projectManager ?? this.projectManager,
      taskCount: taskCount ?? this.taskCount,
      completedTaskCount: completedTaskCount ?? this.completedTaskCount,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      totalCapacityKw: totalCapacityKw ?? this.totalCapacityKw,
      pvModuleCount: pvModuleCount ?? this.pvModuleCount,
      connectionType: connectionType ?? this.connectionType,
      connectionNotes: connectionNotes ?? this.connectionNotes,
      inverter125Kw: inverter125Kw ?? this.inverter125Kw,
      inverter80Kw: inverter80Kw ?? this.inverter80Kw,
      inverter60Kw: inverter60Kw ?? this.inverter60Kw,
      inverter40Kw: inverter40Kw ?? this.inverter40Kw,
      ftsValue: ftsValue ?? this.ftsValue,
      revenueValue: revenueValue ?? this.revenueValue,
      pqmValue: pqmValue ?? this.pqmValue,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    address,
    clientInfo,
    status,
    startDate,
    estimatedEndDate,
    actualEndDate,
    projectManagerId,
    projectManager,
    taskCount,
    completedTaskCount,
    imageUrl,
    description,
    totalCapacityKw,
    pvModuleCount,
    connectionType,
    connectionNotes,
    inverter125Kw,
    inverter80Kw,
    inverter60Kw,
    inverter40Kw,
    ftsValue,
    revenueValue,
    pqmValue,
    latitude,
    longitude,
    createdAt,
    updatedAt,
  ];
}
