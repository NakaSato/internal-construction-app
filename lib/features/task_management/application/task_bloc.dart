import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/usecases/task_usecases.dart';
import '../../../../core/usecases/usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

/// BLoC for managing task-related state
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks _getTasks;
  final GetTaskById _getTaskById;
  final GetTasksByProject _getTasksByProject;
  final CreateTask _createTask;
  final UpdateTask _updateTask;

  TaskBloc({
    required GetTasks getTasks,
    required GetTaskById getTaskById,
    required GetTasksByProject getTasksByProject,
    required CreateTask createTask,
    required UpdateTask updateTask,
  }) : _getTasks = getTasks,
       _getTaskById = getTaskById,
       _getTasksByProject = getTasksByProject,
       _createTask = createTask,
       _updateTask = updateTask,
       super(const TaskInitial()) {
    on<TasksLoadRequested>(_onTasksLoadRequested);
    on<TaskLoadRequested>(_onTaskLoadRequested);
    on<ProjectTasksLoadRequested>(_onProjectTasksLoadRequested);
    on<TaskCreated>(_onTaskCreated);
    on<TaskUpdated>(_onTaskUpdated);
  }

  Future<void> _onTasksLoadRequested(
    TasksLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());

    final result = await _getTasks(NoParams());

    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TasksLoaded(tasks)),
    );
  }

  Future<void> _onTaskLoadRequested(
    TaskLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());

    final result = await _getTaskById(TaskParams(taskId: event.taskId));

    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (task) => emit(TaskLoaded(task)),
    );
  }

  Future<void> _onProjectTasksLoadRequested(
    ProjectTasksLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());

    final result = await _getTasksByProject(
      ProjectTasksParams(projectId: event.projectId),
    );

    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TasksLoaded(tasks)),
    );
  }

  Future<void> _onTaskCreated(
    TaskCreated event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());

    final result = await _createTask(CreateTaskParams(task: event.task));

    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (task) => emit(TaskCreateSuccess(task)),
    );
  }

  Future<void> _onTaskUpdated(
    TaskUpdated event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());

    final result = await _updateTask(UpdateTaskParams(task: event.task));

    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (task) => emit(TaskUpdateSuccess(task)),
    );
  }
}
