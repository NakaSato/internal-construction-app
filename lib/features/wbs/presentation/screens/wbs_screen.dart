import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../application/cubits/wbs_cubit.dart';
import '../../domain/entities/wbs_task.dart';
import '../../domain/usecases/wbs_usecases.dart';
import '../widgets/wbs_tree_widget.dart';
import '../widgets/wbs_task_details_widget.dart';
import '../widgets/wbs_progress_widget.dart';

class WbsScreen extends StatelessWidget {
  const WbsScreen({super.key, required this.projectId, this.projectName});

  final String projectId;
  final String? projectName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WbsCubit(
        getProjectWbs: getIt<GetProjectWbs>(),
        getWbsTask: getIt<GetWbsTask>(),
        createWbsTask: getIt<CreateWbsTask>(),
        updateWbsTask: getIt<UpdateWbsTask>(),
        updateTaskStatus: getIt<UpdateTaskStatus>(),
        deleteWbsTask: getIt<DeleteWbsTask>(),
      )..loadProjectWbs(projectId),
      child: WbsView(projectId: projectId, projectName: projectName),
    );
  }
}

class WbsView extends StatelessWidget {
  const WbsView({super.key, required this.projectId, this.projectName});

  final String projectId;
  final String? projectName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(projectName != null ? '$projectName - WBS' : 'Work Breakdown Structure'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh WBS data
              context.read<WbsCubit>().loadProjectWbs(
                (context.read<WbsCubit>().state as WbsLoaded).wbsStructure.projectId,
              );
            },
          ),
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showCreateTaskDialog(context)),
        ],
      ),
      body: BlocBuilder<WbsCubit, WbsState>(
        builder: (context, state) {
          if (state is WbsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WbsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading WBS',
                    style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<WbsCubit>().loadProjectWbs(projectId);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is WbsLoaded) {
            return _buildWbsContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildWbsContent(BuildContext context, WbsLoaded state) {
    final isTablet = MediaQuery.of(context).size.width > 768;

    if (isTablet) {
      // Two-pane layout for tablets
      return Row(
        children: [
          // Left pane - WBS tree and progress
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Progress summary
                WbsProgressWidget(wbsStructure: state.wbsStructure),
                const Divider(height: 1),
                // WBS tree
                Expanded(
                  child: WbsTreeWidget(
                    wbsStructure: state.wbsStructure,
                    selectedTask: state.selectedTask,
                    onTaskSelected: (task) {
                      context.read<WbsCubit>().selectTask(task.id);
                    },
                    onTaskStatusChanged: (taskId, status) {
                      context.read<WbsCubit>().updateTaskStatusOnly(taskId: taskId, status: status);
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Right pane - Task details
          Expanded(
            flex: 1,
            child: WbsTaskDetailsWidget(
              task: state.selectedTask,
              onTaskUpdated: (task) {
                context.read<WbsCubit>().updateTask(taskId: task.id, task: task);
              },
              onTaskDeleted: (taskId) {
                context.read<WbsCubit>().deleteTask(taskId);
              },
            ),
          ),
        ],
      );
    } else {
      // Single pane layout for mobile
      return Column(
        children: [
          // Progress summary (collapsed on mobile)
          WbsProgressWidget(wbsStructure: state.wbsStructure, isCollapsed: true),
          const Divider(height: 1),
          // WBS tree
          Expanded(
            child: WbsTreeWidget(
              wbsStructure: state.wbsStructure,
              selectedTask: state.selectedTask,
              onTaskSelected: (task) {
                context.read<WbsCubit>().selectTask(task.id);
                _showTaskDetailsBottomSheet(context, task);
              },
              onTaskStatusChanged: (taskId, status) {
                context.read<WbsCubit>().updateTaskStatusOnly(taskId: taskId, status: status);
              },
            ),
          ),
        ],
      );
    }
  }

  void _showTaskDetailsBottomSheet(BuildContext context, WbsTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: WbsTaskDetailsWidget(
                  task: task,
                  onTaskUpdated: (updatedTask) {
                    context.read<WbsCubit>().updateTask(taskId: updatedTask.id, task: updatedTask);
                    Navigator.of(context).pop();
                  },
                  onTaskDeleted: (taskId) {
                    context.read<WbsCubit>().deleteTask(taskId);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Task'),
        content: const Text('Task creation form would go here.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              // TODO: Implement task creation
              Navigator.of(context).pop();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
