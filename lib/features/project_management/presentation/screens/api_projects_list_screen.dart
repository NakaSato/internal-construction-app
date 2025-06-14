import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../application/project_bloc.dart';
import '../../application/project_event.dart';
import '../../application/project_state.dart';
import '../../domain/entities/project.dart';
import '../widgets/project_card.dart';

/// Screen to display projects loaded from real API with pagination
class ApiProjectsListScreen extends StatefulWidget {
  const ApiProjectsListScreen({super.key});

  @override
  State<ApiProjectsListScreen> createState() => _ApiProjectsListScreenState();
}

class _ApiProjectsListScreenState extends State<ApiProjectsListScreen> {
  final ScrollController _scrollController = ScrollController();
  late ProjectBloc _projectBloc;

  @override
  void initState() {
    super.initState();
    _projectBloc = getIt<ProjectBloc>();
    _scrollController.addListener(_onScroll);
    // Load first page of projects
    _projectBloc.add(const ProjectLoadWithPaginationRequested(refresh: true));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _projectBloc.add(const ProjectLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'API Projects',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _projectBloc.add(
                const ProjectLoadWithPaginationRequested(refresh: true),
              );
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
                      'Loading projects from API...',
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
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        _projectBloc.add(
                          const ProjectLoadWithPaginationRequested(
                            refresh: true,
                          ),
                        );
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
              );
            }

            if (state is ProjectLoadedWithPagination) {
              return _buildProjectList(state);
            }

            if (state is ProjectLoaded) {
              return _buildSimpleProjectList(state.projects);
            }

            return const Center(child: Text('No projects found'));
          },
        ),
      ),
    );
  }

  Widget _buildProjectList(ProjectLoadedWithPagination state) {
    return RefreshIndicator(
      onRefresh: () async {
        _projectBloc.add(
          const ProjectLoadWithPaginationRequested(refresh: true),
        );
      },
      child: Column(
        children: [
          // Pagination info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Page ${state.currentPage} of ${state.totalPages} • ${state.totalCount} total projects',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Projects list
          Expanded(
            child: state.projects.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.hasReachedMax
                        ? state.projects.length
                        : state.projects.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= state.projects.length) {
                        return _buildLoadingIndicator();
                      }

                      final project = state.projects[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ProjectCard(
                          project: project,
                          onTap: () => _showProjectDetails(project),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleProjectList(List<Project> projects) {
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

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Loading more projects...',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Projects Found',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no projects available at the moment.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
