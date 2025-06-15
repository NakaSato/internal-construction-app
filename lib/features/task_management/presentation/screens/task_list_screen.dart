import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../application/task_bloc.dart';
import '../../application/task_event.dart';
import '../../application/task_state.dart';
import '../../domain/entities/task.dart' as task_entity;

/// Screen to display and manage tasks
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskBloc>(
      create: (context) => getIt<TaskBloc>()..add(const TasksLoadRequested()),
      child: const TaskListView(),
    );
  }
}

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskError) {
            return Center(
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
                    'Error Loading Tasks',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TaskBloc>().add(const TasksLoadRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TasksLoaded) {
            final tasks = state.tasks;

            if (tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Tasks Found',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'There are no tasks to display.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(task.status, theme),
                      child: Icon(
                        _getStatusIcon(task.status),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(task.title, style: theme.textTheme.titleMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description.isNotEmpty) Text(task.description),
                        const SizedBox(height: 4),
                        Text(
                          'Due: ${_formatDate(task.dueDate)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        task.status.name,
                        style: theme.textTheme.labelSmall,
                      ),
                      backgroundColor: _getStatusColor(
                        task.status,
                        theme,
                      ).withOpacity(0.2),
                    ),
                    onTap: () {
                      // TODO: Navigate to task detail
                    },
                  ),
                );
              },
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Color _getStatusColor(task_entity.TaskStatus status, ThemeData theme) {
    switch (status) {
      case task_entity.TaskStatus.todo:
        return Colors.grey;
      case task_entity.TaskStatus.inProgress:
        return Colors.blue;
      case task_entity.TaskStatus.review:
        return Colors.orange;
      case task_entity.TaskStatus.completed:
        return Colors.green;
      case task_entity.TaskStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(task_entity.TaskStatus status) {
    switch (status) {
      case task_entity.TaskStatus.todo:
        return Icons.circle_outlined;
      case task_entity.TaskStatus.inProgress:
        return Icons.trending_up;
      case task_entity.TaskStatus.review:
        return Icons.rate_review;
      case task_entity.TaskStatus.completed:
        return Icons.check_circle;
      case task_entity.TaskStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
