import 'package:equatable/equatable.dart';

/// Enhanced Project Manager entity for API responses
class ProjectManager extends Equatable {
  const ProjectManager({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
  });

  final String userId;
  final String username;
  final String fullName;
  final String email;

  factory ProjectManager.fromJson(Map<String, dynamic> json) {
    return ProjectManager(
      userId: json['userId'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'email': email,
    };
  }

  @override
  List<Object?> get props => [userId, username, fullName, email];
}

/// Equipment details for solar projects
class EquipmentDetails extends Equatable {
  const EquipmentDetails({
    this.inverter125kw = 0,
    this.inverter80kw = 0,
    this.inverter60kw = 0,
    this.inverter40kw = 0,
  });

  final int inverter125kw;
  final int inverter80kw;
  final int inverter60kw;
  final int inverter40kw;

  factory EquipmentDetails.fromJson(Map<String, dynamic> json) {
    return EquipmentDetails(
      inverter125kw: json['inverter125kw'] as int? ?? 0,
      inverter80kw: json['inverter80kw'] as int? ?? 0,
      inverter60kw: json['inverter60kw'] as int? ?? 0,
      inverter40kw: json['inverter40kw'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inverter125kw': inverter125kw,
      'inverter80kw': inverter80kw,
      'inverter60kw': inverter60kw,
      'inverter40kw': inverter40kw,
    };
  }

  /// Get total inverter count
  int get totalInverters => inverter125kw + inverter80kw + inverter60kw + inverter40kw;

  /// Get total inverter capacity in kW
  double get totalCapacity => 
      (inverter125kw * 125) + 
      (inverter80kw * 80) + 
      (inverter60kw * 60) + 
      (inverter40kw * 40);

  @override
  List<Object?> get props => [inverter125kw, inverter80kw, inverter60kw, inverter40kw];
}

/// Location coordinates for projects
class LocationCoordinates extends Equatable {
  const LocationCoordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) {
    return LocationCoordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Enhanced Project entity matching the API specification
class EnhancedProject extends Equatable {
  const EnhancedProject({
    required this.projectId,
    required this.projectName,
    required this.address,
    required this.clientInfo,
    required this.status,
    required this.startDate,
    required this.estimatedEndDate,
    this.actualEndDate,
    required this.createdAt,
    required this.updatedAt,
    this.projectManager,
    this.taskCount = 0,
    this.completedTaskCount = 0,
    this.team,
    this.connectionType,
    this.connectionNotes,
    this.totalCapacityKw,
    this.pvModuleCount,
    this.equipmentDetails,
    this.ftsValue,
    this.revenueValue,
    this.pqmValue,
    this.locationCoordinates,
  });

  final String projectId;
  final String projectName;
  final String address;
  final String clientInfo;
  final String status;
  final DateTime startDate;
  final DateTime estimatedEndDate;
  final DateTime? actualEndDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProjectManager? projectManager;
  final int taskCount;
  final int completedTaskCount;
  final String? team;
  final String? connectionType;
  final String? connectionNotes;
  final double? totalCapacityKw;
  final int? pvModuleCount;
  final EquipmentDetails? equipmentDetails;
  final double? ftsValue;
  final double? revenueValue;
  final double? pqmValue;
  final LocationCoordinates? locationCoordinates;

  factory EnhancedProject.fromJson(Map<String, dynamic> json) {
    return EnhancedProject(
      projectId: json['projectId'] as String,
      projectName: json['projectName'] as String,
      address: json['address'] as String,
      clientInfo: json['clientInfo'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      estimatedEndDate: DateTime.parse(json['estimatedEndDate'] as String),
      actualEndDate: json['actualEndDate'] != null 
          ? DateTime.parse(json['actualEndDate'] as String) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      projectManager: json['projectManager'] != null
          ? ProjectManager.fromJson(json['projectManager'] as Map<String, dynamic>)
          : null,
      taskCount: json['taskCount'] as int? ?? 0,
      completedTaskCount: json['completedTaskCount'] as int? ?? 0,
      team: json['team'] as String?,
      connectionType: json['connectionType'] as String?,
      connectionNotes: json['connectionNotes'] as String?,
      totalCapacityKw: (json['totalCapacityKw'] as num?)?.toDouble(),
      pvModuleCount: json['pvModuleCount'] as int?,
      equipmentDetails: json['equipmentDetails'] != null
          ? EquipmentDetails.fromJson(json['equipmentDetails'] as Map<String, dynamic>)
          : null,
      ftsValue: (json['ftsValue'] as num?)?.toDouble(),
      revenueValue: (json['revenueValue'] as num?)?.toDouble(),
      pqmValue: (json['pqmValue'] as num?)?.toDouble(),
      locationCoordinates: json['locationCoordinates'] != null
          ? LocationCoordinates.fromJson(json['locationCoordinates'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'address': address,
      'clientInfo': clientInfo,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'estimatedEndDate': estimatedEndDate.toIso8601String(),
      'actualEndDate': actualEndDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'projectManager': projectManager?.toJson(),
      'taskCount': taskCount,
      'completedTaskCount': completedTaskCount,
      'team': team,
      'connectionType': connectionType,
      'connectionNotes': connectionNotes,
      'totalCapacityKw': totalCapacityKw,
      'pvModuleCount': pvModuleCount,
      'equipmentDetails': equipmentDetails?.toJson(),
      'ftsValue': ftsValue,
      'revenueValue': revenueValue,
      'pqmValue': pqmValue,
      'locationCoordinates': locationCoordinates?.toJson(),
    };
  }

  /// Calculate completion percentage
  double get completionPercentage {
    if (taskCount == 0) return 0.0;
    return (completedTaskCount / taskCount) * 100;
  }

  /// Check if project is active
  bool get isActive => status.toLowerCase() == 'active';

  /// Check if project is completed
  bool get isCompleted => status.toLowerCase() == 'completed' || actualEndDate != null;

  /// Get days remaining until estimated end date
  int get daysRemaining {
    if (isCompleted) return 0;
    final now = DateTime.now();
    return estimatedEndDate.difference(now).inDays;
  }

  /// Check if project is overdue
  bool get isOverdue {
    if (isCompleted) return false;
    return DateTime.now().isAfter(estimatedEndDate);
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
    createdAt,
    updatedAt,
    projectManager,
    taskCount,
    completedTaskCount,
    team,
    connectionType,
    connectionNotes,
    totalCapacityKw,
    pvModuleCount,
    equipmentDetails,
    ftsValue,
    revenueValue,
    pqmValue,
    locationCoordinates,
  ];
}

/// Paginated response for projects API
class ProjectsResponse extends Equatable {
  const ProjectsResponse({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
    this.metadata,
  });

  final List<EnhancedProject> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final Map<String, dynamic>? metadata;

  factory ProjectsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ProjectsResponse(
      items: (data['items'] as List)
          .map((item) => EnhancedProject.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: data['totalCount'] as int,
      pageNumber: data['pageNumber'] as int,
      pageSize: data['pageSize'] as int,
      totalPages: data['totalPages'] as int,
      hasPreviousPage: data['hasPreviousPage'] as bool,
      hasNextPage: data['hasNextPage'] as bool,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    items,
    totalCount,
    pageNumber,
    pageSize,
    totalPages,
    hasPreviousPage,
    hasNextPage,
    metadata,
  ];
}

/// Query parameters for projects API
class ProjectsQuery extends Equatable {
  const ProjectsQuery({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.managerId,
    this.status,
    this.sortBy,
    this.sortOrder,
    this.filter,
    this.fields,
  });

  final int pageNumber;
  final int pageSize;
  final String? managerId;
  final String? status;
  final String? sortBy;
  final String? sortOrder;
  final String? filter;
  final String? fields;

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    if (managerId != null) params['managerId'] = managerId;
    if (status != null) params['status'] = status;
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;
    if (filter != null) params['filter'] = filter;
    if (fields != null) params['fields'] = fields;

    return params;
  }

  ProjectsQuery copyWith({
    int? pageNumber,
    int? pageSize,
    String? managerId,
    String? status,
    String? sortBy,
    String? sortOrder,
    String? filter,
    String? fields,
  }) {
    return ProjectsQuery(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      managerId: managerId ?? this.managerId,
      status: status ?? this.status,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      filter: filter ?? this.filter,
      fields: fields ?? this.fields,
    );
  }

  @override
  List<Object?> get props => [
    pageNumber,
    pageSize,
    managerId,
    status,
    sortBy,
    sortOrder,
    filter,
    fields,
  ];
}
