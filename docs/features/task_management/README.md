# Task Management Feature

## Overview
The task management feature enables users to create, assign, track, and complete tasks within projects. It provides capabilities for task prioritization, status tracking, and collaboration.

## Architecture Components

### Domain Layer
- **Entities**: Task, TaskStatus, TaskPriority, TaskAssignment
- **Repositories**: TaskRepository
- **Use Cases**: GetTasksUseCase, CreateTaskUseCase, UpdateTaskStatusUseCase, AssignTaskUseCase

### Application Layer
- **State Management**: TaskBloc/Cubit
- **Events/States**: TaskEvent, TaskState

### Infrastructure Layer
- **Data Sources**: TaskRemoteDataSource, TaskLocalDataSource
- **Models**: TaskModel, TaskAssignmentModel
- **Repository Implementation**: TaskRepositoryImpl

### Presentation Layer
- **Screens**: TaskListScreen, TaskDetailScreen, CreateTaskScreen
- **Widgets**: TaskCard, StatusSelector, PriorityBadge, AssigneeSelector
- **Pages**: TasksPage, MyTasksPage

## Usage Examples

```dart
// Example: Create a new task
final result = await createTaskUseCase(
  CreateTaskParams(
    task: Task(
      title: 'Implement login screen',
      description: 'Create UI and integrate with API',
      projectId: 'project-123',
      priority: TaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 3)),
    ),
  ),
);

result.fold(
  (failure) => handleFailure(failure),
  (task) => navigateToTaskDetails(task),
);

// Example: Update task status
final updateResult = await updateTaskStatusUseCase(
  UpdateTaskStatusParams(
    taskId: 'task-123',
    status: TaskStatus.inProgress,
  ),
);

updateResult.fold(
  (failure) => handleFailure(failure),
  (_) => refreshTaskList(),
);
```

## API Integration

The task management feature integrates with the following endpoints:
- `GET /api/tasks` - Get list of tasks
- `POST /api/tasks` - Create new task
- `GET /api/tasks/{id}` - Get task details
- `PUT /api/tasks/{id}` - Update task
- `PUT /api/tasks/{id}/status` - Update task status
- `PUT /api/tasks/{id}/assign` - Assign task to user

## Related Features
- [Project Management](/docs/features/project_management/README.md)
- [Work Calendar](/docs/features/work_calendar/README.md)
- [Daily Reports](/docs/features/daily_reports/README.md)
