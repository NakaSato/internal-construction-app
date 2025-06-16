import 'package:injectable/injectable.dart';

import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

/// Mock implementation of ProjectRepository for development/testing
@Named('mock')
@LazySingleton(as: ProjectRepository)
class MockProjectRepository implements ProjectRepository {
  const MockProjectRepository();

  static final List<Project> _projects = [
    Project(
      projectId: '1',
      projectName: 'Mobile App Development',
      address: '123 Tech Street, Silicon Valley, CA',
      clientInfo: 'TechCorp Inc - Contact: John Smith (555-123-4567)',
      status: 'In Progress',
      startDate: DateTime(2024, 1, 15),
      estimatedEndDate: DateTime(2024, 6, 15),
      taskCount: 25,
      completedTaskCount: 15,
      description:
          'Building a cross-platform mobile application with advanced features',
    ),
    Project(
      projectId: '2',
      projectName: 'E-commerce Website',
      address: '456 Commerce Ave, New York, NY',
      clientInfo: 'ShopSmart LLC - Contact: Jane Doe (555-987-6543)',
      status: 'Planning',
      startDate: DateTime(2024, 2, 1),
      estimatedEndDate: DateTime(2024, 8, 1),
      taskCount: 30,
      completedTaskCount: 5,
      description: 'Full-featured e-commerce platform with payment integration',
    ),
    Project(
      projectId: '3',
      projectName: 'Data Analytics Dashboard',
      address: '789 Data Drive, Austin, TX',
      clientInfo: 'Analytics Pro - Contact: Bob Johnson (555-456-7890)',
      status: 'Completed',
      startDate: DateTime(2023, 9, 1),
      estimatedEndDate: DateTime(2024, 1, 1),
      actualEndDate: DateTime(2023, 12, 20),
      taskCount: 20,
      completedTaskCount: 20,
      description: 'Real-time analytics dashboard with data visualization',
    ),
    Project(
      projectId: '4',
      projectName: 'Cloud Migration',
      address: '321 Cloud Lane, Seattle, WA',
      clientInfo: 'CloudFirst Corp - Contact: Alice Brown (555-321-9876)',
      status: 'On Hold',
      startDate: DateTime(2024, 3, 1),
      estimatedEndDate: DateTime(2024, 9, 1),
      taskCount: 15,
      completedTaskCount: 8,
      description: 'Migrating legacy systems to cloud infrastructure',
    ),
    Project(
      projectId: '5',
      projectName: 'Security Audit',
      address: '654 Security Blvd, Washington, DC',
      clientInfo: 'SecureIt Inc - Contact: Charlie Wilson (555-654-3210)',
      status: 'In Progress',
      startDate: DateTime(2024, 1, 20),
      estimatedEndDate: DateTime(2024, 4, 20),
      taskCount: 12,
      completedTaskCount: 7,
      description: 'Comprehensive security audit and vulnerability assessment',
    ),
    Project(
      projectId: '6',
      projectName: 'API Development',
      address: '987 API Street, San Francisco, CA',
      clientInfo: 'DevTools Ltd - Contact: Diana Lee (555-789-0123)',
      status: 'In Progress',
      startDate: DateTime(2024, 2, 10),
      estimatedEndDate: DateTime(2024, 5, 10),
      taskCount: 18,
      completedTaskCount: 12,
      description: 'RESTful API development with microservices architecture',
    ),
  ];

  @override
  Future<List<Project>> getAllProjects() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay
    return List.from(_projects);
  }

  @override
  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _projects
        .where((project) => project.projectStatus == status)
        .toList();
  }

  @override
  Future<Project?> getProjectById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _projects.firstWhere((project) => project.projectId == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Project> createProject(Project project) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _projects.add(project);
    return project;
  }

  @override
  Future<Project> updateProject(Project project) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _projects.indexWhere((p) => p.projectId == project.projectId);
    if (index != -1) {
      _projects[index] = project;
    }
    return project;
  }

  @override
  Future<void> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _projects.removeWhere((project) => project.projectId == id);
  }

  @override
  Future<List<Project>> searchProjects(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowercaseQuery = query.toLowerCase();
    return _projects
        .where(
          (project) =>
              project.projectName.toLowerCase().contains(lowercaseQuery) ||
              project.description.toLowerCase().contains(lowercaseQuery) ||
              project.clientInfo.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  @override
  Future<List<Project>> getProjectsByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // For mock data, return projects where the manager ID matches
    return _projects
        .where((project) => project.projectManager?.userId == userId)
        .toList();
  }
}
