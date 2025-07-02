import 'package:injectable/injectable.dart';
import '../../domain/entities/project_api_models.dart';
import '../../domain/repositories/project_repository.dart';

/// Mock implementation of the enhanced project repository for testing and development
@Injectable(
  as: EnhancedProjectRepository,
  env: [Environment.dev, Environment.test],
)
class MockProjectRepository implements EnhancedProjectRepository {
  const MockProjectRepository();

  @override
  Future<ProjectsResponse> getProjectsNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
    ProjectsQuery query,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // For mock: return all projects within a fake radius (just return all for now)
    final filteredProjects = _mockProjects.where((project) {
      // If locationCoordinates is present, do a simple distance check (mocked)
      if (project.locationCoordinates != null) {
        // In a real implementation, calculate distance using Haversine formula
        // Here, just return all for demonstration
        return true;
      }
      return false;
    }).toList();

    return ProjectsResponse(
      items: filteredProjects,
      totalCount: filteredProjects.length,
      pageNumber: query.pageNumber,
      pageSize: query.pageSize,
      totalPages: (filteredProjects.length / query.pageSize).ceil(),
      hasPreviousPage: query.pageNumber > 1,
      hasNextPage:
          query.pageNumber < (filteredProjects.length / query.pageSize).ceil(),
    );
  }

  @override
  Future<ProjectsResponse> getAllProjects(ProjectsQuery query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return ProjectsResponse(
      items: _mockProjects,
      totalCount: _mockProjects.length,
      pageNumber: query.pageNumber,
      pageSize: query.pageSize,
      totalPages: (_mockProjects.length / query.pageSize).ceil(),
      hasPreviousPage: query.pageNumber > 1,
      hasNextPage:
          query.pageNumber < (_mockProjects.length / query.pageSize).ceil(),
    );
  }

  @override
  Future<EnhancedProject> getProjectById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _mockProjects.firstWhere((project) => project.projectId == id);
    } catch (e) {
      throw Exception('Project not found');
    }
  }

  @override
  Future<EnhancedProject> createProject(
    Map<String, dynamic> projectData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final newProject = EnhancedProject.fromJson({
      'projectId': DateTime.now().millisecondsSinceEpoch.toString(),
      'projectName': projectData['projectName'] ?? 'New Project',
      'address': projectData['address'] ?? 'Test Location',
      'clientInfo': projectData['clientInfo'] ?? 'Test Client',
      'status': 'Planning',
      'startDate': DateTime.now().toIso8601String(),
      'estimatedEndDate': DateTime.now()
          .add(const Duration(days: 90))
          .toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'taskCount': 0,
      'completedTaskCount': 0,
      'totalCapacityKw': projectData['totalCapacityKw'] ?? 5.0,
      'pvModuleCount': projectData['pvModuleCount'] ?? 20,
      'revenueValue': projectData['revenueValue'] ?? 50000.0,
      'ftsValue': projectData['ftsValue'] ?? 0.0,
      'pqmValue': projectData['pqmValue'] ?? 0.0,
    });

    _mockProjects.add(newProject);
    return newProject;
  }

  @override
  Future<EnhancedProject> updateProject(
    String id,
    Map<String, dynamic> projectData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final index = _mockProjects.indexWhere(
      (project) => project.projectId == id,
    );
    if (index == -1) throw Exception('Project not found');

    // For simplicity, create a new project with updated data
    final currentProject = _mockProjects[index];
    final updatedProject = EnhancedProject.fromJson({
      'projectId': currentProject.projectId,
      'projectName': projectData['projectName'] ?? currentProject.projectName,
      'address': projectData['address'] ?? currentProject.address,
      'clientInfo': projectData['clientInfo'] ?? currentProject.clientInfo,
      'status': projectData['status'] ?? currentProject.status,
      'startDate': currentProject.startDate.toIso8601String(),
      'estimatedEndDate': currentProject.estimatedEndDate.toIso8601String(),
      'actualEndDate': currentProject.actualEndDate?.toIso8601String(),
      'createdAt': currentProject.createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'taskCount': projectData['taskCount'] ?? currentProject.taskCount,
      'completedTaskCount':
          projectData['completedTaskCount'] ??
          currentProject.completedTaskCount,
      'totalCapacityKw':
          projectData['totalCapacityKw'] ?? currentProject.totalCapacityKw,
      'pvModuleCount':
          projectData['pvModuleCount'] ?? currentProject.pvModuleCount,
      'revenueValue':
          projectData['revenueValue'] ?? currentProject.revenueValue,
      'ftsValue': projectData['ftsValue'] ?? currentProject.ftsValue,
      'pqmValue': projectData['pqmValue'] ?? currentProject.pqmValue,
    });

    _mockProjects[index] = updatedProject;
    return updatedProject;
  }

  @override
  Future<void> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _mockProjects.indexWhere(
      (project) => project.projectId == id,
    );
    if (index == -1) throw Exception('Project not found');

    _mockProjects.removeAt(index);
  }

  @override
  Future<ProjectsResponse> getProjectsByManager(
    String managerId,
    ProjectsQuery query,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final filteredProjects = _mockProjects
        .where(
          (project) =>
              project.projectManager != null &&
              (project.projectManager!.userId == managerId ||
                  project.projectManager!.username == managerId ||
                  project.projectManager!.email == managerId),
        )
        .toList();

    return ProjectsResponse(
      items: filteredProjects,
      totalCount: filteredProjects.length,
      pageNumber: query.pageNumber,
      pageSize: query.pageSize,
      totalPages: (filteredProjects.length / query.pageSize).ceil(),
      hasPreviousPage: query.pageNumber > 1,
      hasNextPage:
          query.pageNumber < (filteredProjects.length / query.pageSize).ceil(),
    );
  }

  @override
  Future<ProjectsResponse> getProjectsByStatus(
    String status,
    ProjectsQuery query,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final filteredProjects = _mockProjects
        .where(
          (project) => project.status.toLowerCase() == status.toLowerCase(),
        )
        .toList();

    return ProjectsResponse(
      items: filteredProjects,
      totalCount: filteredProjects.length,
      pageNumber: query.pageNumber,
      pageSize: query.pageSize,
      totalPages: (filteredProjects.length / query.pageSize).ceil(),
      hasPreviousPage: query.pageNumber > 1,
      hasNextPage:
          query.pageNumber < (filteredProjects.length / query.pageSize).ceil(),
    );
  }

  @override
  Future<ProjectsResponse> searchProjects(
    String searchQuery,
    ProjectsQuery query,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final lowerQuery = searchQuery.toLowerCase();
    final filteredProjects = _mockProjects
        .where(
          (project) =>
              project.projectName.toLowerCase().contains(lowerQuery) ||
              project.address.toLowerCase().contains(lowerQuery) ||
              project.clientInfo.toLowerCase().contains(lowerQuery),
        )
        .toList();

    return ProjectsResponse(
      items: filteredProjects,
      totalCount: filteredProjects.length,
      pageNumber: query.pageNumber,
      pageSize: query.pageSize,
      totalPages: (filteredProjects.length / query.pageSize).ceil(),
      hasPreviousPage: query.pageNumber > 1,
      hasNextPage:
          query.pageNumber < (filteredProjects.length / query.pageSize).ceil(),
    );
  }

  @override
  Future<Map<String, dynamic>> getProjectStatistics() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final total = _mockProjects.length;
    final active = _mockProjects.where((p) => p.status == 'Active').length;
    final completed = _mockProjects
        .where((p) => p.status == 'Completed')
        .length;
    final planning = _mockProjects.where((p) => p.status == 'Planning').length;

    return {
      'total': total,
      'active': active,
      'completed': completed,
      'planning': planning,
      'totalRevenue': _mockProjects.fold(
        0.0,
        (sum, p) => sum + (p.revenueValue ?? 0.0),
      ),
      'totalCapacity': _mockProjects.fold(
        0.0,
        (sum, p) => sum + (p.totalCapacityKw ?? 0.0),
      ),
      'averageProgress': total > 0
          ? _mockProjects.fold(
                  0.0,
                  (sum, p) =>
                      sum +
                      (p.completedTaskCount /
                          (p.taskCount > 0 ? p.taskCount : 1)),
                ) /
                total
          : 0.0,
    };
  }

  // Mock data - in a real app this would come from an API
  static final List<EnhancedProject> _mockProjects = [
    EnhancedProject.fromJson({
      'projectId': 'proj-001',
      'projectName': 'Residential Solar Installation - Smith House',
      'address': '123 Oak Street, Springfield, IL 62701',
      'clientInfo': 'John Smith - john.smith@email.com',
      'status': 'Active',
      'startDate': '2024-01-15T08:00:00Z',
      'estimatedEndDate': '2024-03-15T17:00:00Z',
      'createdAt': '2024-01-10T10:00:00Z',
      'updatedAt': '2024-02-20T15:30:00Z',
      'taskCount': 12,
      'completedTaskCount': 9,
      'totalCapacityKw': 8.5,
      'pvModuleCount': 24,
      'revenueValue': 25000.0,
      'ftsValue': 18750.0,
      'pqmValue': 85.0,
      'projectManager': {
        'managerId': 'manager-1',
        'managerName': 'Sarah Johnson',
        'managerEmail': 'sarah.johnson@company.com',
      },
      'locationCoordinates': {'latitude': 39.7817, 'longitude': -89.6501},
    }),
    EnhancedProject.fromJson({
      'projectId': 'proj-002',
      'projectName': 'Commercial Solar Array - Tech Campus',
      'address': '456 Innovation Drive, Tech City, CA 94102',
      'clientInfo': 'TechCorp Industries - procurement@techcorp.com',
      'status': 'Planning',
      'startDate': '2024-04-01T08:00:00Z',
      'estimatedEndDate': '2024-08-01T17:00:00Z',
      'createdAt': '2024-02-01T09:00:00Z',
      'updatedAt': '2024-02-25T11:15:00Z',
      'taskCount': 24,
      'completedTaskCount': 6,
      'totalCapacityKw': 50.0,
      'pvModuleCount': 140,
      'revenueValue': 150000.0,
      'ftsValue': 37500.0,
      'pqmValue': 25.0,
      'projectManager': {
        'managerId': 'manager-2',
        'managerName': 'Mike Chen',
        'managerEmail': 'mike.chen@company.com',
      },
      'locationCoordinates': {'latitude': 37.7749, 'longitude': -122.4194},
    }),
  ];
}
