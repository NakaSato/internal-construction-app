import 'package:equatable/equatable.dart';

import '../domain/entities/task.dart' as task_entity;

/// Events for the TaskBloc
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all tasks
class TasksLoadRequested extends TaskEvent {
  const TasksLoadRequested();
}

/// Event to load a single task
class TaskLoadRequested extends TaskEvent {
  final String taskId;

  const TaskLoadRequested(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Event to load tasks for a specific project
class ProjectTasksLoadRequested extends TaskEvent {
  final String projectId;

  const ProjectTasksLoadRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Event to load tasks assigned to a specific user
class AssigneeTasksLoadRequested extends TaskEvent {
  final String assigneeId;

  const AssigneeTasksLoadRequested(this.assigneeId);

  @override
  List<Object?> get props => [assigneeId];
}

/// Event to create a new task
class TaskCreated extends TaskEvent {
  final task_entity.Task task;

  const TaskCreated(this.task);

  @override
  List<Object?> get props => [task];
}

/// Event to update an existing task
class TaskUpdated extends TaskEvent {
  final task_entity.Task task;

  const TaskUpdated(this.task);

  @override
  List<Object?> get props => [task];
}

/// Event to delete a task
class TaskDeleted extends TaskEvent {
  final String taskId;

  const TaskDeleted(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Event to update task status
class TaskStatusUpdated extends TaskEvent {
  final String taskId;
  final task_entity.TaskStatus status;

  const TaskStatusUpdated({required this.taskId, required this.status});

  @override
  List<Object?> get props => [taskId, status];
}

/// Event to update task completion percentage
class TaskCompletionUpdated extends TaskEvent {
  final String taskId;
  final int percentage;

  const TaskCompletionUpdated({required this.taskId, required this.percentage});

  @override
  List<Object?> get props => [taskId, percentage];
}
