import '../entities/project_api_models.dart';

/// Enhanced repository interface for project management API operations
abstract class EnhancedProjectRepository {
  /// Get all projects with advanced filtering and pagination
  ///
  /// **🔒 Requires**: Any authenticated user
  ///
  /// Supports:
  /// - Advanced filtering, sorting, and field selection
  /// - Enhanced pagination capabilities
  /// - Dynamic filter expressions
  Future<ProjectsResponse> getAllProjects(ProjectsQuery query);

  /// Get project by ID with complete details
  ///
  /// **🔒 Requires**: Any authenticated user
  ///
  /// Returns detailed project information including:
  /// - Complete project data
  /// - Team assignments
  /// - Technical specifications
  /// - Progress tracking
  Future<EnhancedProject> getProjectById(String id);

  /// Create a new project
  ///
  /// **🔒 Requires**: Admin/Manager role
  ///
  /// Creates a new solar installation project with:
  /// - Basic project information
  /// - Technical specifications
  /// - Team assignments
  /// - Initial status
  Future<EnhancedProject> createProject(Map<String, dynamic> projectData);

  /// Update an existing project
  ///
  /// **🔒 Requires**: Admin/Manager role
  ///
  /// Updates project information including:
  /// - Project details
  /// - Status updates
  /// - Progress tracking
  /// - Team reassignments
  Future<EnhancedProject> updateProject(
    String id,
    Map<String, dynamic> projectData,
  );

  /// Delete a project
  ///
  /// **🔒 Requires**: Admin only
  ///
  /// Permanently removes a project and all associated data
  Future<void> deleteProject(String id);

  /// Get projects filtered by manager
  ///
  /// **🔒 Requires**: Any authenticated user
  ///
  /// Returns projects assigned to a specific manager
  Future<ProjectsResponse> getProjectsByManager(
    String managerId,
    ProjectsQuery query,
  );

  /// Get projects filtered by status
  ///
  /// **🔒 Requires**: Any authenticated user
  ///
  /// Returns projects with specific status (Active, Completed, etc.)
  Future<ProjectsResponse> getProjectsByStatus(
    String status,
    ProjectsQuery query,
  );

  /// Search projects with text query
  ///
  /// **🔒 Requires**: Any authenticated user
  ///
  /// Searches projects by name, address, client info, or other text fields
  Future<ProjectsResponse> searchProjects(
    String searchQuery,
    ProjectsQuery query,
  );

  /// Get project statistics and analytics
  ///
  /// **🔒 Requires**: Manager/Admin role
  ///
  /// Returns aggregated data for dashboard and reporting
  Future<Map<String, dynamic>> getProjectStatistics();

  /// Get projects near a location
  ///
  /// **🔒 Requires**: Any authenticated user
  ///
  /// Returns projects within a specified radius of coordinates
  Future<ProjectsResponse> getProjectsNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
    ProjectsQuery query,
  );
}

/// Use cases for project management operations
abstract class ProjectUseCases {
  /// Get filtered and paginated projects list
  Future<ProjectsResponse> getProjects(ProjectsQuery query);

  /// Get single project with full details
  Future<EnhancedProject> getProject(String id);

  /// Create new project with validation
  Future<EnhancedProject> createProject(Map<String, dynamic> projectData);

  /// Update project with validation
  Future<EnhancedProject> updateProject(
    String id,
    Map<String, dynamic> projectData,
  );

  /// Delete project with permission check
  Future<void> deleteProject(String id);

  /// Search projects with advanced filters
  Future<ProjectsResponse> searchProjects(String query, ProjectsQuery filters);

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats();
}

/// Data transfer objects for API requests
class CreateProjectRequest {
  const CreateProjectRequest({
    required this.projectName,
    required this.address,
    required this.clientInfo,
    required this.startDate,
    required this.estimatedEndDate,
    this.managerId,
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

  final String projectName;
  final String address;
  final String clientInfo;
  final DateTime startDate;
  final DateTime estimatedEndDate;
  final String? managerId;
  final String? team;
  final String? connectionType;
  final String? connectionNotes;
  final double? totalCapacityKw;
  final int? pvModuleCount;
  final Map<String, int>? equipmentDetails;
  final double? ftsValue;
  final double? revenueValue;
  final double? pqmValue;
  final Map<String, double>? locationCoordinates;

  Map<String, dynamic> toJson() {
    return {
      'projectName': projectName,
      'address': address,
      'clientInfo': clientInfo,
      'startDate': startDate.toIso8601String(),
      'estimatedEndDate': estimatedEndDate.toIso8601String(),
      if (managerId != null) 'managerId': managerId,
      if (team != null) 'team': team,
      if (connectionType != null) 'connectionType': connectionType,
      if (connectionNotes != null) 'connectionNotes': connectionNotes,
      if (totalCapacityKw != null) 'totalCapacityKw': totalCapacityKw,
      if (pvModuleCount != null) 'pvModuleCount': pvModuleCount,
      if (equipmentDetails != null) 'equipmentDetails': equipmentDetails,
      if (ftsValue != null) 'ftsValue': ftsValue,
      if (revenueValue != null) 'revenueValue': revenueValue,
      if (pqmValue != null) 'pqmValue': pqmValue,
      if (locationCoordinates != null)
        'locationCoordinates': locationCoordinates,
    };
  }
}

class UpdateProjectRequest {
  const UpdateProjectRequest({
    this.projectName,
    this.address,
    this.clientInfo,
    this.status,
    this.startDate,
    this.estimatedEndDate,
    this.actualEndDate,
    this.managerId,
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

  final String? projectName;
  final String? address;
  final String? clientInfo;
  final String? status;
  final DateTime? startDate;
  final DateTime? estimatedEndDate;
  final DateTime? actualEndDate;
  final String? managerId;
  final String? team;
  final String? connectionType;
  final String? connectionNotes;
  final double? totalCapacityKw;
  final int? pvModuleCount;
  final Map<String, int>? equipmentDetails;
  final double? ftsValue;
  final double? revenueValue;
  final double? pqmValue;
  final Map<String, double>? locationCoordinates;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (projectName != null) json['projectName'] = projectName;
    if (address != null) json['address'] = address;
    if (clientInfo != null) json['clientInfo'] = clientInfo;
    if (status != null) json['status'] = status;
    if (startDate != null) json['startDate'] = startDate!.toIso8601String();
    if (estimatedEndDate != null) {
      json['estimatedEndDate'] = estimatedEndDate!.toIso8601String();
    }
    if (actualEndDate != null) {
      json['actualEndDate'] = actualEndDate!.toIso8601String();
    }
    if (managerId != null) json['managerId'] = managerId;
    if (team != null) json['team'] = team;
    if (connectionType != null) json['connectionType'] = connectionType;
    if (connectionNotes != null) json['connectionNotes'] = connectionNotes;
    if (totalCapacityKw != null) json['totalCapacityKw'] = totalCapacityKw;
    if (pvModuleCount != null) json['pvModuleCount'] = pvModuleCount;
    if (equipmentDetails != null) json['equipmentDetails'] = equipmentDetails;
    if (ftsValue != null) json['ftsValue'] = ftsValue;
    if (revenueValue != null) json['revenueValue'] = revenueValue;
    if (pqmValue != null) json['pqmValue'] = pqmValue;
    if (locationCoordinates != null) {
      json['locationCoordinates'] = locationCoordinates;
    }

    return json;
  }
}
