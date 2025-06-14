import 'package:flutter/material.dart';

import 'project_management/domain/entities/project.dart';

/// Demo page showcasing the new project list implementation with colored vertical bars
class ProjectListStyleDemo extends StatelessWidget {
  const ProjectListStyleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample project data for demonstration
    final sampleProjects = [
      Project(
        id: '1',
        name: 'Mobile App Development',
        description: 'Flutter mobile application with modern UI',
        status: ProjectStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        dueDate: DateTime.now().add(const Duration(days: 60)),
        completionPercentage: 75,
        priority: ProjectPriority.high,
      ),
      Project(
        id: '2',
        name: 'Website Redesign',
        description: 'Complete overhaul of company website',
        status: ProjectStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        dueDate: DateTime.now().add(const Duration(days: 45)),
        completionPercentage: 45,
        priority: ProjectPriority.medium,
      ),
      Project(
        id: '3',
        name: 'API Integration',
        description: 'Integrate third-party APIs for enhanced functionality',
        status: ProjectStatus.planning,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        completionPercentage: 20,
        priority: ProjectPriority.medium,
      ),
      Project(
        id: '4',
        name: 'Database Migration',
        description: 'Migrate legacy database to cloud infrastructure',
        status: ProjectStatus.planning,
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 90)),
        completionPercentage: 0,
        priority: ProjectPriority.low,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project List Styles Demo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Project List Style',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'With colored vertical bars, IntrinsicHeight layout, and modern card design',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            _buildProjectList(sampleProjects),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Implementation Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFeaturePoint('ListView.builder for efficient scrolling'),
                    _buildFeaturePoint('IntrinsicHeight ensures proper row alignment'),
                    _buildFeaturePoint('Colored vertical bars for visual distinction'),
                    _buildFeaturePoint('Material Design 3 styling and shadows'),
                    _buildFeaturePoint('Responsive layout with Expanded widgets'),
                    _buildFeaturePoint('Arrow icons for navigation indication'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a project list with colored vertical bars as described
  Widget _buildProjectList(List<Project> projects) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        
        // Dynamic colors based on project status
        final Color color = _getProjectColor(project.status);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Colored vertical bar
                  Container(
                    width: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  // Project details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Project',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  project.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (project.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    project.description,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 8),
                                // Progress indicator
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: project.completionPercentage / 100.0,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: AlwaysStoppedAnimation<Color>(color),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${project.completionPercentage}%',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Status and arrow
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusText(project.status),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getProjectColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.orange;
      case ProjectStatus.inProgress:
        return Colors.blue;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.onHold:
        return Colors.red;
      case ProjectStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }
}
