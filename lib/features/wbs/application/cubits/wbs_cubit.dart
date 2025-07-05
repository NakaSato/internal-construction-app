import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/wbs_task.dart';
import '../../domain/entities/wbs_structure.dart';
import '../../domain/entities/wbs_progress.dart';
import '../../domain/usecases/wbs_usecases.dart';

// States
abstract class WbsState extends Equatable {
  const WbsState();

  @override
  List<Object?> get props => [];
}

class WbsInitial extends WbsState {}

class WbsLoading extends WbsState {}

class WbsLoaded extends WbsState {
  const WbsLoaded({required this.wbsStructure, this.selectedTask, this.progress});

  final WbsStructure wbsStructure;
  final WbsTask? selectedTask;
  final WbsProgressSummary? progress;

  @override
  List<Object?> get props => [wbsStructure, selectedTask, progress];

  WbsLoaded copyWith({WbsStructure? wbsStructure, WbsTask? selectedTask, WbsProgressSummary? progress}) {
    return WbsLoaded(
      wbsStructure: wbsStructure ?? this.wbsStructure,
      selectedTask: selectedTask ?? this.selectedTask,
      progress: progress ?? this.progress,
    );
  }
}

class WbsError extends WbsState {
  const WbsError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

// Cubit
class WbsCubit extends Cubit<WbsState> {
  WbsCubit({
    required this.getProjectWbs,
    required this.getWbsTask,
    required this.createWbsTask,
    required this.updateWbsTask,
    required this.updateTaskStatus,
    required this.deleteWbsTask,
  }) : super(WbsInitial());

  final GetProjectWbs getProjectWbs;
  final GetWbsTask getWbsTask;
  final CreateWbsTask createWbsTask;
  final UpdateWbsTask updateWbsTask;
  final UpdateTaskStatus updateTaskStatus;
  final DeleteWbsTask deleteWbsTask;

  Future<void> loadProjectWbs(String projectId) async {
    emit(WbsLoading());

    final result = await getProjectWbs(GetProjectWbsParams(projectId: projectId));

    result.fold(
      (failure) => emit(WbsError(failure.message)),
      (wbsStructure) => emit(WbsLoaded(wbsStructure: wbsStructure)),
    );
  }

  Future<void> selectTask(String taskId) async {
    if (state is! WbsLoaded) return;

    final currentState = state as WbsLoaded;
    emit(WbsLoading());

    final result = await getWbsTask(GetWbsTaskParams(taskId: taskId));

    result.fold(
      (failure) => emit(WbsError(failure.message)),
      (task) => emit(currentState.copyWith(selectedTask: task)),
    );
  }

  Future<void> updateTaskStatusOnly({
    required String taskId,
    required WbsTaskStatus status,
    String? completionNotes,
    String? completedBy,
  }) async {
    if (state is! WbsLoaded) return;

    final currentState = state as WbsLoaded;

    final result = await updateTaskStatus(
      UpdateTaskStatusParams(
        taskId: taskId,
        status: status,
        completionNotes: completionNotes,
        completedBy: completedBy,
      ),
    );

    result.fold((failure) => emit(WbsError(failure.message)), (updatedTask) {
      // Update the task in the structure
      final updatedStructure = _updateTaskInStructure(currentState.wbsStructure, updatedTask);
      emit(currentState.copyWith(wbsStructure: updatedStructure, selectedTask: updatedTask));
    });
  }

  Future<void> createTask({required String projectId, required WbsTask task}) async {
    if (state is! WbsLoaded) return;

    final currentState = state as WbsLoaded;

    final result = await createWbsTask(CreateWbsTaskParams(projectId: projectId, task: task));

    result.fold((failure) => emit(WbsError(failure.message)), (newTask) {
      // Add the new task to the structure
      final updatedStructure = _addTaskToStructure(currentState.wbsStructure, newTask);
      emit(currentState.copyWith(wbsStructure: updatedStructure));
    });
  }

  Future<void> updateTask({required String taskId, required WbsTask task}) async {
    if (state is! WbsLoaded) return;

    final currentState = state as WbsLoaded;

    final result = await updateWbsTask(UpdateWbsTaskParams(taskId: taskId, task: task));

    result.fold((failure) => emit(WbsError(failure.message)), (updatedTask) {
      // Update the task in the structure
      final updatedStructure = _updateTaskInStructure(currentState.wbsStructure, updatedTask);
      emit(currentState.copyWith(wbsStructure: updatedStructure, selectedTask: updatedTask));
    });
  }

  Future<void> deleteTask(String taskId) async {
    if (state is! WbsLoaded) return;

    final currentState = state as WbsLoaded;

    final result = await deleteWbsTask(DeleteWbsTaskParams(taskId: taskId));

    result.fold((failure) => emit(WbsError(failure.message)), (_) {
      // Remove the task from the structure
      final updatedStructure = _removeTaskFromStructure(currentState.wbsStructure, taskId);
      emit(
        currentState.copyWith(
          wbsStructure: updatedStructure,
          selectedTask: currentState.selectedTask?.id == taskId ? null : currentState.selectedTask,
        ),
      );
    });
  }

  void clearSelection() {
    if (state is WbsLoaded) {
      final currentState = state as WbsLoaded;
      emit(currentState.copyWith(selectedTask: null));
    }
  }

  // Helper methods
  WbsStructure _updateTaskInStructure(WbsStructure structure, WbsTask updatedTask) {
    final updatedRootTasks = _updateTaskInList(structure.rootTasks, updatedTask);
    return structure.copyWith(rootTasks: updatedRootTasks);
  }

  List<WbsTask> _updateTaskInList(List<WbsTask> tasks, WbsTask updatedTask) {
    return tasks.map((task) {
      if (task.id == updatedTask.id) {
        return updatedTask;
      } else if (task.children.isNotEmpty) {
        return task.copyWith(children: _updateTaskInList(task.children, updatedTask));
      }
      return task;
    }).toList();
  }

  WbsStructure _addTaskToStructure(WbsStructure structure, WbsTask newTask) {
    final updatedRootTasks = [...structure.rootTasks, newTask];
    return structure.copyWith(rootTasks: updatedRootTasks, totalTasks: structure.totalTasks + 1);
  }

  WbsStructure _removeTaskFromStructure(WbsStructure structure, String taskId) {
    final updatedRootTasks = _removeTaskFromList(structure.rootTasks, taskId);
    return structure.copyWith(rootTasks: updatedRootTasks, totalTasks: structure.totalTasks - 1);
  }

  List<WbsTask> _removeTaskFromList(List<WbsTask> tasks, String taskId) {
    return tasks
        .where((task) => task.id != taskId)
        .map(
          (task) =>
              task.children.isNotEmpty ? task.copyWith(children: _removeTaskFromList(task.children, taskId)) : task,
        )
        .toList();
  }
}
