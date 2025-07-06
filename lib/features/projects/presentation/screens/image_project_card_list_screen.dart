import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';
import '../../../authorization/presentation/widgets/authorization_widgets.dart';

/// Extension for convenience methods on Color objects
extension ColorExtension on Color {
  Color withValues({int? red, int? green, int? blue, int? alpha}) {
    return Color.fromARGB(
      alpha ?? this.alpha,
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
}

// Project data model matching your API response
class ApiProject {
  final String projectId;
  final String projectName;
  final String address;
  final String clientInfo;
  final String status;
  final DateTime startDate;
  final DateTime estimatedEndDate;
  final DateTime? actualEndDate;
  final ProjectManager projectManager;
  final int taskCount;
  final int completedTaskCount;
  final String? imageUrl; // Project image

  const ApiProject({
    required this.projectId,
    required this.projectName,
    required this.address,
    required this.clientInfo,
    required this.status,
    required this.startDate,
    required this.estimatedEndDate,
    this.actualEndDate,
    required this.projectManager,
    required this.taskCount,
    required this.completedTaskCount,
    this.imageUrl,
  });

  double get completionPercentage =>
      taskCount > 0 ? (completedTaskCount / taskCount) * 100 : 0;

  bool get isOverdue =>
      estimatedEndDate.isBefore(DateTime.now()) && actualEndDate == null;

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'on hold':
        return Colors.amber;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class ProjectManager {
  final String userId;
  final String username;
  final String email;
  final String fullName;
  final String roleName;
  final bool isActive;

  const ProjectManager({
    required this.userId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.roleName,
    required this.isActive,
  });
}

class ImageProjectCardListScreen extends StatefulWidget {
  const ImageProjectCardListScreen({super.key});

  @override
  State<ImageProjectCardListScreen> createState() =>
      _ImageProjectCardListScreenState();
}

class _ImageProjectCardListScreenState
    extends State<ImageProjectCardListScreen> {
  bool _isLoading = false;
  List<ApiProject> _projects = [];
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreProjects();
      }
    }
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    // Simulate API call - replace with actual API integration
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _projects = _getMockProjects();
      _isLoading = false;
    });
  }

  Future<void> _loadMoreProjects() async {
    setState(() {
      _isLoading = true;
      _currentPage++;
    });

    // Simulate loading more projects
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      // In real implementation, this would be an API call
      final moreProjects = _getMockProjects(page: _currentPage);
      _projects.addAll(moreProjects);
      _hasMoreData = moreProjects.isNotEmpty;
      _isLoading = false;
    });
  }

  List<ApiProject> _getMockProjects({int page = 1}) {
    // Mock data matching your API structure
    final statuses = ['In Progress', 'Completed', 'On Hold', 'Planning'];
    final projectTypes = [
      'Downtown Solar Installation',
      'Residential Solar Project',
      'Commercial Solar Array',
      'Solar Farm Development',
      'Smart Solar Home',
      'Green Energy Facility',
      'Rooftop Solar Installation',
      'Solar Power Plant',
    ];

    return List.generate(page == 1 ? 8 : 4, (index) {
      final projectIndex = (page - 1) * _pageSize + index;
      return ApiProject(
        projectId: 'project-${projectIndex + 1}',
        projectName: projectTypes[projectIndex % projectTypes.length],
        address: '${123 + projectIndex} Main St, City, State 1234$index',
        clientInfo:
            'Client Corp ${index + 1} - Contact: John Smith (555-123-456$index)',
        status: statuses[projectIndex % statuses.length],
        startDate: DateTime.now().subtract(Duration(days: 30 + index * 5)),
        estimatedEndDate: DateTime.now().add(Duration(days: 60 - index * 10)),
        taskCount: 15 + index * 3,
        completedTaskCount: 8 + index * 2,
        imageUrl: null, // Now using header.jpg asset for all backgrounds
        projectManager: ProjectManager(
          userId: 'pm-${index + 1}',
          username: 'pm.manager${index + 1}',
          email: 'manager${index + 1}@example.com',
          fullName: 'Project Manager ${index + 1}',
          roleName: 'ProjectManager',
          isActive: true,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solar Project Gallery'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProjects),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter options coming soon!')),
              );
            },
          ),
          // Create Project button in AppBar
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is! AuthAuthenticated) {
                return const SizedBox.shrink();
              }

              final user = authState.user;

              return PermissionBuilder(
                user: user,
                resource: 'projects',
                action: 'create',
                builder: (context, hasPermission) {
                  if (!hasPermission) {
                    return const SizedBox.shrink();
                  }

                  return IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => context.go('/projects/create'),
                    tooltip: 'Create New Project',
                  );
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProjects,
        child: _buildProjectList(),
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const SizedBox.shrink(); // Hide button if not authenticated
          }

          final user = authState.user;

          return PermissionBuilder(
            user: user,
            resource: 'projects',
            action: 'create',
            builder: (context, hasPermission) {
              if (!hasPermission) {
                return const SizedBox.shrink(); // Hide button if no permission
              }

              return FloatingActionButton.extended(
                heroTag: "image_project_fab",
                onPressed: () => context.go('/projects/create'),
                icon: const Icon(Icons.add),
                label: const Text('New Project'),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProjectList() {
    if (_projects.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No projects found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first project to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Project statistics header
        SliverToBoxAdapter(child: _buildStatsHeader()),

        // Project grid
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < _projects.length) {
                return _buildImageProjectCard(_projects[index]);
              } else if (_isLoading) {
                return _buildLoadingCard();
              }
              return null;
            }, childCount: _projects.length + (_isLoading ? 2 : 0)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    final totalProjects = _projects.length;
    final completedProjects = _projects
        .where((p) => p.status == 'Completed')
        .length;
    final inProgressProjects = _projects
        .where((p) => p.status == 'In Progress')
        .length;
    final overdueProjects = _projects.where((p) => p.isOverdue).length;

    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background header image
          Positioned.fill(
            child: Image.asset('assets/images/header.jpg', fit: BoxFit.cover),
          ),
          // Overlay for better text visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.9),
                    Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Project Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 2.0,
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Total',
                      totalProjects.toString(),
                      Icons.folder,
                    ),
                    _buildStatItem(
                      'Active',
                      inProgressProjects.toString(),
                      Icons.play_circle,
                      Colors.orange,
                    ),
                    _buildStatItem(
                      'Done',
                      completedProjects.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    if (overdueProjects > 0)
                      _buildStatItem(
                        'Overdue',
                        overdueProjects.toString(),
                        Icons.warning,
                        Colors.red,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    final itemColor = color ?? Theme.of(context).colorScheme.onPrimaryContainer;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: itemColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: itemColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, color: itemColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: itemColor,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 2.0,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: itemColor.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 2.0,
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageProjectCard(ApiProject project) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showProjectDetails(project),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize
              .min, // Fix: Allow Column to size itself based on content
          children: [
            // Project Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background header image
                        Image.asset(
                          'assets/images/header.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        ),
                        // Overlay gradient for better text visibility
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                        // Optional: Project-specific overlay if available
                        if (project.imageUrl != null)
                          Container(
                            decoration: BoxDecoration(
                              color: project.statusColor.withValues(alpha: 0.1),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Status overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: project.statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        project.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Overdue warning
                  if (project.isOverdue)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Project Info - Fixed height to prevent overflow
            Container(
              height: 80, // Fix: Set a fixed height for the info section
              padding: const EdgeInsets.all(8.0), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Project name
                  Flexible(
                    child: Text(
                      project.projectName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12, // Slightly smaller text
                      ),
                      maxLines: 1, // Reduced to 1 line to fit better
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2), // Reduced spacing
                  // Address
                  Flexible(
                    child: Text(
                      project.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10, // Smaller text
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced spacing
                  // Progress bar - more compact
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 10, // Smaller text
                                ),
                          ),
                          Text(
                            '${project.completionPercentage.toInt()}%',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10, // Smaller text
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 4, // Thinner progress bar
                        child: LinearProgressIndicator(
                          value: project.completionPercentage / 100,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            project.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Use header.jpg as fallback background
        Image.asset(
          'assets/images/header.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.business,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // Semi-transparent overlay
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
          ),
          child: Center(
            child: Icon(
              Icons.solar_power,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _showProjectDetails(ApiProject project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProjectDetailsSheet(project: project),
    );
  }
}

class _ProjectDetailsSheet extends StatelessWidget {
  final ApiProject project;

  const _ProjectDetailsSheet({required this.project});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project image with header.jpg background
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Background header image
                            Image.asset(
                              'assets/images/header.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.business, size: 64),
                            ),
                            // Overlay gradient for better contrast
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.4),
                                  ],
                                ),
                              ),
                            ),
                            // Project status overlay
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: project.statusColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  project.status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Project name overlay at the bottom
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Text(
                                project.projectName,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        const Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(130, 0, 0, 0),
                                        ),
                                      ],
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Project name and status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.projectName,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: project.statusColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              project.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Project details
                      _buildDetailRow(
                        'Address',
                        project.address,
                        Icons.location_on,
                      ),
                      _buildDetailRow(
                        'Client',
                        project.clientInfo,
                        Icons.business,
                      ),
                      _buildDetailRow(
                        'Manager',
                        project.projectManager.fullName,
                        Icons.person,
                      ),
                      _buildDetailRow(
                        'Tasks',
                        '${project.completedTaskCount}/${project.taskCount} completed',
                        Icons.task,
                      ),
                      _buildDetailRow(
                        'Start Date',
                        _formatDate(project.startDate),
                        Icons.calendar_today,
                      ),
                      _buildDetailRow(
                        'End Date',
                        _formatDate(project.estimatedEndDate),
                        Icons.event,
                      ),

                      const SizedBox(height: 24),

                      // Progress section
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: project.completionPercentage / 100,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          project.statusColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${project.completionPercentage.toInt()}% Complete',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Opening ${project.projectName} details...',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('View Details'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Editing ${project.projectName}...',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
