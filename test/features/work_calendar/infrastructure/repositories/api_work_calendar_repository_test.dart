import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_architecture_app/features/work_calendar/domain/entities/work_event.dart';
import 'package:flutter_architecture_app/features/work_calendar/infrastructure/repositories/api_work_calendar_repository.dart';

import '../../../../test_helpers/test_helpers.mocks.dart';

void main() {
  late ApiWorkCalendarRepository repository;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    repository = ApiWorkCalendarRepository(mockDio);
  });

  group('ApiWorkCalendarRepository', () {
    final testWorkEvent = WorkEvent(
      id: 'event_123',
      title: 'Test Meeting',
      startTime: DateTime(2024, 6, 8, 10, 0, 0),
      endTime: DateTime(2024, 6, 8, 11, 0, 0),
      description: 'Test meeting description',
      location: 'Conference Room A',
      color: '#2196F3',
      isAllDay: false,
      eventType: WorkEventType.meeting,
      attendees: ['user1@example.com', 'user2@example.com'],
    );

    final testEventData = {
      'id': 'event_123',
      'title': 'Test Meeting',
      'startTime': '2024-06-08T10:00:00.000Z',
      'endTime': '2024-06-08T11:00:00.000Z',
      'description': 'Test meeting description',
      'location': 'Conference Room A',
      'color': '#2196F3',
      'isAllDay': false,
      'eventType': 'meeting',
      'attendees': ['user1@example.com', 'user2@example.com'],
    };

    group('getEventsInRange', () {
      test('should get events in date range successfully', () async {
        // Arrange
        final startDate = DateTime(2024, 6, 1);
        final endDate = DateTime(2024, 6, 30);
        final responseData = {
          'events': [testEventData],
        };

        when(
          mockDio.get(
            '/api/calendar/events',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/calendar/events'),
          ),
        );

        // Act
        final result = await repository.getEventsInRange(startDate, endDate);

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals('event_123'));
        expect(result[0].title, equals('Test Meeting'));
        expect(result[0].eventType, equals(WorkEventType.meeting));

        verify(
          mockDio.get(
            '/api/calendar/events',
            queryParameters: {
              'startDate': startDate.toIso8601String(),
              'endDate': endDate.toIso8601String(),
            },
          ),
        ).called(1);
      });

      test('should return empty list when no events in range', () async {
        // Arrange
        final startDate = DateTime(2024, 6, 1);
        final endDate = DateTime(2024, 6, 30);
        final responseData = {'events': <dynamic>[]};

        when(
          mockDio.get(
            '/api/calendar/events',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/calendar/events'),
          ),
        );

        // Act
        final result = await repository.getEventsInRange(startDate, endDate);

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception when get events in range fails', () async {
        // Arrange
        final startDate = DateTime(2024, 6, 1);
        final endDate = DateTime(2024, 6, 30);

        when(
          mockDio.get(
            '/api/calendar/events',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/calendar/events'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getEventsInRange(startDate, endDate),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to get events in range'),
            ),
          ),
        );
      });
    });

    group('getEventsForDate', () {
      test('should get events for specific date successfully', () async {
        // Arrange
        final date = DateTime(2024, 6, 8);
        final responseData = {
          'events': [testEventData],
        };

        when(
          mockDio.get(
            '/api/calendar/events/date',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/calendar/events/date'),
          ),
        );

        // Act
        final result = await repository.getEventsForDate(date);

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals('event_123'));

        verify(
          mockDio.get(
            '/api/calendar/events/date',
            queryParameters: {'date': date.toIso8601String()},
          ),
        ).called(1);
      });

      test('should throw exception when get events for date fails', () async {
        // Arrange
        final date = DateTime(2024, 6, 8);

        when(
          mockDio.get(
            '/api/calendar/events/date',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/calendar/events/date'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getEventsForDate(date),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to get events for date'),
            ),
          ),
        );
      });
    });

    group('createEvent', () {
      test('should create event successfully', () async {
        // Arrange
        when(
          mockDio.post('/api/calendar/events', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            data: testEventData,
            statusCode: 201,
            requestOptions: RequestOptions(path: '/api/calendar/events'),
          ),
        );

        // Act
        final result = await repository.createEvent(testWorkEvent);

        // Assert
        expect(result.id, equals('event_123'));
        expect(result.title, equals('Test Meeting'));
        expect(result.eventType, equals(WorkEventType.meeting));

        verify(
          mockDio.post(
            '/api/calendar/events',
            data: {
              'id': testWorkEvent.id,
              'title': testWorkEvent.title,
              'startTime': testWorkEvent.startTime.toIso8601String(),
              'endTime': testWorkEvent.endTime.toIso8601String(),
              'description': testWorkEvent.description,
              'location': testWorkEvent.location,
              'color': testWorkEvent.color,
              'isAllDay': testWorkEvent.isAllDay,
              'eventType': testWorkEvent.eventType.name,
              'attendees': testWorkEvent.attendees,
            },
          ),
        ).called(1);
      });

      test('should create event with minimal data', () async {
        // Arrange
        final minimalEvent = WorkEvent(
          id: 'minimal_event',
          title: 'Minimal Event',
          startTime: DateTime(2024, 6, 8, 10, 0, 0),
          endTime: DateTime(2024, 6, 8, 11, 0, 0),
        );

        final minimalEventData = {
          'id': 'minimal_event',
          'title': 'Minimal Event',
          'startTime': '2024-06-08T10:00:00.000Z',
          'endTime': '2024-06-08T11:00:00.000Z',
          'description': null,
          'location': null,
          'color': null,
          'isAllDay': false,
          'eventType': 'meeting',
          'attendees': [],
        };

        when(
          mockDio.post('/api/calendar/events', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            data: minimalEventData,
            statusCode: 201,
            requestOptions: RequestOptions(path: '/api/calendar/events'),
          ),
        );

        // Act
        final result = await repository.createEvent(minimalEvent);

        // Assert
        expect(result.id, equals('minimal_event'));
        expect(result.description, isNull);
        expect(result.location, isNull);
      });

      test('should throw exception when create event fails', () async {
        // Arrange
        when(
          mockDio.post('/api/calendar/events', data: anyNamed('data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/calendar/events'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.createEvent(testWorkEvent),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to create event'),
            ),
          ),
        );
      });
    });

    group('updateEvent', () {
      test('should update event successfully', () async {
        // Arrange
        final updatedEventData = {...testEventData, 'title': 'Updated Meeting'};

        when(
          mockDio.put(
            '/api/calendar/events/${testWorkEvent.id}',
            data: anyNamed('data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: updatedEventData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/calendar/events/${testWorkEvent.id}',
            ),
          ),
        );

        // Act
        final updatedEvent = testWorkEvent.copyWith(title: 'Updated Meeting');
        final result = await repository.updateEvent(updatedEvent);

        // Assert
        expect(result.id, equals('event_123'));
        expect(result.title, equals('Updated Meeting'));

        verify(
          mockDio.put(
            '/api/calendar/events/${testWorkEvent.id}',
            data: anyNamed('data'),
          ),
        ).called(1);
      });

      test('should throw exception when update event fails', () async {
        // Arrange
        when(
          mockDio.put(
            '/api/calendar/events/${testWorkEvent.id}',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/calendar/events/${testWorkEvent.id}',
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.updateEvent(testWorkEvent),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to update event'),
            ),
          ),
        );
      });
    });

    group('deleteEvent', () {
      test('should delete event successfully', () async {
        // Arrange
        const eventId = 'event_123';
        when(mockDio.delete('/api/calendar/events/$eventId')).thenAnswer(
          (_) async => Response(
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/calendar/events/$eventId',
            ),
          ),
        );

        // Act
        await repository.deleteEvent(eventId);

        // Assert
        verify(mockDio.delete('/api/calendar/events/$eventId')).called(1);
      });

      test('should throw exception when delete event fails', () async {
        // Arrange
        const eventId = 'event_123';
        when(mockDio.delete('/api/calendar/events/$eventId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/calendar/events/$eventId',
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.deleteEvent(eventId),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to delete event'),
            ),
          ),
        );
      });
    });

    group('getEvent', () {
      test('should get event by ID successfully', () async {
        // Arrange
        const eventId = 'event_123';
        when(mockDio.get('/api/calendar/events/$eventId')).thenAnswer(
          (_) async => Response(
            data: testEventData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/calendar/events/$eventId',
            ),
          ),
        );

        // Act
        final result = await repository.getEvent(eventId);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals(eventId));
        expect(result.title, equals('Test Meeting'));

        verify(mockDio.get('/api/calendar/events/$eventId')).called(1);
      });

      test('should return null when event not found (404 status)', () async {
        // Arrange
        const eventId = 'nonexistent_event';
        when(mockDio.get('/api/calendar/events/$eventId')).thenAnswer(
          (_) async => Response(
            statusCode: 404,
            requestOptions: RequestOptions(
              path: '/api/calendar/events/$eventId',
            ),
          ),
        );

        // Act
        final result = await repository.getEvent(eventId);

        // Assert
        expect(result, isNull);
      });

      test('should return null when DioException with 404', () async {
        // Arrange
        const eventId = 'nonexistent_event';
        when(mockDio.get('/api/calendar/events/$eventId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/calendar/events/$eventId',
            ),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/api/calendar/events/$eventId',
              ),
            ),
          ),
        );

        // Act
        final result = await repository.getEvent(eventId);

        // Assert
        expect(result, isNull);
      });

      test('should throw exception for other errors', () async {
        // Arrange
        const eventId = 'event_123';
        when(mockDio.get('/api/calendar/events/$eventId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/calendar/events/$eventId',
            ),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(
                path: '/api/calendar/events/$eventId',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getEvent(eventId),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to get event'),
            ),
          ),
        );
      });
    });

    group('searchEvents', () {
      test('should search events successfully', () async {
        // Arrange
        const query = 'meeting';
        final responseData = {
          'events': [testEventData],
        };

        when(
          mockDio.get(
            '/api/calendar/events/search',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/calendar/events/search'),
          ),
        );

        // Act
        final result = await repository.searchEvents(query);

        // Assert
        expect(result, hasLength(1));
        expect(result[0].title, equals('Test Meeting'));

        verify(
          mockDio.get(
            '/api/calendar/events/search',
            queryParameters: {'query': query},
          ),
        ).called(1);
      });

      test('should return empty list when no search results', () async {
        // Arrange
        const query = 'nonexistent';
        final responseData = {'events': <dynamic>[]};

        when(
          mockDio.get(
            '/api/calendar/events/search',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/calendar/events/search'),
          ),
        );

        // Act
        final result = await repository.searchEvents(query);

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception when search fails', () async {
        // Arrange
        const query = 'meeting';
        when(
          mockDio.get(
            '/api/calendar/events/search',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/calendar/events/search'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.searchEvents(query),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to search events'),
            ),
          ),
        );
      });
    });

    group('getUpcomingEvents', () {
      test('should get upcoming events successfully', () async {
        // Arrange
        final responseData = {
          'events': [testEventData],
        };

        when(mockDio.get('/api/calendar/events/upcoming')).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/calendar/events/upcoming',
            ),
          ),
        );

        // Act
        final result = await repository.getUpcomingEvents();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals('event_123'));

        verify(mockDio.get('/api/calendar/events/upcoming')).called(1);
      });

      test('should throw exception when get upcoming events fails', () async {
        // Arrange
        when(mockDio.get('/api/calendar/events/upcoming')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/calendar/events/upcoming',
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getUpcomingEvents(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to get upcoming events'),
            ),
          ),
        );
      });
    });

    group('getEventsByType', () {
      test('should get events by type successfully', () async {
        // Arrange
        const eventType = WorkEventType.meeting;
        final responseData = {
          'events': [testEventData],
        };

        when(
          mockDio.get(
            '/api/calendar/events/type',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/calendar/events/type'),
          ),
        );

        // Act
        final result = await repository.getEventsByType(eventType);

        // Assert
        expect(result, hasLength(1));
        expect(result[0].eventType, equals(WorkEventType.meeting));

        verify(
          mockDio.get(
            '/api/calendar/events/type',
            queryParameters: {'type': eventType.name},
          ),
        ).called(1);
      });

      test('should throw exception when get events by type fails', () async {
        // Arrange
        const eventType = WorkEventType.meeting;
        when(
          mockDio.get(
            '/api/calendar/events/type',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/calendar/events/type'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getEventsByType(eventType),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to get events by type'),
            ),
          ),
        );
      });
    });

    group('getTodaysEvents', () {
      test('should get today\'s events successfully', () async {
        // Arrange
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        final responseData = {
          'events': [testEventData],
        };

        when(
          mockDio.get(
            '/api/calendar/events',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/calendar/events'),
          ),
        );

        // Act
        final result = await repository.getTodaysEvents();

        // Assert
        expect(result, hasLength(1));

        verify(
          mockDio.get(
            '/api/calendar/events',
            queryParameters: {
              'startDate': startOfDay.toIso8601String(),
              'endDate': endOfDay.toIso8601String(),
            },
          ),
        ).called(1);
      });

      test('should throw exception when get today\'s events fails', () async {
        // Arrange
        when(
          mockDio.get(
            '/api/calendar/events',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/calendar/events'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getTodaysEvents(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to get today\'s events'),
            ),
          ),
        );
      });
    });

    group('getWeekEvents', () {
      test('should get week events successfully', () async {
        // Arrange
        final weekStart = DateTime(2024, 6, 3); // Monday
        final weekEnd = weekStart.add(const Duration(days: 7));
        final responseData = {
          'events': [testEventData],
        };

        when(
          mockDio.get(
            '/api/calendar/events',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/calendar/events'),
          ),
        );

        // Act
        final result = await repository.getWeekEvents(weekStart);

        // Assert
        expect(result, hasLength(1));

        verify(
          mockDio.get(
            '/api/calendar/events',
            queryParameters: {
              'startDate': weekStart.toIso8601String(),
              'endDate': weekEnd.toIso8601String(),
            },
          ),
        ).called(1);
      });

      test('should throw exception when get week events fails', () async {
        // Arrange
        final weekStart = DateTime(2024, 6, 3);
        when(
          mockDio.get(
            '/api/calendar/events',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/calendar/events'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getWeekEvents(weekStart),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to get week events'),
            ),
          ),
        );
      });
    });

    group('getMonthEvents', () {
      test('should get month events successfully', () async {
        // Arrange
        final monthStart = DateTime(2024, 6, 1);
        final monthEnd = DateTime(2024, 7, 1);
        final responseData = {
          'events': [testEventData],
        };

        when(
          mockDio.get(
            '/api/calendar/events',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/calendar/events'),
          ),
        );

        // Act
        final result = await repository.getMonthEvents(monthStart);

        // Assert
        expect(result, hasLength(1));

        verify(
          mockDio.get(
            '/api/calendar/events',
            queryParameters: {
              'startDate': monthStart.toIso8601String(),
              'endDate': monthEnd.toIso8601String(),
            },
          ),
        ).called(1);
      });

      test('should throw exception when get month events fails', () async {
        // Arrange
        final monthStart = DateTime(2024, 6, 1);
        when(
          mockDio.get(
            '/api/calendar/events',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/calendar/events'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getMonthEvents(monthStart),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to get month events'),
            ),
          ),
        );
      });
    });

    group('getConflictingEvents', () {
      test('should get conflicting events successfully', () async {
        // Arrange
        final startTime = DateTime(2024, 6, 8, 10, 0, 0);
        final endTime = DateTime(2024, 6, 8, 11, 0, 0);
        final responseData = {
          'events': [testEventData],
        };

        when(
          mockDio.get(
            '/api/calendar/events/conflicts',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/calendar/events/conflicts',
            ),
          ),
        );

        // Act
        final result = await repository.getConflictingEvents(
          startTime,
          endTime,
        );

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals('event_123'));

        verify(
          mockDio.get(
            '/api/calendar/events/conflicts',
            queryParameters: {
              'startTime': startTime.toIso8601String(),
              'endTime': endTime.toIso8601String(),
            },
          ),
        ).called(1);
      });

      test('should return empty list when no conflicts', () async {
        // Arrange
        final startTime = DateTime(2024, 6, 8, 14, 0, 0);
        final endTime = DateTime(2024, 6, 8, 15, 0, 0);
        final responseData = {'events': <dynamic>[]};

        when(
          mockDio.get(
            '/api/calendar/events/conflicts',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/calendar/events/conflicts',
            ),
          ),
        );

        // Act
        final result = await repository.getConflictingEvents(
          startTime,
          endTime,
        );

        // Assert
        expect(result, isEmpty);
      });

      test(
        'should throw exception when get conflicting events fails',
        () async {
          // Arrange
          final startTime = DateTime(2024, 6, 8, 10, 0, 0);
          final endTime = DateTime(2024, 6, 8, 11, 0, 0);

          when(
            mockDio.get(
              '/api/calendar/events/conflicts',
              queryParameters: anyNamed('queryParameters'),
            ),
          ).thenThrow(
            DioException(
              requestOptions: RequestOptions(
                path: '/api/calendar/events/conflicts',
              ),
            ),
          );

          // Act & Assert
          expect(
            () => repository.getConflictingEvents(startTime, endTime),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Failed to get conflicting events'),
              ),
            ),
          );
        },
      );
    });

    group('exportEvents', () {
      test('should export events successfully', () async {
        // Arrange
        final events = [testWorkEvent];
        const exportData = 'BEGIN:VCALENDAR\r\nVERSION:2.0\r\n...';
        final responseData = {'exportData': exportData};

        when(
          mockDio.post('/api/calendar/events/export', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/calendar/events/export'),
          ),
        );

        // Act
        final result = await repository.exportEvents(events);

        // Assert
        expect(result, equals(exportData));

        verify(
          mockDio.post(
            '/api/calendar/events/export',
            data: {
              'events': [
                {
                  'id': testWorkEvent.id,
                  'title': testWorkEvent.title,
                  'startTime': testWorkEvent.startTime.toIso8601String(),
                  'endTime': testWorkEvent.endTime.toIso8601String(),
                  'description': testWorkEvent.description,
                  'location': testWorkEvent.location,
                  'color': testWorkEvent.color,
                  'isAllDay': testWorkEvent.isAllDay,
                  'eventType': testWorkEvent.eventType.name,
                  'attendees': testWorkEvent.attendees,
                },
              ],
            },
          ),
        ).called(1);
      });

      test('should export empty list successfully', () async {
        // Arrange
        final events = <WorkEvent>[];
        const exportData =
            'BEGIN:VCALENDAR\r\nVERSION:2.0\r\nEND:VCALENDAR\r\n';
        final responseData = {'exportData': exportData};

        when(
          mockDio.post('/api/calendar/events/export', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/calendar/events/export'),
          ),
        );

        // Act
        final result = await repository.exportEvents(events);

        // Assert
        expect(result, equals(exportData));

        verify(
          mockDio.post(
            '/api/calendar/events/export',
            data: {'events': <dynamic>[]},
          ),
        ).called(1);
      });

      test('should throw exception when export fails', () async {
        // Arrange
        final events = [testWorkEvent];

        when(
          mockDio.post('/api/calendar/events/export', data: anyNamed('data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/calendar/events/export'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.exportEvents(events),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to export events'),
            ),
          ),
        );
      });
    });

    group('helper methods', () {
      test('should parse all event types correctly', () async {
        // Arrange
        final allEventTypes = WorkEventType.values;
        final responseData = {
          'events': allEventTypes
              .map(
                (type) => {
                  'id': 'event_${type.name}',
                  'title': 'Test ${type.displayName}',
                  'startTime': '2024-06-08T10:00:00.000Z',
                  'endTime': '2024-06-08T11:00:00.000Z',
                  'description': null,
                  'location': null,
                  'color': type.defaultColor,
                  'isAllDay': false,
                  'eventType': type.name,
                  'attendees': <String>[],
                },
              )
              .toList(),
        };

        when(mockDio.get('/api/calendar/events/upcoming')).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/calendar/events/upcoming',
            ),
          ),
        );

        // Act
        final result = await repository.getUpcomingEvents();

        // Assert
        expect(result, hasLength(allEventTypes.length));
        for (int i = 0; i < allEventTypes.length; i++) {
          expect(result[i].eventType, equals(allEventTypes[i]));
          expect(result[i].color, equals(allEventTypes[i].defaultColor));
        }
      });

      test('should handle unknown event type gracefully', () async {
        // Arrange
        final eventDataWithUnknownType = {
          ...testEventData,
          'eventType': 'unknown_type',
        };
        final responseData = {
          'events': [eventDataWithUnknownType],
        };

        when(mockDio.get('/api/calendar/events/upcoming')).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/calendar/events/upcoming',
            ),
          ),
        );

        // Act
        final result = await repository.getUpcomingEvents();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].eventType, equals(WorkEventType.other));
      });

      test('should handle null event type gracefully', () async {
        // Arrange
        final eventDataWithNullType = {...testEventData, 'eventType': null};
        final responseData = {
          'events': [eventDataWithNullType],
        };

        when(mockDio.get('/api/calendar/events/upcoming')).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/calendar/events/upcoming',
            ),
          ),
        );

        // Act
        final result = await repository.getUpcomingEvents();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].eventType, equals(WorkEventType.other));
      });

      test('should handle event data with default values', () async {
        // Arrange
        final minimalEventData = {
          'id': 'minimal_event',
          'title': 'Minimal Event',
          'startTime': '2024-06-08T10:00:00.000Z',
          'endTime': '2024-06-08T11:00:00.000Z',
          'description': null,
          'location': null,
          'color': null,
          'isAllDay': null,
          'eventType': null,
          'attendees': null,
        };
        final responseData = {
          'events': [minimalEventData],
        };

        when(mockDio.get('/api/calendar/events/upcoming')).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/calendar/events/upcoming',
            ),
          ),
        );

        // Act
        final result = await repository.getUpcomingEvents();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals('minimal_event'));
        expect(result[0].description, isNull);
        expect(result[0].location, isNull);
        expect(result[0].color, isNull);
        expect(result[0].isAllDay, isFalse);
        expect(result[0].eventType, equals(WorkEventType.other));
        expect(result[0].attendees, isEmpty);
      });
    });
  });
}
