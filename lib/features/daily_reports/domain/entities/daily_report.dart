import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Daily Report entity for solar installation projects
class DailyReport extends Equatable {
  const DailyReport({
    required this.reportId,
    required this.projectId,
    required this.technicianId,
    required this.reportDate,
    required this.status,
    required this.workStartTime,
    required this.workEndTime,
    required this.weatherConditions,
    required this.overallNotes,
    required this.safetyNotes,
    required this.delaysOrIssues,
    required this.photosCount,
    required this.createdAt,
    required this.updatedAt,
    this.project,
    this.technician,
    this.workProgressItems = const [],
    this.personnelLogs = const [],
    this.materialUsage = const [],
    this.equipmentLogs = const [],
    this.approverComments,
    this.rejectionReason,
    this.submittedAt,
    this.approvedAt,
    this.rejectedAt,
    this.location,
  });

  final String reportId;
  final String projectId;
  final String technicianId;
  final DateTime reportDate;
  final DailyReportStatus status;
  final String workStartTime;
  final String workEndTime;
  final String weatherConditions;
  final String overallNotes;
  final String safetyNotes;
  final String delaysOrIssues;
  final int photosCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProjectInfo? project;
  final TechnicianInfo? technician;
  final List<WorkProgressItem> workProgressItems;
  final List<PersonnelLog> personnelLogs;
  final List<MaterialUsage> materialUsage;
  final List<EquipmentLog> equipmentLogs;
  final String? approverComments;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final LocationInfo? location;

  @override
  List<Object?> get props => [
    reportId,
    projectId,
    technicianId,
    reportDate,
    status,
    workStartTime,
    workEndTime,
    weatherConditions,
    overallNotes,
    safetyNotes,
    delaysOrIssues,
    photosCount,
    createdAt,
    updatedAt,
    project,
    technician,
    workProgressItems,
    personnelLogs,
    materialUsage,
    equipmentLogs,
    approverComments,
    rejectionReason,
    submittedAt,
    approvedAt,
    rejectedAt,
    location,
  ];

  DailyReport copyWith({
    String? reportId,
    String? projectId,
    String? technicianId,
    DateTime? reportDate,
    DailyReportStatus? status,
    String? workStartTime,
    String? workEndTime,
    String? weatherConditions,
    String? overallNotes,
    String? safetyNotes,
    String? delaysOrIssues,
    int? photosCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProjectInfo? project,
    TechnicianInfo? technician,
    List<WorkProgressItem>? workProgressItems,
    List<PersonnelLog>? personnelLogs,
    List<MaterialUsage>? materialUsage,
    List<EquipmentLog>? equipmentLogs,
    String? approverComments,
    String? rejectionReason,
    DateTime? submittedAt,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    LocationInfo? location,
  }) {
    return DailyReport(
      reportId: reportId ?? this.reportId,
      projectId: projectId ?? this.projectId,
      technicianId: technicianId ?? this.technicianId,
      reportDate: reportDate ?? this.reportDate,
      status: status ?? this.status,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      weatherConditions: weatherConditions ?? this.weatherConditions,
      overallNotes: overallNotes ?? this.overallNotes,
      safetyNotes: safetyNotes ?? this.safetyNotes,
      delaysOrIssues: delaysOrIssues ?? this.delaysOrIssues,
      photosCount: photosCount ?? this.photosCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      project: project ?? this.project,
      technician: technician ?? this.technician,
      workProgressItems: workProgressItems ?? this.workProgressItems,
      personnelLogs: personnelLogs ?? this.personnelLogs,
      materialUsage: materialUsage ?? this.materialUsage,
      equipmentLogs: equipmentLogs ?? this.equipmentLogs,
      approverComments: approverComments ?? this.approverComments,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      location: location ?? this.location,
    );
  }
}

/// Daily Report Status enum
enum DailyReportStatus {
  draft(1, 'Draft'),
  submitted(2, 'Submitted'),
  approved(3, 'Approved'),
  rejected(4, 'Rejected');

  const DailyReportStatus(this.value, this.displayName);

  final int value;
  final String displayName;

  static DailyReportStatus fromValue(int value) {
    return DailyReportStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => draft,
    );
  }

  static DailyReportStatus fromName(String name) {
    return DailyReportStatus.values.firstWhere(
      (status) => status.name == name.toLowerCase(),
      orElse: () => draft,
    );
  }
}

