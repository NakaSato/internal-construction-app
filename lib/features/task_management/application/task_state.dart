import 'package:equatable/equatable.dart';

import '../domain/entities/task.dart' as task_entity;

/// States for the TaskBloc
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TaskInitial extends TaskState {
  const TaskInitial();
}

/// Loading state
class TaskLoading extends TaskState {
  const TaskLoading();
}

/// State when tasks are loaded successfully
class TasksLoaded extends TaskState {
  final List<task_entity.Task> tasks;

  const TasksLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

/// State when a single task is loaded
class TaskLoaded extends TaskState {
  final task_entity.Task task;

  const TaskLoaded(this.task);

  @override
  List<Object?> get props => [task];
}

/// State when task is created successfully
class TaskCreateSuccess extends TaskState {
  final task_entity.Task task;

  const TaskCreateSuccess(this.task);

  @override
  List<Object?> get props => [task];
}

/// State when task is updated successfully
class TaskUpdateSuccess extends TaskState {
  final task_entity.Task task;

  const TaskUpdateSuccess(this.task);

  @override
  List<Object?> get props => [task];
}

/// State when task is deleted successfully
class TaskDeleted extends TaskState {
  final String taskId;

  const TaskDeleted(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Error state
class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
