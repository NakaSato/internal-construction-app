# Daily Reports Feature

## Overview
The daily reports feature allows users to create, view, and manage daily activity reports. It provides functionality for tracking work progress, logging activities, and generating daily summaries.

## Architecture Components

### Domain Layer
- **Entities**: DailyReport, ReportActivity, ReportStatus
- **Repositories**: DailyReportRepository
- **Use Cases**: GetDailyReportsUseCase, SubmitDailyReportUseCase, UpdateReportStatusUseCase

### Application Layer
- **State Management**: DailyReportBloc/Cubit
- **Events/States**: DailyReportEvent, DailyReportState

### Infrastructure Layer
- **Data Sources**: DailyReportRemoteDataSource, DailyReportLocalDataSource
- **Models**: DailyReportModel, ReportActivityModel
- **Repository Implementation**: DailyReportRepositoryImpl

### Presentation Layer
- **Screens**: DailyReportListScreen, CreateReportScreen, ReportDetailScreen
- **Widgets**: DailyReportCard, ActivityInputWidget, ReportSummaryChart
- **Pages**: DailyReportsPage, ReportHistoryPage

## Usage Examples

```dart
// Example: Submit a new daily report
final result = await submitDailyReportUseCase(
  SubmitDailyReportParams(
    report: DailyReport(
      date: DateTime.now(),
      activities: [
        ReportActivity(
          description: 'Completed UI implementation',
          duration: const Duration(hours: 4),
          projectId: 'project-123',
        ),
      ],
      notes: 'Focused on implementing the dashboard UI components',
    ),
  ),
);

result.fold(
  (failure) => handleFailure(failure),
  (success) => showSuccessMessage('Report submitted successfully'),
);
```

## API Integration

The daily reports feature integrates with the following endpoints:
- `GET /api/reports` - Get list of reports
- `POST /api/reports` - Create new report
- `GET /api/reports/{id}` - Get report details
- `PUT /api/reports/{id}` - Update report
- `GET /api/reports/statistics` - Get reporting statistics

## Related Features
- [Work Calendar](/docs/features/work_calendar/README.md)
- [Project Management](/docs/features/project_management/README.md)
- [Task Management](/docs/features/task_management/README.md)
