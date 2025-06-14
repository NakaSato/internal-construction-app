import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../application/project_bloc.dart';
import '../../application/project_event.dart';
import '../../application/project_state.dart';
import '../../domain/entities/project.dart';
import '../widgets/project_card.dart';

/// Screen to display projects in a card list format
class ProjectCardListScreen extends StatefulWidget {
  const ProjectCardListScreen({super.key});

  @override
  State<ProjectCardListScreen> createState() => _ProjectCardListScreenState();
}

class _ProjectCardListScreenState extends State<ProjectCardListScreen> {
  late ProjectBloc _projectBloc;

  @override
  void initState() {
    super.initState();
    _projectBloc = getIt<ProjectBloc>();
    _projectBloc.add(const ProjectLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Project Cards',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _projectBloc.add(const ProjectLoadRequested());
            },
            tooltip: 'Refresh projects',
          ),
        ],
      ),
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
                    Text(
                      'Loading projects...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ProjectError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load projects',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          _projectBloc.add(const ProjectLoadRequested());
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ProjectLoaded) {
              return _buildProjectList(state.projects);
            }

            return const Center(child: Text('No projects found'));
          },
        ),
      ),
    );
  }

  Widget _buildProjectList(List<Project> projects) {
    return RefreshIndicator(
      onRefresh: () async {
        _projectBloc.add(const ProjectLoadRequested());
      },
      child: projects.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProjectCard(
                    project: project,
                    onTap: () => _showProjectDetails(project),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Projects Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'There are no projects available at the moment.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectDetails(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project.projectName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Address', project.address),
              _buildDetailRow('Client', project.clientInfo),
              _buildDetailRow('Status', project.status),
              _buildDetailRow(
                'Start Date',
                project.startDate.toString().split(' ')[0],
              ),
              _buildDetailRow(
                'End Date',
                project.estimatedEndDate.toString().split(' ')[0],
              ),
              if (project.projectManager != null) ...[
                _buildDetailRow('Manager', project.projectManager!.fullName),
                _buildDetailRow('Manager Email', project.projectManager!.email),
              ],
              _buildDetailRow(
                'Tasks',
                '${project.completedTaskCount}/${project.taskCount}',
              ),
              _buildDetailRow('Progress', '${project.completionPercentage}%'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
