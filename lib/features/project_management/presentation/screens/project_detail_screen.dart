import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../application/project_bloc.dart';
import '../../application/project_event.dart';
import '../../application/project_state.dart';
import '../../domain/entities/project.dart';
import '../../../daily_reports/presentation/screens/daily_reports_screen.dart';
import '../../../work_request_approval/presentation/screens/my_work_requests_screen.dart';
import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';
import '../../../authorization/application/authorization_bloc.dart';
import '../../../authorization/application/authorization_state.dart';
import '../../../authorization/presentation/widgets/authorization_widgets.dart';

// Import widget components
import '../widgets/project_detail/project_header_widget.dart';
import '../widgets/project_detail/project_stats_widget.dart';
import '../widgets/project_detail/project_description_widget.dart';
import '../widgets/project_detail/project_progress_widget.dart';
import '../widgets/project_detail/project_tasks_widget.dart';
import '../widgets/project_detail/project_reports_widget.dart';
import '../widgets/project_detail/project_actions_widget.dart';
import '../widgets/project_detail/project_details_widget.dart';
import '../widgets/project_detail/quick_actions_bottom_sheet.dart';

/// Screen to display detailed information about a specific project
class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late ProjectBloc _projectBloc;
  Project? _project;

  @override
  void initState() {
    super.initState();
    _projectBloc = GetIt.instance<ProjectBloc>();
    _projectBloc.add(const ProjectLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider.value(
        value: _projectBloc,
        child: BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, state) {
            if (state is ProjectLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading project details...'),
                  ],
                ),
              );
            }

            if (state is ProjectError) {
              return _buildErrorView(context, state.message);
            }

            if (state is ProjectLoaded) {
              // Find the specific project by ID
              try {
                _project = state.projects.firstWhere(
                  (project) => project.projectId == widget.projectId,
                );
                return _buildProjectDetailView(context, _project!);
              } catch (e) {
                return _buildProjectNotFoundView(context);
              }
            }

            return const Center(child: Text('No project data available'));
          },
        ),
      ),
      floatingActionButton: _project != null ? BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) return const SizedBox.shrink();
          
          // Handle potential role lookup errors by using a default fallback approach
          try {
            return PermissionBuilder(
              user: authState.user,
              resource: 'projects',
              action: 'update',
              builder: (context, hasUpdatePermission) {
                if (!hasUpdatePermission) return const SizedBox.shrink();
                
                return FloatingActionButton.extended(
                  onPressed: () => QuickActionsBottomSheet.show(context, _project!),
                  icon: const Icon(Icons.add),
                  label: const Text('Quick Add'),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                );
              },
              // Add a fallback to handle loading errors
              fallback: const SizedBox.shrink(),
            );
          } catch (e) {
            // If permission check fails, default to not showing the button
            return const SizedBox.shrink();
          }
        },
      ) : null,
    );
  }

  Widget _buildProjectDetailView(BuildContext context, Project project) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(
            child: Text('Authentication required to view project details'),
          );
        }

        final user = authState.user;

        return CustomScrollView(
          slivers: [
            // Project Header with App Bar - with authorization controls
            _buildAuthorizedProjectHeader(context, project, user),

            // Project Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Overview Stats
                    ProjectStatsWidget(project: project),
                    const SizedBox(height: 20),
                    
                    // Project Description
                    if (project.description.isNotEmpty) ...[
                      ProjectDescriptionWidget(project: project),
                      const SizedBox(height: 20),
                    ],
                    
                    // Progress and Budget Section
                    ProjectProgressWidget(project: project),
                    const SizedBox(height: 20),
                    
                    // Tasks Section
                    ProjectTasksWidget(
                      project: project,
                      onViewAllTasks: () {
                        // TODO: Navigate to full tasks list
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Recent Reports Section
                    ProjectReportsWidget(
                      project: project,
                      onViewAllReports: () => _navigateToDailyReports(context, project),
                    ),
                    const SizedBox(height: 20),
                    
                    // Action Buttons - with authorization controls
                    _buildAuthorizedActions(context, project, user),
                    const SizedBox(height: 20),
                    
                    // Project Details
                    ProjectDetailsWidget(project: project),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAuthorizedProjectHeader(BuildContext context, Project project, user) {
    try {
      // First check update permission with fallback
      return PermissionBuilder(
        user: user,
        resource: 'projects',
        action: 'update',
        builder: (context, hasUpdatePermission) {
          try {
            // Then check delete permission with fallback
            return PermissionBuilder(
              user: user,
              resource: 'projects', 
              action: 'delete',
              builder: (context, hasDeletePermission) {
                return ProjectHeaderWidget(
                  project: project,
                  onEdit: hasUpdatePermission ? () => _editProject(context, project) : null,
                  onShare: () => _shareProject(context, project), // Share is available to all
                  onDelete: hasDeletePermission ? () => _deleteProject(context, project) : null,
                );
              },
              // Fallback for delete permission check failure
              fallback: ProjectHeaderWidget(
                project: project,
                onEdit: hasUpdatePermission ? () => _editProject(context, project) : null,
                onShare: () => _shareProject(context, project),
                onDelete: null,
              ),
            );
          } catch (e) {
            // If nested permission check fails, use default with just update permission
            return ProjectHeaderWidget(
              project: project,
              onEdit: hasUpdatePermission ? () => _editProject(context, project) : null,
              onShare: () => _shareProject(context, project),
              onDelete: null,
            );
          }
        },
        // Fallback for update permission check failure
        fallback: ProjectHeaderWidget(
          project: project,
          onEdit: null,
          onShare: () => _shareProject(context, project),
          onDelete: null,
        ),
      );
    } catch (e) {
      // Complete fallback if all permission checks fail
      return ProjectHeaderWidget(
        project: project,
        onEdit: null,
        onShare: () => _shareProject(context, project),
        onDelete: null,
      );
    }
  }
  }

  Widget _buildAuthorizedActions(BuildContext context, Project project, user) {
    try {
      return PermissionBuilder(
        user: user,
        resource: 'projects',
        action: 'update',
        builder: (context, hasUpdatePermission) {
          if (hasUpdatePermission) {
            // Admin/Manager view with full actions
            return ProjectActionsWidget(
              project: project,
              onDailyReports: () => _navigateToDailyReports(context, project),
              onWorkRequests: () => _navigateToWorkRequests(context, project),
              onAddTask: () => _showAddTaskDialog(context, project),
              onProjectTeam: () => _showProjectTeamDialog(context, project),
            );
          } else {
            // Read-only view for regular users
            return _buildReadOnlyActions(context, project);
          }
        },
        // Fallback for when permission check fails - default to read-only view
        fallback: _buildReadOnlyActions(context, project),
      );
    } catch (e) {
      // Complete fallback if permission check throws an exception
      return _buildReadOnlyActions(context, project);
    }
  }
  }

  Widget _buildReadOnlyActions(BuildContext context, Project project) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'View Only Access',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'You have read-only access to this project. Contact your manager for update permissions.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToDailyReports(context, project),
                    icon: const Icon(Icons.assessment_outlined, size: 20),
                    label: const Text('View Reports'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToWorkRequests(context, project),
                    icon: const Icon(Icons.assignment_outlined, size: 20),
                    label: const Text('View Requests'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Project',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                _projectBloc.add(const ProjectLoadRequested());
              },
              child: const Text('Retry'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectNotFoundView(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Project Not Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The project you\'re looking for could not be found.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation helper methods
  void _editProject(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Project',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildEditSection(context, 'Basic Information', [
                      _buildEditOption(context, 'Project Name', project.projectName, Icons.title),
                      _buildEditOption(context, 'Address', project.address, Icons.location_on),
                      _buildEditOption(context, 'Client Information', project.clientInfo, Icons.business),
                    ]),
                    _buildEditSection(context, 'Timeline', [
                      _buildEditOption(context, 'Start Date', _formatDate(project.startDate), Icons.calendar_today),
                      _buildEditOption(context, 'Estimated End Date', _formatDate(project.estimatedEndDate), Icons.schedule),
                      _buildEditOption(context, 'Actual End Date', project.actualEndDate != null ? _formatDate(project.actualEndDate!) : 'Not set', Icons.check_circle),
                    ]),
                    _buildEditSection(context, 'Project Details', [
                      _buildEditOption(context, 'Status', project.status, Icons.info),
                      _buildEditOption(context, 'Description', project.description.isNotEmpty ? project.description : 'No description', Icons.description),
                      _buildEditOption(context, 'Location', project.location ?? 'Not specified', Icons.location_pin),
                    ]),
                    _buildEditSection(context, 'Financial', [
                      _buildEditOption(context, 'Budget', project.budget?.toString() ?? 'Not set', Icons.monetization_on),
                      _buildEditOption(context, 'Actual Cost', project.actualCost?.toString() ?? 'Not set', Icons.trending_up),
                      _buildEditOption(context, 'Progress', '${project.completionPercentage}%', Icons.analytics),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditSection(BuildContext context, String title, List<Widget> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...options,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEditOption(BuildContext context, String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit, size: 16),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Edit $label functionality will be implemented')),
        );
      },
    );
  }

  void _shareProject(BuildContext context, Project project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share project functionality coming soon')),
    );
  }

  void _deleteProject(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('Delete Project'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${project.projectName}"?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. All project data, reports, and associated files will be permanently deleted.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual project deletion API call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Project "${project.projectName}" deletion functionality will be implemented'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            child: const Text('Delete Project'),
          ),
        ],
      ),
    );
  }

  void _navigateToDailyReports(BuildContext context, Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailyReportsScreen(),
      ),
    );
  }

  void _navigateToWorkRequests(BuildContext context, Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyWorkRequestsScreen(),
      ),
    );
  }

  // Helper methods for authorized actions
  void _showAddTaskDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task creation functionality will be implemented')),
              );
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  void _showProjectTeamDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Project Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current team members:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            // TODO: Display actual team members from project data
            ListTile(
              leading: CircleAvatar(
                child: Text(project.projectManager?.name != null && project.projectManager!.name.isNotEmpty 
                    ? project.projectManager!.name.substring(0, 1) 
                    : 'PM'),
              ),
              title: Text(project.projectManager?.name ?? 'Project Manager'),
              subtitle: const Text('Project Manager'),
            ),
            const Divider(),
            const Text('Team management functionality will be implemented'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Team management functionality will be implemented')),
              );
            },
            child: const Text('Manage Team'),
          ),
        ],
      ),
    );
  }

  // Helper method for date formatting
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to safely check permissions
  bool _hasPermission(BuildContext context, User user, String resource, String action) {
    try {
      final authBloc = context.read<AuthorizationBloc>();
      final state = authBloc.state;
      
      if (state is AuthorizationLoaded) {
        return state.hasPermission(resource, action);
      } else {
        // If the authorization data isn't loaded yet, default to false
        return false;
      }
    } catch (e) {
      // In case of any errors like the 404 with role lookup, default to false
      print('Permission check error: $e');
      return false;
    }
  }
}