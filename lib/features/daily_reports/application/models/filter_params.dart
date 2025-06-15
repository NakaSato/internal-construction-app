import 'package:equatable/equatable.dart';

/// Filter parameters for daily reports queries
class DailyReportsFilterParams extends Equatable {
  final String? projectId;
  final String? technicianId;
  final DateTime? startDate;
  final DateTime? endDate;
  final DailyReportsFilterStatus? status;
  final int pageSize;
  final int pageNumber;
  final String? sortBy;
  final bool sortDescending;

  const DailyReportsFilterParams({
    this.projectId,
    this.technicianId,
    this.startDate,
    this.endDate,
    this.status,
    this.pageSize = 10,
    this.pageNumber = 1,
    this.sortBy = 'reportDate',
    this.sortDescending = true,
  });

  /// Get query parameters for API call
  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {
      'pageSize': pageSize.toString(),
      'pageNumber': pageNumber.toString(),
    };

    if (projectId != null) {
      params['projectId'] = projectId!;
    }

    if (technicianId != null) {
      params['technicianId'] = technicianId!;
    }

    if (startDate != null) {
      params['startDate'] = startDate!.toIso8601String();
    }

    if (endDate != null) {
      params['endDate'] = endDate!.toIso8601String();
    }

    if (status != null) {
      params['status'] = status!.name;
    }

    if (sortBy != null) {
      params['sortBy'] = sortBy!;
      params['sortDescending'] = sortDescending.toString();
    }

    return params;
  }

  /// Creates a copy with the given fields replaced
  DailyReportsFilterParams copyWith({
    String? projectId,
    String? technicianId,
    DateTime? startDate,
    DateTime? endDate,
    DailyReportsFilterStatus? status,
    int? pageSize,
    int? pageNumber,
    String? sortBy,
    bool? sortDescending,
  }) {
    return DailyReportsFilterParams(
      projectId: projectId ?? this.projectId,
      technicianId: technicianId ?? this.technicianId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      pageSize: pageSize ?? this.pageSize,
      pageNumber: pageNumber ?? this.pageNumber,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }

  /// Empty filter params
  static const empty = DailyReportsFilterParams();

  /// Creates a filter for only one project
  static DailyReportsFilterParams forProject(String projectId) {
    return DailyReportsFilterParams(projectId: projectId);
  }

  /// Creates a filter for only reports by a specific technician
  static DailyReportsFilterParams forTechnician(String technicianId) {
    return DailyReportsFilterParams(technicianId: technicianId);
  }

  /// Creates a filter for a date range
  static DailyReportsFilterParams forDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return DailyReportsFilterParams(startDate: startDate, endDate: endDate);
  }

  @override
  List<Object?> get props => [
    projectId,
    technicianId,
    startDate,
    endDate,
    status,
    pageSize,
    pageNumber,
    sortBy,
    sortDescending,
  ];
}

/// Filter status options for daily reports
enum DailyReportsFilterStatus { draft, submitted, approved, rejected, all }
