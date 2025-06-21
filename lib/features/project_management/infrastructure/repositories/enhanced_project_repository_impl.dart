import '../../domain/entities/project_api_models.dart';
import '../../domain/repositories/enhanced_project_repository.dart';
import '../datasources/project_remote_data_source.dart';

/// Enhanced repository implementation for Project Management API
/// 
/// Provides advanced project management capabilities including:
/// - CRUD operations with role-based access control
/// - Advanced filtering and search functionality
/// - Project statistics and analytics
/// - Caching and offline support
/// - Error handling and retry logic
class EnhancedProjectRepositoryImpl implements EnhancedProjectRepository {
  final ProjectRemoteDataSource _remoteDataSource;

  const EnhancedProjectRepositoryImpl(this._remoteDataSource);

  @override
  Future<ProjectsResponse> getProjects({
    ProjectsQuery? query,
    String? userRole,
  }) async {
    try {
      return await _remoteDataSource.getProjects(
        query: query,
        userRole: userRole,
      );
    } catch (e) {
      // Log error for debugging
      print('Repository Error - getProjects: $e');
      rethrow; // Let the calling layer handle the error
    }
  }

  @override
  Future<EnhancedProject> getProjectById(
    String projectId, {
    String? userRole,
  }) async {
    try {
      return await _remoteDataSource.getProjectById(
        projectId,
        userRole: userRole,
      );
    } catch (e) {
      print('Repository Error - getProjectById: $e');
      rethrow;
    }
  }

