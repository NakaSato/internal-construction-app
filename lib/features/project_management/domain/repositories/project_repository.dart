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