/// Extension for DailyReportStatus
extension DailyReportStatusX on DailyReportStatus {
  Color get color {
    switch (this) {
      case DailyReportStatus.draft:
        return Colors.grey;
      case DailyReportStatus.submitted:
        return Colors.blue;
      case DailyReportStatus.approved:
        return Colors.green;
      case DailyReportStatus.rejected:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case DailyReportStatus.draft:
        return Icons.edit;
      case DailyReportStatus.submitted:
        return Icons.send;
      case DailyReportStatus.approved:
        return Icons.check_circle;
      case DailyReportStatus.rejected:
        return Icons.cancel;
    }
  }

  List<String> get nextActions {
    switch (this) {
      case DailyReportStatus.draft:
        return ['Submit', 'Update', 'Delete'];
      case DailyReportStatus.submitted:
        return ['Approve', 'Reject'];
      case DailyReportStatus.approved:
        return ['View only'];
      case DailyReportStatus.rejected:
        return ['Update', 'Resubmit'];
    }
  }
}

/// Project information
class ProjectInfo extends Equatable {
  const ProjectInfo({
    required this.projectId,
    required this.projectName,
    required this.address,
    this.clientInfo,
  });

  final String projectId;
  final String projectName;
  final String address;
  final String? clientInfo;

  @override
  List<Object?> get props => [projectId, projectName, address, clientInfo];
}

/// Technician information
class TechnicianInfo extends Equatable {
  const TechnicianInfo({
    required this.userId,
    required this.fullName,
    required this.email,
    this.username,
    this.roleName,
  });

  final String userId;
  final String fullName;
  final String email;
  final String? username;
  final String? roleName;

  @override
  List<Object?> get props => [userId, fullName, email, username, roleName];
}

/// Work Progress Item
class WorkProgressItem extends Equatable {
  const WorkProgressItem({
    required this.workProgressId,
    required this.reportId,
    required this.taskDescription,
    required this.hoursWorked,
    required this.percentageComplete,
    required this.notes,
    required this.createdAt,
  });

  final String workProgressId;
  final String reportId;
  final String taskDescription;
  final double hoursWorked;
  final int percentageComplete;
  final String notes;
  final DateTime createdAt;

  @override
  List<Object> get props => [
    workProgressId,
    reportId,
    taskDescription,
    hoursWorked,
    percentageComplete,
    notes,
    createdAt,
  ];
}

/// Personnel Log
class PersonnelLog extends Equatable {
  const PersonnelLog({
    required this.personnelLogId,
    required this.reportId,
    required this.personnelName,
    required this.role,
    required this.hoursWorked,
    required this.overtimeHours,
    required this.notes,
    required this.createdAt,
  });

  final String personnelLogId;
  final String reportId;
  final String personnelName;
  final String role;
  final double hoursWorked;
  final double overtimeHours;
  final String notes;
  final DateTime createdAt;

  @override
  List<Object> get props => [
    personnelLogId,
    reportId,
    personnelName,
    role,
    hoursWorked,
    overtimeHours,
    notes,
    createdAt,
  ];
}

/// Material Usage
class MaterialUsage extends Equatable {
  const MaterialUsage({
    required this.materialUsageId,
    required this.reportId,
    required this.materialName,
    required this.quantityUsed,
    required this.unit,
    required this.notes,
    required this.createdAt,
  });

  final String materialUsageId;
  final String reportId;
  final String materialName;
  final int quantityUsed;
  final String unit;
  final String notes;
  final DateTime createdAt;

  @override
  List<Object> get props => [
    materialUsageId,
    reportId,
    materialName,
    quantityUsed,
    unit,
    notes,
    createdAt,
  ];
}

/// Equipment Log
class EquipmentLog extends Equatable {
  const EquipmentLog({
    required this.equipmentLogId,
    required this.reportId,
    required this.equipmentName,
    required this.usageHours,
    required this.condition,
    required this.notes,
    required this.createdAt,
  });

  final String equipmentLogId;
  final String reportId;
  final String equipmentName;
  final double usageHours;
  final String condition;
  final String notes;
  final DateTime createdAt;

  @override
  List<Object> get props => [
    equipmentLogId,
    reportId,
    equipmentName,
    usageHours,
    condition,
    notes,
    createdAt,
  ];
}

/// Location information for the report
class LocationInfo extends Equatable {
  const LocationInfo({
    required this.latitude,
    required this.longitude,
    this.address,
    this.timestamp,
  });

  final double latitude;
  final double longitude;
  final String? address;
  final DateTime? timestamp;

  @override
  List<Object?> get props => [latitude, longitude, address, timestamp];
}
