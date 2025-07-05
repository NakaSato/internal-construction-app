import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../../common/widgets/enhanced_error_widget.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/realtime_api_streams.dart';
import '../../../../core/di/injection.dart';
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
  StreamSubscription<RealtimeProjectUpdate>? _realtimeSubscription;
  late RealtimeApiStreams _realtimeStreams;
  bool _isRealtimeConnected = false;
  EnhancedProject? _currentProject;

  @override
  void initState() {
    super.initState();
    _initializeRealtime();
    _loadProject();
  }

  @override
  void dispose() {
    // Stop real-time updates through BLoC
    context.read<EnhancedProjectBloc>().add(const StopProjectRealtimeUpdates());
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  void _initializeRealtime() {
    _realtimeStreams = getIt<RealtimeApiStreams>();

    // Initialize real-time connection
    _realtimeStreams
        .initialize()
        .then((_) {
          setState(() {
            _isRealtimeConnected = _realtimeStreams.isConnected;
          });

          // Start real-time updates through BLoC
          context.read<EnhancedProjectBloc>().add(const StartProjectRealtimeUpdates());

          // Subscribe to project updates directly for UI feedback
          _realtimeSubscription = _realtimeStreams.projectsStream.listen(
            (update) => _handleRealtimeUpdate(update),
            onError: (error) {
              debugPrint('❌ Real-time error: $error');
              setState(() {
                _isRealtimeConnected = false;
              });
            },
          );
        })
        .catchError((error) {
          debugPrint('❌ Failed to initialize real-time: $error');
        });
  }

  void _handleRealtimeUpdate(RealtimeProjectUpdate update) {
    // Only process updates for the current project for UI feedback
    if (update.projectId == widget.projectId || (update.project?.projectId == widget.projectId)) {
      switch (update.type) {
        case 'update':
          // Show snackbar for real-time update (BLoC handles the state)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.update, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Project updated in real-time'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          break;

        case 'delete':
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Project was deleted'),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );

            // Navigate back to projects list
            context.go(AppRoutes.projects);
          }
          break;
      }
    }
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
        actions: [
          // Real-time connection indicator
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isRealtimeConnected ? Icons.wifi : Icons.wifi_off,
                    color: _isRealtimeConnected ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isRealtimeConnected ? 'Live' : 'Offline',
                    style: TextStyle(
                      color: _isRealtimeConnected ? Colors.green : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    // Store current project for real-time comparison
    _currentProject = project;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Real-time status indicator
          if (_isRealtimeConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.live_tv, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Real-time updates enabled',
                    style: TextStyle(color: Colors.green.shade700, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  ),
                ],
              ),
            ),

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.projectName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Real-time sync indicator
                    if (_isRealtimeConnected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sync, color: Colors.green, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
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

          // Real-time update timestamp
          if (_isRealtimeConnected) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Last updated: ${DateTime.now().toLocal().toString().split('.')[0]}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
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
      return Column(
        children: [
          NetworkErrorWidget(message: message, onRetry: _loadProject),
          // Add real-time reconnection button for network errors
          if (!_isRealtimeConnected) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _initializeRealtime,
                icon: const Icon(Icons.wifi),
                label: const Text('Reconnect Real-time Updates'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ],
      );
    }

    // Generic enhanced error widget for other cases with real-time info
    return Column(
      children: [
        EnhancedErrorWidget(
          message: message,
          onRetry: _loadProject,
          showDetails: true,
          errorDetails:
              '''
Project ID: ${widget.projectId}
Real-time Status: ${_isRealtimeConnected ? 'Connected' : 'Disconnected'}
Error: $message''',
        ),
        // Add real-time troubleshooting
        if (!_isRealtimeConnected) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton.icon(
              onPressed: _initializeRealtime,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Real-time Connection'),
              style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            ),
          ),
        ],
      ],
    );
  }
}
