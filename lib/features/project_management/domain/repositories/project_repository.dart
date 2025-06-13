import '../entities/project.dart';

/// Repository interface for project management operations
abstract class ProjectRepository {
  /// Get all projects
  Future<List<Project>> getAllProjects();

  /// Get projects by status
  Future<List<Project>> getProjectsByStatus(ProjectStatus status);

  /// Get project by ID
  Future<Project?> getProjectById(String id);

  /// Create a new project
  Future<Project> createProject(Project project);

  /// Update an existing project
  Future<Project> updateProject(Project project);

  /// Delete a project
  Future<void> deleteProject(String id);

  /// Search projects by name or description
  Future<List<Project>> searchProjects(String query);

  /// Get projects assigned to a user
  Future<List<Project>> getProjectsByUserId(String userId);
}
