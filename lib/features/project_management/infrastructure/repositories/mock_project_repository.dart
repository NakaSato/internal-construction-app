import 'package:injectable/injectable.dart';

import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

/// Mock implementation of ProjectRepository for development/testing
@Named('mock')
@LazySingleton(as: ProjectRepository)
class MockProjectRepository implements ProjectRepository {
  static final List<Project> _projects = [
    Project(
      id: '1',
      name: 'Flutter Architecture App',
      description:
          'A comprehensive Flutter application showcasing clean architecture principles with authentication, image upload, location tracking, and calendar features.',
      status: ProjectStatus.inProgress,
      priority: ProjectPriority.high,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      dueDate: DateTime.now().add(const Duration(days: 15)),
      completionPercentage: 75,
      tags: ['Flutter', 'Clean Architecture', 'BLoC', 'Mobile Development'],
    ),
    Project(
      id: '2',
      name: 'API Integration',
      description:
          'Integrate with backend APIs for user authentication, data synchronization, and real-time updates.',
      status: ProjectStatus.inProgress,
      priority: ProjectPriority.high,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      dueDate: DateTime.now().add(const Duration(days: 10)),
      completionPercentage: 60,
      tags: ['API', 'Backend Integration', 'Authentication'],
    ),
    Project(
      id: '3',
      name: 'UI/UX Enhancement',
      description:
          'Improve user interface design, add animations, and enhance user experience across all screens.',
      status: ProjectStatus.planning,
      priority: ProjectPriority.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      dueDate: DateTime.now().add(const Duration(days: 25)),
      completionPercentage: 15,
      tags: ['UI/UX', 'Design', 'Animation'],
    ),
    Project(
      id: '4',
      name: 'Testing & QA',
      description:
          'Comprehensive testing including unit tests, widget tests, and integration tests for all features.',
      status: ProjectStatus.planning,
      priority: ProjectPriority.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      dueDate: DateTime.now().add(const Duration(days: 20)),
      completionPercentage: 25,
      tags: ['Testing', 'QA', 'Unit Tests', 'Integration Tests'],
    ),
    Project(
      id: '5',
      name: 'Performance Optimization',
      description:
          'Optimize app performance, reduce bundle size, and improve loading times.',
      status: ProjectStatus.onHold,
      priority: ProjectPriority.low,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      dueDate: DateTime.now().add(const Duration(days: 40)),
      completionPercentage: 10,
      tags: ['Performance', 'Optimization', 'Bundle Size'],
    ),
    Project(
      id: '6',
      name: 'Documentation',
      description:
          'Create comprehensive documentation for the project including API docs, user guides, and developer documentation.',
      status: ProjectStatus.completed,
      priority: ProjectPriority.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      dueDate: DateTime.now().subtract(const Duration(days: 5)),
      completionPercentage: 100,
      tags: ['Documentation', 'API Docs', 'User Guide'],
    ),
  ];

  @override
  Future<List<Project>> getAllProjects() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_projects);
  }

  @override
  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _projects.where((project) => project.status == status).toList();
  }

  @override
  Future<Project?> getProjectById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Project> createProject(Project project) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newProject = project.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _projects.add(newProject);
    return newProject;
  }

  @override
  Future<Project> updateProject(Project project) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      final updatedProject = project.copyWith(updatedAt: DateTime.now());
      _projects[index] = updatedProject;
      return updatedProject;
    }
    throw Exception('Project not found');
  }

  @override
  Future<void> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _projects.removeWhere((project) => project.id == id);
  }

  @override
  Future<List<Project>> searchProjects(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lowercaseQuery = query.toLowerCase();
    return _projects.where((project) {
      return project.name.toLowerCase().contains(lowercaseQuery) ||
          project.description.toLowerCase().contains(lowercaseQuery) ||
          project.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  @override
  Future<List<Project>> getProjectsByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _projects
        .where((project) => project.assignedUserId == userId)
        .toList();
  }
}
