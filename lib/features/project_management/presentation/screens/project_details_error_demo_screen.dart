import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/enhanced_error_widget.dart';
import '../../../../core/navigation/app_router.dart';
import '../../application/project_bloc.dart';
import '../../domain/entities/project_api_models.dart';

/// Example project details screen demonstrating enhanced error handling
class ProjectDetailsErrorDemoScreen extends StatefulWidget {
  const ProjectDetailsErrorDemoScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProjectDetailsErrorDemoScreen> createState() => _ProjectDetailsErrorDemoScreenState();
}

class _ProjectDetailsErrorDemoScreenState extends State<ProjectDetailsErrorDemoScreen> {
  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  void _loadProject() {
    context.read<EnhancedProjectBloc>().add(LoadProjectDetailsRequested(projectId: widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(AppRoutes.projects)),
      ),
      body: BlocBuilder<EnhancedProjectBloc, EnhancedProjectState>(
        builder: (context, state) {
          return switch (state) {
            EnhancedProjectInitial() => const Center(child: Text('Ready to load project details')),

            EnhancedProjectLoading() => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Loading project details...')],
              ),
            ),

            EnhancedProjectDetailsLoaded(project: final project) => _buildProjectDetails(project),

            EnhancedProjectError(message: final message) => _buildErrorView(message),

            _ => const Center(child: Text('Unexpected state')),
          };
        },
      ),
    );
  }

  Widget _buildProjectDetails(EnhancedProject project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.projectName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${project.projectId}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    fontFamily: 'monospace',
                  ),
                ),
                if (project.address.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    project.address,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Project details
          _buildDetailCard(icon: Icons.flag_rounded, title: 'Status', value: project.status),

          const SizedBox(height: 12),

          _buildDetailCard(
            icon: Icons.person_rounded,
            title: 'Manager',
            value: project.projectManager?.fullName ?? 'Not assigned',
          ),

          const SizedBox(height: 12),

          _buildDetailCard(
            icon: Icons.calendar_today_rounded,
            title: 'Start Date',
            value: project.startDate.toString().split(' ')[0],
          ),

          const SizedBox(height: 12),

          _buildDetailCard(
            icon: Icons.event_rounded,
            title: 'Estimated End Date',
            value: project.estimatedEndDate.toString().split(' ')[0],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({required IconData icon, required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildErrorView(String message) {
    // Check for specific error types and show appropriate error widgets
    if (message.contains('not found') || message.contains('does not exist')) {
      return ProjectNotFoundWidget(
        projectId: widget.projectId,
        onGoBack: () => context.go(AppRoutes.projects),
        onGoHome: () => context.go(AppRoutes.home),
      );
    }

    if (message.contains('Connection') || message.contains('Network')) {
      return NetworkErrorWidget(message: message, onRetry: _loadProject);
    }

    // Generic enhanced error widget for other cases
    return EnhancedErrorWidget(
      message: message,
      onRetry: _loadProject,
      showDetails: true,
      errorDetails: 'Project ID: ${widget.projectId}\nError: $message',
    );
  }
}
