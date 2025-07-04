import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

import '../../lib/core/network/api_client.dart';
import '../../lib/core/network/models/api_response.dart';
import '../../lib/features/authentication/infrastructure/services/auth_api_service.dart';
import '../../lib/features/project_management/data/datasources/project_api_service.dart';
import '../../lib/features/task_management/infrastructure/services/task_api_service.dart';
import '../../lib/features/daily_reports/infrastructure/services/daily_reports_api_service.dart';
import '../../lib/features/work_calendar/infrastructure/services/calendar_api_service.dart';

// Mock class for ApiClient
class MockApiClient extends Mock implements ApiClient {
  @override
  Dio get dio => MockDio();
}

class MockDio extends Mock implements Dio {}

void main() {
  group('API Services Integration Tests', () {
    late MockApiClient mockApiClient;
    late MockDio mockDio;

    setUp(() {
      mockApiClient = MockApiClient();
      mockDio = MockDio();
    });

    test('AuthApiService can be instantiated', () {
      expect(() => AuthApiService(mockApiClient), isNot(throwsA(anything)));
    });

    test('ProjectApiService can be instantiated', () {
      expect(() => ProjectApiService(mockDio), isNot(throwsA(anything)));
    });

    test('TaskApiService can be instantiated', () {
      expect(() => TaskApiService(mockApiClient), isNot(throwsA(anything)));
    });

    test('DailyReportsApiService can be instantiated', () {
      expect(
        () => DailyReportsApiService(mockApiClient),
        isNot(throwsA(anything)),
      );
    });

    test('CalendarApiService can be instantiated', () {
      expect(() => CalendarApiService(mockApiClient), isNot(throwsA(anything)));
    });

    test('ApiResponse can handle success responses', () {
      const response = ApiResponse<String>(
        success: true,
        data: 'test data',
        message: 'Success',
      );

      expect(response.success, true);
      expect(response.data, 'test data');
      expect(response.message, 'Success');
    });

    test('ApiResponse can handle error responses', () {
      const response = ApiResponse<String>(
        success: false,
        data: null,
        message: 'Error occurred',
      );

      expect(response.success, false);
      expect(response.data, null);
      expect(response.message, 'Error occurred');
    });

    test('All API services are properly typed', () {
      final authService = AuthApiService(mockApiClient);
      final projectService = ProjectApiService(mockDio);
      final taskService = TaskApiService(mockApiClient);
      final reportsService = DailyReportsApiService(mockApiClient);
      final calendarService = CalendarApiService(mockApiClient);

      expect(authService, isA<AuthApiService>());
      expect(projectService, isA<ProjectApiService>());
      expect(taskService, isA<TaskApiService>());
      expect(reportsService, isA<DailyReportsApiService>());
      expect(calendarService, isA<CalendarApiService>());
    });
  });
}
