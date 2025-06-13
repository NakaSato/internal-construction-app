import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_architecture_app/features/calendar_management/domain/entities/calendar_event.dart';
import 'package:flutter_architecture_app/features/calendar_management/domain/repositories/calendar_management_repository.dart';
import 'package:flutter_architecture_app/features/calendar_management/application/calendar_management_bloc.dart';
import 'package:flutter_architecture_app/features/calendar_management/application/calendar_management_event.dart';
import 'package:flutter_architecture_app/features/calendar_management/application/calendar_management_state.dart';

import 'calendar_management_bloc_test.mocks.dart';

@GenerateMocks([CalendarManagementRepository])
void main() {
  group('CalendarManagementBloc', () {
    late MockCalendarManagementRepository mockRepository;
    late CalendarManagementBloc bloc;

    setUp(() {
      mockRepository = MockCalendarManagementRepository();
      bloc = CalendarManagementBloc(mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state should be CalendarManagementInitial', () {
      expect(bloc.state, isA<CalendarManagementInitial>());
    });

    group('CalendarEventsRequested', () {
      final testEvents = [
        CalendarEvent(
          id: '1',
          title: 'Test Event 1',
          startDateTime: DateTime(2024, 1, 1, 10, 0),
          endDateTime: DateTime(2024, 1, 1, 11, 0),
          eventType: CalendarEventType.meeting,
          status: CalendarEventStatus.scheduled,
          priority: CalendarEventPriority.high,
        ),
      ];

      final testResponse = CalendarEventListResponse(
        events: testEvents,
        totalCount: 1,
        page: 1,
        pageSize: 10,
        totalPages: 1,
        hasPreviousPage: false,
        hasNextPage: false,
      );

      blocTest<CalendarManagementBloc, CalendarManagementState>(
        'emits [loading, loaded] when events are loaded successfully',
        build: () {
          when(
            mockRepository.getAllEvents(),
          ).thenAnswer((_) async => testResponse);
          return bloc;
        },
        act: (bloc) => bloc.add(const CalendarEventsRequested()),
        expect: () => [
          const CalendarManagementLoading(),
          CalendarEventsLoaded(
            events: testEvents,
            totalCount: 1,
            page: 1,
            pageSize: 10,
            totalPages: 1,
            hasPreviousPage: false,
            hasNextPage: false,
          ),
        ],
        verify: (_) {
          verify(mockRepository.getAllEvents()).called(1);
        },
      );

      blocTest<CalendarManagementBloc, CalendarManagementState>(
        'emits [loading, error] when loading events fails',
        build: () {
          when(
            mockRepository.getAllEvents(),
          ).thenThrow(Exception('Failed to load events'));
          return bloc;
        },
        act: (bloc) => bloc.add(const CalendarEventsRequested()),
        expect: () => [
          const CalendarManagementLoading(),
          const CalendarManagementError(
            'Failed to load calendar events: Exception: Failed to load events',
          ),
        ],
      );
    });
  });
}