  @override
  Future<ProjectsResponse> searchProjects(
    String searchTerm, {
    ProjectsQuery? filters,
    String? userRole,
  }) async {
    try {
      return await _remoteDataSource.searchProjects(
        searchTerm,
        filters: filters,
        userRole: userRole,
      );
    } catch (e) {
      print('Repository Error - searchProjects: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getProjectStatistics({
    String? userRole,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _remoteDataSource.getProjectStatistics(
        userRole: userRole,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('Repository Error - getProjectStatistics: $e');
      rethrow;
    }
  }

  @override
  Future<EnhancedProject> createProject(
    Map<String, dynamic> projectData, {
    required String userRole,
  }) async {
    try {
      _validateCreatePermission(userRole);
      return await _remoteDataSource.createProject(
        projectData,
        userRole: userRole,
      );
    } catch (e) {
      print('Repository Error - createProject: $e');
      rethrow;
    }
  }

  @override
  Future<EnhancedProject> updateProject(
    String projectId,
    Map<String, dynamic> projectData, {
    required String userRole,
  }) async {
    try {
      _validateEditPermission(userRole);
      return await _remoteDataSource.updateProject(
        projectId,
        projectData,
        userRole: userRole,
      );
    } catch (e) {
      print('Repository Error - updateProject: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteProject(
    String projectId, {
    required String userRole,
  }) async {
    try {
      _validateDeletePermission(userRole);
      await _remoteDataSource.deleteProject(
        projectId,
        userRole: userRole,
      );
    } catch (e) {
      print('Repository Error - deleteProject: $e');
      rethrow;
    }
  }

  @override
  Future<List<EnhancedProject>> getProjectsByManager(
    String managerId, {
    String? userRole,
  }) async {
    try {
      return await _remoteDataSource.getProjectsByManager(
        managerId,
        userRole: userRole,
      );
    } catch (e) {
      print('Repository Error - getProjectsByManager: $e');
      rethrow;
    }
  }

  @override
  Future<List<EnhancedProject>> getProjectsByStatus(
    String status, {
    String? userRole,
  }) async {
    try {
      return await _remoteDataSource.getProjectsByStatus(
        status,
        userRole: userRole,
      );
    } catch (e) {
      print('Repository Error - getProjectsByStatus: $e');
      rethrow;
    }
  }

  @override
  Future<List<EnhancedProject>> getProjectsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userRole,
  }) async {
    try {
      return await _remoteDataSource.getProjectsByDateRange(
        startDate,
        endDate,
        userRole: userRole,
      );
    } catch (e) {
      print('Repository Error - getProjectsByDateRange: $e');
      rethrow;
    }
  }

  @override
  Future<EnhancedProject> assignProjectManager(
    String projectId,
    String managerId, {
    required String userRole,
  }) async {
    try {
      _validateManagePermission(userRole);
      return await _remoteDataSource.assignProjectManager(
        projectId,
        managerId,
        userRole: userRole,
      );
    } catch (e) {
      print('Repository Error - assignProjectManager: $e');
      rethrow;
    }
  }

  @override
  Future<EnhancedProject> updateProjectStatus(
    String projectId,
    String status, {
    required String userRole,
  }) async {
    try {
      _validateEditPermission(userRole);
      return await _remoteDataSource.updateProjectStatus(
        projectId,
        status,
        userRole: userRole,
      );
    } catch (e) {
      print('Repository Error - updateProjectStatus: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _remoteDataSource.clearCache();
    } catch (e) {
      print('Repository Error - clearCache: $e');
      rethrow;
    }
  }

  @override
  Future<void> refreshCache() async {
    try {
      await _remoteDataSource.refreshCache();
    } catch (e) {
      print('Repository Error - refreshCache: $e');
      rethrow;
    }
  }

  // Private helper methods for role validation

  void _validateCreatePermission(String userRole) {
    final allowedRoles = ['Admin', 'Project Manager'];
    if (!allowedRoles.any((role) => 
        userRole.toLowerCase().contains(role.toLowerCase()))) {
      throw Exception(
        'Insufficient permissions: $userRole cannot create projects. '
        'Required role: Admin or Project Manager'
      );
    }
  }

  void _validateEditPermission(String userRole) {
    final allowedRoles = ['Admin', 'Project Manager'];
    if (!allowedRoles.any((role) => 
        userRole.toLowerCase().contains(role.toLowerCase()))) {
      throw Exception(
        'Insufficient permissions: $userRole cannot edit projects. '
        'Required role: Admin or Project Manager'
      );
    }
  }

  void _validateDeletePermission(String userRole) {
    final allowedRoles = ['Admin'];
    if (!allowedRoles.any((role) => 
        userRole.toLowerCase().contains(role.toLowerCase()))) {
      throw Exception(
        'Insufficient permissions: $userRole cannot delete projects. '
        'Required role: Admin only'
      );
    }
  }

  void _validateManagePermission(String userRole) {
    final allowedRoles = ['Admin', 'Project Manager'];
    if (!allowedRoles.any((role) => 
        userRole.toLowerCase().contains(role.toLowerCase()))) {
      throw Exception(
        'Insufficient permissions: $userRole cannot manage projects. '
        'Required role: Admin or Project Manager'
      );
    }
  }
}

/// Repository implementation with caching layer
class CachedEnhancedProjectRepositoryImpl implements EnhancedProjectRepository {
  final EnhancedProjectRepository _baseRepository;
  final Map<String, dynamic> _cache = {};
  final Duration _cacheTimeout = const Duration(minutes: 5);

  CachedEnhancedProjectRepositoryImpl(this._baseRepository);

  @override
  Future<ProjectsResponse> getProjects({
    ProjectsQuery? query,
    String? userRole,
  }) async {
    final cacheKey = 'projects_${query?.hashCode ?? 'all'}_$userRole';
    
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (cached['timestamp'].add(_cacheTimeout).isAfter(DateTime.now())) {
        return cached['data'] as ProjectsResponse;
      }
    }

    final result = await _baseRepository.getProjects(
      query: query,
      userRole: userRole,
    );

    _cache[cacheKey] = {
      'data': result,
      'timestamp': DateTime.now(),
    };

    return result;
  }

  @override
  Future<EnhancedProject> getProjectById(
    String projectId, {
    String? userRole,
  }) async {
    final cacheKey = 'project_${projectId}_$userRole';
    
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (cached['timestamp'].add(_cacheTimeout).isAfter(DateTime.now())) {
        return cached['data'] as EnhancedProject;
      }
    }

    final result = await _baseRepository.getProjectById(
      projectId,
      userRole: userRole,
    );

    _cache[cacheKey] = {
      'data': result,
      'timestamp': DateTime.now(),
    };

    return result;
  }

  @override
  Future<ProjectsResponse> searchProjects(
    String searchTerm, {
    ProjectsQuery? filters,
    String? userRole,
  }) async {
    // Search results are not cached to ensure fresh data
    return await _baseRepository.searchProjects(
      searchTerm,
      filters: filters,
      userRole: userRole,
    );
  }

  @override
  Future<Map<String, dynamic>> getProjectStatistics({
    String? userRole,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final cacheKey = 'stats_${userRole}_${startDate?.millisecondsSinceEpoch}_${endDate?.millisecondsSinceEpoch}';
    
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (cached['timestamp'].add(_cacheTimeout).isAfter(DateTime.now())) {
        return cached['data'] as Map<String, dynamic>;
      }
    }

    final result = await _baseRepository.getProjectStatistics(
      userRole: userRole,
      startDate: startDate,
      endDate: endDate,
    );

    _cache[cacheKey] = {
      'data': result,
      'timestamp': DateTime.now(),
    };

    return result;
  }

  // Write operations clear relevant cache entries
  @override
  Future<EnhancedProject> createProject(
    Map<String, dynamic> projectData, {
    required String userRole,
  }) async {
    final result = await _baseRepository.createProject(
      projectData,
      userRole: userRole,
    );
    
    _clearProjectsCache();
    return result;
  }

  @override
  Future<EnhancedProject> updateProject(
    String projectId,
    Map<String, dynamic> projectData, {
    required String userRole,
  }) async {
    final result = await _baseRepository.updateProject(
      projectId,
      projectData,
      userRole: userRole,
    );
    
    _clearProjectCache(projectId);
    _clearProjectsCache();
    return result;
  }

  @override
  Future<void> deleteProject(
    String projectId, {
    required String userRole,
  }) async {
    await _baseRepository.deleteProject(
      projectId,
      userRole: userRole,
    );
    
    _clearProjectCache(projectId);
    _clearProjectsCache();
  }

  @override
  Future<List<EnhancedProject>> getProjectsByManager(
    String managerId, {
    String? userRole,
  }) async {
    return await _baseRepository.getProjectsByManager(
      managerId,
      userRole: userRole,
    );
  }

  @override
  Future<List<EnhancedProject>> getProjectsByStatus(
    String status, {
    String? userRole,
  }) async {
    return await _baseRepository.getProjectsByStatus(
      status,
      userRole: userRole,
    );
  }

  @override
  Future<List<EnhancedProject>> getProjectsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userRole,
  }) async {
    return await _baseRepository.getProjectsByDateRange(
      startDate,
      endDate,
      userRole: userRole,
    );
  }

  @override
  Future<EnhancedProject> assignProjectManager(
    String projectId,
    String managerId, {
    required String userRole,
  }) async {
    final result = await _baseRepository.assignProjectManager(
      projectId,
      managerId,
      userRole: userRole,
    );
    
    _clearProjectCache(projectId);
    _clearProjectsCache();
    return result;
  }

  @override
  Future<EnhancedProject> updateProjectStatus(
    String projectId,
    String status, {
    required String userRole,
  }) async {
    final result = await _baseRepository.updateProjectStatus(
      projectId,
      status,
      userRole: userRole,
    );
    
    _clearProjectCache(projectId);
    _clearProjectsCache();
    return result;
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
    await _baseRepository.clearCache();
  }

  @override
  Future<void> refreshCache() async {
    _cache.clear();
    await _baseRepository.refreshCache();
  }

  // Private cache management methods
  void _clearProjectCache(String projectId) {
    _cache.removeWhere((key, value) => key.startsWith('project_$projectId'));
  }

  void _clearProjectsCache() {
    _cache.removeWhere((key, value) => 
        key.startsWith('projects_') || key.startsWith('stats_'));
  }
}
