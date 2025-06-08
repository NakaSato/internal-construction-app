import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_architecture_app/features/work_calendar/application/work_calendar_bloc.dart';
import 'package:flutter_architecture_app/features/work_calendar/application/work_calendar_event.dart';
import 'package:flutter_architecture_app/features/work_calendar/application/work_calendar_state.dart';
import 'package:flutter_architecture_app/features/work_calendar/domain/entities/work_event.dart';

import '../../../test_helpers/test_helpers.mocks.dart';

void main() {
  late WorkCalendarBloc bloc;
  late MockWorkCalendarRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkCalendarRepository();
    bloc = WorkCalendarBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('WorkCalendarBloc', () {
    final testEvent = WorkEvent(
      id: 'event_123',
      title: 'Test Meeting',
      description: 'Test meeting description',
      startTime: DateTime(2024, 1, 1, 10, 0),
      endTime: DateTime(2024, 1, 1, 11, 0),
      eventType: WorkEventType.meeting,
      isAllDay: false,
      location: 'Conference Room A',
      attendees: ['john@example.com', 'jane@example.com'],
    );

    final List<WorkEvent> testEventList = [testEvent];
    final testStartDate = DateTime(2024, 1, 1);
    final testEndDate = DateTime(2024, 1, 31);

    test('initial state is WorkCalendarInitial', () {
      expect(bloc.state, const WorkCalendarInitial());
    });

    group('CalendarEventsRequested', () {
      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarLoading, CalendarEventsLoaded] when events are loaded successfully',
        build: () {
          when(
            mockRepository.getEventsInRange(testStartDate, testEndDate),
          ).thenAnswer((_) async => testEventList);
          return bloc;
        },
        act: (bloc) => bloc.add(
          CalendarEventsRequested(
            startDate: testStartDate,
            endDate: testEndDate,
          ),
        ),
        expect: () => [
          const WorkCalendarLoading(),
          CalendarEventsLoaded(
            events: testEventList,
            currentDate: testStartDate,
            viewType: CalendarViewType.month,
          ),
        ],
        verify: (_) {
          verify(
            mockRepository.getEventsInRange(testStartDate, testEndDate),
          ).called(1);
        },
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarLoading, WorkCalendarError] when loading events fails',
        build: () {
          when(
            mockRepository.getEventsInRange(testStartDate, testEndDate),
          ).thenThrow(Exception('Network error'));
          return bloc;
        },
        act: (bloc) => bloc.add(
          CalendarEventsRequested(
            startDate: testStartDate,
            endDate: testEndDate,
          ),
        ),
        expect: () => [
          const WorkCalendarLoading(),
          const WorkCalendarError(
            'Failed to load calendar events: Exception: Network error',
          ),
        ],
      );
    });

    group('DayEventsRequested', () {
      final testDate = DateTime(2024, 1, 1);

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarLoading, DayEventsLoaded] when day events are loaded successfully',
        build: () {
          when(
            mockRepository.getEventsForDate(testDate),
          ).thenAnswer((_) async => testEventList);
          return bloc;
        },
        act: (bloc) => bloc.add(DayEventsRequested(testDate)),
        expect: () => [
          const WorkCalendarLoading(),
          DayEventsLoaded(date: testDate, events: testEventList),
        ],
        verify: (_) {
          verify(mockRepository.getEventsForDate(testDate)).called(1);
        },
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarLoading, WorkCalendarError] when loading day events fails',
        build: () {
          when(
            mockRepository.getEventsForDate(testDate),
          ).thenThrow(Exception('Database error'));
          return bloc;
        },
        act: (bloc) => bloc.add(DayEventsRequested(testDate)),
        expect: () => [
          const WorkCalendarLoading(),
          const WorkCalendarError(
            'Failed to load day events: Exception: Database error',
          ),
        ],
      );
    });

    group('WorkEventCreated', () {
      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkEventCreatedSuccess] when event is created successfully',
        build: () {
          when(
            mockRepository.createEvent(testEvent),
          ).thenAnswer((_) async => testEvent);
          return bloc;
        },
        act: (bloc) => bloc.add(WorkEventCreated(testEvent)),
        expect: () => [WorkEventCreatedSuccess(testEvent)],
        verify: (_) {
          verify(mockRepository.createEvent(testEvent)).called(1);
        },
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkEventCreatedSuccess, WorkCalendarLoading, CalendarEventsLoaded] when event is created and calendar is loaded',
        build: () {
          when(
            mockRepository.createEvent(testEvent),
          ).thenAnswer((_) async => testEvent);
          when(
            mockRepository.getEventsInRange(any, any),
          ).thenAnswer((_) async => testEventList);
          return bloc;
        },
        seed: () => CalendarEventsLoaded(
          events: [],
          currentDate: testStartDate,
          viewType: CalendarViewType.month,
        ),
        act: (bloc) => bloc.add(WorkEventCreated(testEvent)),
        expect: () => [
          WorkEventCreatedSuccess(testEvent),
          const WorkCalendarLoading(),
          CalendarEventsLoaded(
            events: testEventList,
            currentDate: testStartDate,
            viewType: CalendarViewType.month,
          ),
        ],
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarError] when creating event fails',
        build: () {
          when(
            mockRepository.createEvent(testEvent),
          ).thenThrow(Exception('Validation error'));
          return bloc;
        },
        act: (bloc) => bloc.add(WorkEventCreated(testEvent)),
        expect: () => [
          const WorkCalendarError(
            'Failed to create event: Exception: Validation error',
          ),
        ],
      );
    });

    group('WorkEventUpdated', () {
      final updatedEvent = testEvent.copyWith(title: 'Updated Meeting');

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkEventUpdatedSuccess] when event is updated successfully',
        build: () {
          when(
            mockRepository.updateEvent(updatedEvent),
          ).thenAnswer((_) async => updatedEvent);
          return bloc;
        },
        act: (bloc) => bloc.add(WorkEventUpdated(updatedEvent)),
        expect: () => [WorkEventUpdatedSuccess(updatedEvent)],
        verify: (_) {
          verify(mockRepository.updateEvent(updatedEvent)).called(1);
        },
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkEventUpdatedSuccess, WorkCalendarLoading, CalendarEventsLoaded] when event is updated and calendar is loaded',
        build: () {
          when(
            mockRepository.updateEvent(updatedEvent),
          ).thenAnswer((_) async => updatedEvent);
          when(
            mockRepository.getEventsInRange(any, any),
          ).thenAnswer((_) async => [updatedEvent]);
          return bloc;
        },
        seed: () => CalendarEventsLoaded(
          events: testEventList,
          currentDate: testStartDate,
          viewType: CalendarViewType.month,
        ),
        act: (bloc) => bloc.add(WorkEventUpdated(updatedEvent)),
        expect: () => [
          WorkEventUpdatedSuccess(updatedEvent),
          const WorkCalendarLoading(),
          CalendarEventsLoaded(
            events: [updatedEvent],
            currentDate: testStartDate,
            viewType: CalendarViewType.month,
          ),
        ],
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarError] when updating event fails',
        build: () {
          when(
            mockRepository.updateEvent(updatedEvent),
          ).thenThrow(Exception('Permission denied'));
          return bloc;
        },
        act: (bloc) => bloc.add(WorkEventUpdated(updatedEvent)),
        expect: () => [
          const WorkCalendarError(
            'Failed to update event: Exception: Permission denied',
          ),
        ],
      );
    });

    group('WorkEventDeleted', () {
      const eventId = 'event_123';

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkEventDeletedSuccess] when event is deleted successfully',
        build: () {
          when(mockRepository.deleteEvent(eventId)).thenAnswer((_) async => {});
          return bloc;
        },
        act: (bloc) => bloc.add(const WorkEventDeleted(eventId)),
        expect: () => [const WorkEventDeletedSuccess(eventId)],
        verify: (_) {
          verify(mockRepository.deleteEvent(eventId)).called(1);
        },
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkEventDeletedSuccess, WorkCalendarLoading, CalendarEventsLoaded] when event is deleted and calendar is loaded',
        build: () {
          when(mockRepository.deleteEvent(eventId)).thenAnswer((_) async => {});
          when(
            mockRepository.getEventsInRange(any, any),
          ).thenAnswer((_) async => []);
          return bloc;
        },
        seed: () => CalendarEventsLoaded(
          events: testEventList,
          currentDate: testStartDate,
          viewType: CalendarViewType.month,
        ),
        act: (bloc) => bloc.add(const WorkEventDeleted(eventId)),
        expect: () => [
          const WorkEventDeletedSuccess(eventId),
          const WorkCalendarLoading(),
          CalendarEventsLoaded(
            events: [],
            currentDate: testStartDate,
            viewType: CalendarViewType.month,
          ),
        ],
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarError] when deleting event fails',
        build: () {
          when(
            mockRepository.deleteEvent(eventId),
          ).thenThrow(Exception('Event not found'));
          return bloc;
        },
        act: (bloc) => bloc.add(const WorkEventDeleted(eventId)),
        expect: () => [
          const WorkCalendarError(
            'Failed to delete event: Exception: Event not found',
          ),
        ],
      );
    });

    group('CalendarEventsSearched', () {
      const searchQuery = 'meeting';

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarLoading, CalendarSearchResultsLoaded] when search is successful',
        build: () {
          when(
            mockRepository.searchEvents(searchQuery),
          ).thenAnswer((_) async => testEventList);
          return bloc;
        },
        act: (bloc) => bloc.add(const CalendarEventsSearched(searchQuery)),
        expect: () => [
          const WorkCalendarLoading(),
          CalendarSearchResultsLoaded(
            query: searchQuery,
            results: testEventList,
          ),
        ],
        verify: (_) {
          verify(mockRepository.searchEvents(searchQuery)).called(1);
        },
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarLoading, CalendarSearchResultsLoaded] with empty results when no events found',
        build: () {
          when(
            mockRepository.searchEvents(searchQuery),
          ).thenAnswer((_) async => []);
          return bloc;
        },
        act: (bloc) => bloc.add(const CalendarEventsSearched(searchQuery)),
        expect: () => [
          const WorkCalendarLoading(),
          const CalendarSearchResultsLoaded(query: searchQuery, results: []),
        ],
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarLoading, WorkCalendarError] when search fails',
        build: () {
          when(
            mockRepository.searchEvents(searchQuery),
          ).thenThrow(Exception('Search service unavailable'));
          return bloc;
        },
        act: (bloc) => bloc.add(const CalendarEventsSearched(searchQuery)),
        expect: () => [
          const WorkCalendarLoading(),
          const WorkCalendarError(
            'Failed to search events: Exception: Search service unavailable',
          ),
        ],
      );
    });

    group('UpcomingEventsRequested', () {
      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarLoading, UpcomingEventsLoaded] when upcoming events are loaded successfully',
        build: () {
          when(
            mockRepository.getUpcomingEvents(),
          ).thenAnswer((_) async => testEventList);
          return bloc;
        },
        act: (bloc) => bloc.add(const UpcomingEventsRequested()),
        expect: () => [
          const WorkCalendarLoading(),
          UpcomingEventsLoaded(testEventList),
        ],
        verify: (_) {
          verify(mockRepository.getUpcomingEvents()).called(1);
        },
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarLoading, WorkCalendarError] when loading upcoming events fails',
        build: () {
          when(
            mockRepository.getUpcomingEvents(),
          ).thenThrow(Exception('Server error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const UpcomingEventsRequested()),
        expect: () => [
          const WorkCalendarLoading(),
          const WorkCalendarError(
            'Failed to load upcoming events: Exception: Server error',
          ),
        ],
      );
    });

    group('TodaysEventsRequested', () {
      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarLoading, TodaysEventsLoaded] when today\'s events are loaded successfully',
        build: () {
          when(
            mockRepository.getTodaysEvents(),
          ).thenAnswer((_) async => testEventList);
          return bloc;
        },
        act: (bloc) => bloc.add(const TodaysEventsRequested()),
        expect: () => [
          const WorkCalendarLoading(),
          TodaysEventsLoaded(testEventList),
        ],
        verify: (_) {
          verify(mockRepository.getTodaysEvents()).called(1);
        },
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarLoading, WorkCalendarError] when loading today\'s events fails',
        build: () {
          when(
            mockRepository.getTodaysEvents(),
          ).thenThrow(Exception('Database connection failed'));
          return bloc;
        },
        act: (bloc) => bloc.add(const TodaysEventsRequested()),
        expect: () => [
          const WorkCalendarLoading(),
          const WorkCalendarError(
            'Failed to load today\'s events: Exception: Database connection failed',
          ),
        ],
      );
    });

    group('EventsFilteredByType', () {
      const eventType = WorkEventType.meeting;

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarLoading, EventsFilteredByTypeLoaded] when events are filtered successfully',
        build: () {
          when(
            mockRepository.getEventsByType(eventType),
          ).thenAnswer((_) async => testEventList);
          return bloc;
        },
        act: (bloc) => bloc.add(const EventsFilteredByType(eventType)),
        expect: () => [
          const WorkCalendarLoading(),
          EventsFilteredByTypeLoaded(
            eventType: eventType,
            events: testEventList,
          ),
        ],
        verify: (_) {
          verify(mockRepository.getEventsByType(eventType)).called(1);
        },
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarLoading, WorkCalendarError] when filtering events fails',
        build: () {
          when(
            mockRepository.getEventsByType(eventType),
          ).thenThrow(Exception('Invalid event type'));
          return bloc;
        },
        act: (bloc) => bloc.add(const EventsFilteredByType(eventType)),
        expect: () => [
          const WorkCalendarLoading(),
          const WorkCalendarError(
            'Failed to filter events: Exception: Invalid event type',
          ),
        ],
      );
    });

    group('CalendarEventsExported', () {
      const exportedData = 'exported_data_string';

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [CalendarExportSuccess] when events are exported successfully',
        build: () {
          when(
            mockRepository.exportEvents(testEventList),
          ).thenAnswer((_) async => exportedData);
          return bloc;
        },
        act: (bloc) => bloc.add(CalendarEventsExported(testEventList)),
        expect: () => [const CalendarExportSuccess(exportedData)],
        verify: (_) {
          verify(mockRepository.exportEvents(testEventList)).called(1);
        },
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [WorkCalendarError] when exporting events fails',
        build: () {
          when(
            mockRepository.exportEvents(testEventList),
          ).thenThrow(Exception('Export format not supported'));
          return bloc;
        },
        act: (bloc) => bloc.add(CalendarEventsExported(testEventList)),
        expect: () => [
          const WorkCalendarError(
            'Failed to export events: Exception: Export format not supported',
          ),
        ],
      );
    });

    group('CalendarViewChanged', () {
      const newViewType = CalendarViewType.week;

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'emits [CalendarEventsLoaded] with new view type when calendar is loaded',
        build: () => bloc,
        seed: () => CalendarEventsLoaded(
          events: testEventList,
          currentDate: testStartDate,
          viewType: CalendarViewType.month,
        ),
        act: (bloc) => bloc.add(const CalendarViewChanged(newViewType)),
        expect: () => [
          CalendarEventsLoaded(
            events: testEventList,
            currentDate: testStartDate,
            viewType: newViewType,
          ),
        ],
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'does not emit any state when calendar is not loaded',
        build: () => bloc,
        seed: () => const WorkCalendarInitial(),
        act: (bloc) => bloc.add(const CalendarViewChanged(newViewType)),
        expect: () => [],
      );
    });

    group('CalendarDateChanged', () {
      final newDate = DateTime(2024, 2, 1);

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'triggers CalendarEventsRequested when calendar is loaded',
        build: () {
          when(
            mockRepository.getEventsInRange(any, any),
          ).thenAnswer((_) async => testEventList);
          return bloc;
        },
        seed: () => CalendarEventsLoaded(
          events: testEventList,
          currentDate: testStartDate,
          viewType: CalendarViewType.month,
        ),
        act: (bloc) => bloc.add(CalendarDateChanged(newDate)),
        expect: () => [
          const WorkCalendarLoading(),
          CalendarEventsLoaded(
            events: testEventList,
            currentDate: newDate,
            viewType: CalendarViewType.month,
          ),
        ],
        verify: (_) {
          verify(
            mockRepository.getEventsInRange(
              newDate,
              newDate.add(const Duration(days: 30)),
            ),
          ).called(1);
        },
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'does not trigger any action when calendar is not loaded',
        build: () => bloc,
        seed: () => const WorkCalendarInitial(),
        act: (bloc) => bloc.add(CalendarDateChanged(newDate)),
        expect: () => [],
        verify: (_) {
          verifyNever(mockRepository.getEventsInRange(any, any));
        },
      );
    });

    group('Complex scenarios', () {
      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'handles multiple rapid events correctly',
        build: () {
          when(
            mockRepository.createEvent(any),
          ).thenAnswer((_) async => testEvent);
          when(
            mockRepository.getEventsInRange(any, any),
          ).thenAnswer((_) async => testEventList);
          return bloc;
        },
        seed: () => CalendarEventsLoaded(
          events: [],
          currentDate: testStartDate,
          viewType: CalendarViewType.month,
        ),
        act: (bloc) {
          bloc.add(WorkEventCreated(testEvent));
          bloc.add(const CalendarViewChanged(CalendarViewType.week));
        },
        expect: () => [
          WorkEventCreatedSuccess(testEvent),
          const WorkCalendarLoading(),
          CalendarEventsLoaded(
            events: testEventList,
            currentDate: testStartDate,
            viewType: CalendarViewType.week,
          ),
        ],
      );

      blocTest<WorkCalendarBloc, WorkCalendarState>(
        'maintains view type through CRUD operations',
        build: () {
          when(
            mockRepository.updateEvent(any),
          ).thenAnswer((_) async => testEvent);
          when(
            mockRepository.getEventsInRange(any, any),
          ).thenAnswer((_) async => testEventList);
          return bloc;
        },
        seed: () => CalendarEventsLoaded(
          events: testEventList,
          currentDate: testStartDate,
          viewType: CalendarViewType.week,
        ),
        act: (bloc) => bloc.add(WorkEventUpdated(testEvent)),
        expect: () => [
          WorkEventUpdatedSuccess(testEvent),
          const WorkCalendarLoading(),
          CalendarEventsLoaded(
            events: testEventList,
            currentDate: testStartDate,
            viewType: CalendarViewType.week,
          ),
        ],
      );
    });
  });
}
