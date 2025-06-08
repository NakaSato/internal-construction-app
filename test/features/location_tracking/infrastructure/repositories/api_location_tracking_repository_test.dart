import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart' as loc;
import 'package:mockito/mockito.dart';

import 'package:flutter_architecture_app/features/location_tracking/domain/entities/location_data.dart';
import 'package:flutter_architecture_app/features/location_tracking/domain/repositories/location_tracking_repository.dart';
import 'package:flutter_architecture_app/features/location_tracking/infrastructure/repositories/api_location_tracking_repository.dart';

import '../../../../test_helpers/test_helpers.mocks.dart';

void main() {
  late ApiLocationTrackingRepository repository;
  late MockDio mockDio;
  late MockLocation mockLocation;

  setUp(() {
    mockDio = MockDio();
    mockLocation = MockLocation();
    repository = ApiLocationTrackingRepository(mockDio, mockLocation);
  });

  group('ApiLocationTrackingRepository', () {
    final testLocationData = LocationData(
      latitude: 37.7749,
      longitude: -122.4194,
      timestamp: DateTime(2024, 1, 1, 12, 0, 0),
      accuracy: 5.0,
      altitude: 50.0,
      speed: 2.5,
      heading: 90.0,
      address: 'San Francisco, CA',
    );

    group('startSession', () {
      test('should start a new location session successfully', () async {
        // Arrange
        const sessionName = 'Test Session';
        const sessionDescription = 'Test description';
        final responseData = {
          'id': 'session_123',
          'name': sessionName,
          'startTime': '2024-01-01T10:00:00.000Z',
          'endTime': null,
          'locations': [],
          'isActive': true,
          'description': sessionDescription,
        };

        when(
          mockDio.post('/api/location/sessions', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/location/sessions'),
          ),
        );

        // Act
        final result = await repository.startSession(
          name: sessionName,
          description: sessionDescription,
        );

        // Assert
        expect(result.id, equals('session_123'));
        expect(result.name, equals(sessionName));
        expect(result.description, equals(sessionDescription));
        expect(result.isActive, isTrue);
        expect(result.locations, isEmpty);

        verify(
          mockDio.post(
            '/api/location/sessions',
            data: {'name': sessionName, 'description': sessionDescription},
          ),
        ).called(1);
      });

      test('should start session without description', () async {
        // Arrange
        const sessionName = 'Test Session';
        final responseData = {
          'id': 'session_123',
          'name': sessionName,
          'startTime': '2024-01-01T10:00:00.000Z',
          'endTime': null,
          'locations': [],
          'isActive': true,
          'description': null,
        };

        when(
          mockDio.post('/api/location/sessions', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/location/sessions'),
          ),
        );

        // Act
        final result = await repository.startSession(name: sessionName);

        // Assert
        expect(result.name, equals(sessionName));
        expect(result.description, isNull);

        verify(
          mockDio.post('/api/location/sessions', data: {'name': sessionName}),
        ).called(1);
      });

      test('should throw exception when start session fails', () async {
        // Arrange
        when(
          mockDio.post('/api/location/sessions', data: anyNamed('data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/location/sessions'),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: '/api/location/sessions'),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.startSession(name: 'Test Session'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to start location session'),
            ),
          ),
        );
      });
    });

    group('stopSession', () {
      test('should stop a location session successfully', () async {
        // Arrange
        const sessionId = 'session_123';
        final responseData = {
          'id': sessionId,
          'name': 'Test Session',
          'startTime': '2024-01-01T10:00:00.000Z',
          'endTime': '2024-01-01T12:00:00.000Z',
          'locations': [],
          'isActive': false,
          'description': null,
        };

        when(mockDio.put('/api/location/sessions/$sessionId/stop')).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId/stop',
            ),
          ),
        );

        // Act
        final result = await repository.stopSession(sessionId);

        // Assert
        expect(result.id, equals(sessionId));
        expect(result.isActive, isFalse);
        expect(result.endTime, isNotNull);

        verify(mockDio.put('/api/location/sessions/$sessionId/stop')).called(1);
      });

      test('should throw exception when stop session fails', () async {
        // Arrange
        const sessionId = 'session_123';
        when(mockDio.put('/api/location/sessions/$sessionId/stop')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId/stop',
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.stopSession(sessionId),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to stop location session'),
            ),
          ),
        );
      });
    });

    group('addLocationToSession', () {
      test('should add location data to session successfully', () async {
        // Arrange
        const sessionId = 'session_123';

        when(
          mockDio.post(
            '/api/location/sessions/$sessionId/locations',
            data: anyNamed('data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId/locations',
            ),
          ),
        );

        // Act
        await repository.addLocationToSession(
          sessionId: sessionId,
          location: testLocationData,
        );

        // Assert
        verify(
          mockDio.post(
            '/api/location/sessions/$sessionId/locations',
            data: {
              'latitude': testLocationData.latitude,
              'longitude': testLocationData.longitude,
              'timestamp': testLocationData.timestamp.toIso8601String(),
              'accuracy': testLocationData.accuracy,
              'altitude': testLocationData.altitude,
              'speed': testLocationData.speed,
              'heading': testLocationData.heading,
              'address': testLocationData.address,
            },
          ),
        ).called(1);
      });

      test('should add location data without optional fields', () async {
        // Arrange
        const sessionId = 'session_123';
        final minimalLocationData = LocationData(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        );

        when(
          mockDio.post(
            '/api/location/sessions/$sessionId/locations',
            data: anyNamed('data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId/locations',
            ),
          ),
        );

        // Act
        await repository.addLocationToSession(
          sessionId: sessionId,
          location: minimalLocationData,
        );

        // Assert
        verify(
          mockDio.post(
            '/api/location/sessions/$sessionId/locations',
            data: {
              'latitude': minimalLocationData.latitude,
              'longitude': minimalLocationData.longitude,
              'timestamp': minimalLocationData.timestamp.toIso8601String(),
            },
          ),
        ).called(1);
      });

      test('should throw exception when adding location fails', () async {
        // Arrange
        const sessionId = 'session_123';
        when(
          mockDio.post(
            '/api/location/sessions/$sessionId/locations',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId/locations',
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.addLocationToSession(
            sessionId: sessionId,
            location: testLocationData,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to add location to session'),
            ),
          ),
        );
      });
    });

    group('getCurrentLocation', () {
      test('should get current location successfully', () async {
        // Arrange
        final mockLocationData = loc.LocationData.fromMap({
          'latitude': 37.7749,
          'longitude': -122.4194,
          'accuracy': 5.0,
          'altitude': 50.0,
          'speed': 2.5,
          'heading': 90.0,
          'time': DateTime(
            2024,
            1,
            1,
            12,
            0,
            0,
          ).millisecondsSinceEpoch.toDouble(),
        });

        when(
          mockLocation.getLocation(),
        ).thenAnswer((_) async => mockLocationData);

        // Act
        final result = await repository.getCurrentLocation();

        // Assert
        expect(result.latitude, equals(37.7749));
        expect(result.longitude, equals(-122.4194));
        expect(result.accuracy, equals(5.0));
        expect(result.altitude, equals(50.0));
        expect(result.speed, equals(2.5));
        expect(result.heading, equals(90.0));

        verify(mockLocation.getLocation()).called(1);
      });

      test(
        'should throw exception when getting current location fails',
        () async {
          // Arrange
          when(
            mockLocation.getLocation(),
          ).thenThrow(Exception('Location service error'));

          // Act & Assert
          expect(
            () => repository.getCurrentLocation(),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Failed to get current location'),
              ),
            ),
          );
        },
      );
    });

    group('getLocationStream', () {
      test('should provide location stream', () async {
        // Arrange
        final streamController = StreamController<loc.LocationData>();
        when(
          mockLocation.onLocationChanged,
        ).thenAnswer((_) => streamController.stream);

        // Act
        final locationStream = repository.getLocationStream();

        // Emit test location data
        final mockLocationData = loc.LocationData.fromMap({
          'latitude': 37.7749,
          'longitude': -122.4194,
          'time': DateTime(
            2024,
            1,
            1,
            12,
            0,
            0,
          ).millisecondsSinceEpoch.toDouble(),
        });
        streamController.add(mockLocationData);

        // Assert
        await expectLater(
          locationStream,
          emits(
            isA<LocationData>()
                .having((loc) => loc.latitude, 'latitude', 37.7749)
                .having((loc) => loc.longitude, 'longitude', -122.4194),
          ),
        );

        // Cleanup
        await streamController.close();
      });

      test('should handle location stream errors', () async {
        // Arrange
        final streamController = StreamController<loc.LocationData>();
        when(
          mockLocation.onLocationChanged,
        ).thenAnswer((_) => streamController.stream);

        // Act
        final locationStream = repository.getLocationStream();

        // Emit error
        streamController.addError(Exception('Location error'));

        // Assert
        await expectLater(locationStream, emitsError(isA<Exception>()));

        // Cleanup
        await streamController.close();
      });
    });

    group('getUserSessions', () {
      test('should get user sessions successfully', () async {
        // Arrange
        final responseData = {
          'sessions': [
            {
              'id': 'session_1',
              'name': 'Session 1',
              'startTime': '2024-01-01T10:00:00.000Z',
              'endTime': '2024-01-01T11:00:00.000Z',
              'locations': [],
              'isActive': false,
              'description': 'First session',
            },
            {
              'id': 'session_2',
              'name': 'Session 2',
              'startTime': '2024-01-01T12:00:00.000Z',
              'endTime': null,
              'locations': [],
              'isActive': true,
              'description': null,
            },
          ],
        };

        when(mockDio.get('/api/location/sessions')).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/location/sessions'),
          ),
        );

        // Act
        final result = await repository.getUserSessions();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, equals('session_1'));
        expect(result[0].name, equals('Session 1'));
        expect(result[0].isActive, isFalse);
        expect(result[1].id, equals('session_2'));
        expect(result[1].isActive, isTrue);

        verify(mockDio.get('/api/location/sessions')).called(1);
      });

      test('should throw exception when getting user sessions fails', () async {
        // Arrange
        when(mockDio.get('/api/location/sessions')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/location/sessions'),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getUserSessions(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to get user sessions'),
            ),
          ),
        );
      });
    });

    group('getSessionById', () {
      test('should get session by ID successfully', () async {
        // Arrange
        const sessionId = 'session_123';
        final responseData = {
          'id': sessionId,
          'name': 'Test Session',
          'startTime': '2024-01-01T10:00:00.000Z',
          'endTime': '2024-01-01T12:00:00.000Z',
          'locations': [],
          'isActive': false,
          'description': 'Test description',
        };

        when(mockDio.get('/api/location/sessions/$sessionId')).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId',
            ),
          ),
        );

        // Act
        final result = await repository.getSessionById(sessionId);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals(sessionId));
        expect(result.name, equals('Test Session'));

        verify(mockDio.get('/api/location/sessions/$sessionId')).called(1);
      });

      test('should return null when session not found', () async {
        // Arrange
        const sessionId = 'nonexistent_session';
        when(mockDio.get('/api/location/sessions/$sessionId')).thenAnswer(
          (_) async => Response(
            statusCode: 404,
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId',
            ),
          ),
        );

        // Act
        final result = await repository.getSessionById(sessionId);

        // Assert
        expect(result, isNull);
      });

      test('should return null when DioException with 404', () async {
        // Arrange
        const sessionId = 'nonexistent_session';
        when(mockDio.get('/api/location/sessions/$sessionId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId',
            ),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/api/location/sessions/$sessionId',
              ),
            ),
          ),
        );

        // Act
        final result = await repository.getSessionById(sessionId);

        // Assert
        expect(result, isNull);
      });

      test('should throw exception for other errors', () async {
        // Arrange
        const sessionId = 'session_123';
        when(mockDio.get('/api/location/sessions/$sessionId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId',
            ),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(
                path: '/api/location/sessions/$sessionId',
              ),
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.getSessionById(sessionId),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to get session by ID'),
            ),
          ),
        );
      });
    });

    group('deleteSession', () {
      test('should delete session successfully', () async {
        // Arrange
        const sessionId = 'session_123';
        when(mockDio.delete('/api/location/sessions/$sessionId')).thenAnswer(
          (_) async => Response(
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId',
            ),
          ),
        );

        // Act
        await repository.deleteSession(sessionId);

        // Assert
        verify(mockDio.delete('/api/location/sessions/$sessionId')).called(1);
      });

      test('should throw exception when delete fails', () async {
        // Arrange
        const sessionId = 'session_123';
        when(mockDio.delete('/api/location/sessions/$sessionId')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId',
            ),
          ),
        );

        // Act & Assert
        expect(
          () => repository.deleteSession(sessionId),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to delete session'),
            ),
          ),
        );
      });
    });

    group('updateSession', () {
      test('should update session with name and description', () async {
        // Arrange
        const sessionId = 'session_123';
        const newName = 'Updated Session';
        const newDescription = 'Updated description';
        final responseData = {
          'id': sessionId,
          'name': newName,
          'startTime': '2024-01-01T10:00:00.000Z',
          'endTime': null,
          'locations': [],
          'isActive': true,
          'description': newDescription,
        };

        when(
          mockDio.put(
            '/api/location/sessions/$sessionId',
            data: anyNamed('data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId',
            ),
          ),
        );

        // Act
        final result = await repository.updateSession(
          sessionId: sessionId,
          name: newName,
          description: newDescription,
        );

        // Assert
        expect(result.id, equals(sessionId));
        expect(result.name, equals(newName));
        expect(result.description, equals(newDescription));

        verify(
          mockDio.put(
            '/api/location/sessions/$sessionId',
            data: {'name': newName, 'description': newDescription},
          ),
        ).called(1);
      });

      test('should update session with only name', () async {
        // Arrange
        const sessionId = 'session_123';
        const newName = 'Updated Session';
        final responseData = {
          'id': sessionId,
          'name': newName,
          'startTime': '2024-01-01T10:00:00.000Z',
          'endTime': null,
          'locations': [],
          'isActive': true,
          'description': null,
        };

        when(
          mockDio.put(
            '/api/location/sessions/$sessionId',
            data: anyNamed('data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId',
            ),
          ),
        );

        // Act
        final result = await repository.updateSession(
          sessionId: sessionId,
          name: newName,
        );

        // Assert
        expect(result.name, equals(newName));

        verify(
          mockDio.put(
            '/api/location/sessions/$sessionId',
            data: {'name': newName},
          ),
        ).called(1);
      });

      test('should throw exception when update fails', () async {
        // Arrange
        const sessionId = 'session_123';
        when(
          mockDio.put(
            '/api/location/sessions/$sessionId',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId',
            ),
          ),
        );

        // Act & Assert
        expect(
          () =>
              repository.updateSession(sessionId: sessionId, name: 'New Name'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to update session'),
            ),
          ),
        );
      });
    });

    group('permission and service methods', () {
      test(
        'isLocationServiceEnabled should return true when enabled',
        () async {
          // Arrange
          when(mockLocation.serviceEnabled()).thenAnswer((_) async => true);

          // Act
          final result = await repository.isLocationServiceEnabled();

          // Assert
          expect(result, isTrue);
          verify(mockLocation.serviceEnabled()).called(1);
        },
      );

      test(
        'isLocationServiceEnabled should return false when disabled',
        () async {
          // Arrange
          when(mockLocation.serviceEnabled()).thenAnswer((_) async => false);

          // Act
          final result = await repository.isLocationServiceEnabled();

          // Assert
          expect(result, isFalse);
        },
      );

      test('isLocationServiceEnabled should return false on error', () async {
        // Arrange
        when(
          mockLocation.serviceEnabled(),
        ).thenThrow(Exception('Service error'));

        // Act
        final result = await repository.isLocationServiceEnabled();

        // Assert
        expect(result, isFalse);
      });

      test('checkLocationPermission should return correct status', () async {
        // Arrange
        when(
          mockLocation.hasPermission(),
        ).thenAnswer((_) async => loc.PermissionStatus.granted);

        // Act
        final result = await repository.checkLocationPermission();

        // Assert
        expect(result, equals(LocationPermissionStatus.whileInUse));
        verify(mockLocation.hasPermission()).called(1);
      });

      test(
        'checkLocationPermission should handle all permission statuses',
        () async {
          // Test denied
          when(
            mockLocation.hasPermission(),
          ).thenAnswer((_) async => loc.PermissionStatus.denied);
          expect(
            await repository.checkLocationPermission(),
            equals(LocationPermissionStatus.denied),
          );

          // Test denied forever
          when(
            mockLocation.hasPermission(),
          ).thenAnswer((_) async => loc.PermissionStatus.deniedForever);
          expect(
            await repository.checkLocationPermission(),
            equals(LocationPermissionStatus.deniedForever),
          );

          // Test granted limited
          when(
            mockLocation.hasPermission(),
          ).thenAnswer((_) async => loc.PermissionStatus.grantedLimited);
          expect(
            await repository.checkLocationPermission(),
            equals(LocationPermissionStatus.whileInUse),
          );
        },
      );

      test('checkLocationPermission should handle errors', () async {
        // Arrange
        when(
          mockLocation.hasPermission(),
        ).thenThrow(Exception('Permission error'));

        // Act
        final result = await repository.checkLocationPermission();

        // Assert
        expect(result, equals(LocationPermissionStatus.unableToDetermine));
      });

      test(
        'requestLocationPermission should request and return status',
        () async {
          // Arrange
          when(
            mockLocation.requestPermission(),
          ).thenAnswer((_) async => loc.PermissionStatus.granted);

          // Act
          final result = await repository.requestLocationPermission();

          // Assert
          expect(result, equals(LocationPermissionStatus.whileInUse));
          verify(mockLocation.requestPermission()).called(1);
        },
      );

      test('requestLocationPermission should handle errors', () async {
        // Arrange
        when(
          mockLocation.requestPermission(),
        ).thenThrow(Exception('Request error'));

        // Act
        final result = await repository.requestLocationPermission();

        // Assert
        expect(result, equals(LocationPermissionStatus.unableToDetermine));
      });
    });

    group('getActiveSession', () {
      test('should get active session successfully', () async {
        // Arrange
        final responseData = {
          'id': 'active_session',
          'name': 'Active Session',
          'startTime': '2024-01-01T10:00:00.000Z',
          'endTime': null,
          'locations': [],
          'isActive': true,
          'description': 'Currently active session',
        };

        when(mockDio.get('/api/location/sessions/active')).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/location/sessions/active',
            ),
          ),
        );

        // Act
        final result = await repository.getActiveSession();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('active_session'));
        expect(result.isActive, isTrue);

        verify(mockDio.get('/api/location/sessions/active')).called(1);
      });

      test('should return null when no active session', () async {
        // Arrange
        when(mockDio.get('/api/location/sessions/active')).thenAnswer(
          (_) async => Response(
            statusCode: 404,
            requestOptions: RequestOptions(
              path: '/api/location/sessions/active',
            ),
          ),
        );

        // Act
        final result = await repository.getActiveSession();

        // Assert
        expect(result, isNull);
      });

      test('should return null when DioException with 404', () async {
        // Arrange
        when(mockDio.get('/api/location/sessions/active')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/location/sessions/active',
            ),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/api/location/sessions/active',
              ),
            ),
          ),
        );

        // Act
        final result = await repository.getActiveSession();

        // Assert
        expect(result, isNull);
      });
    });

    group('compatibility methods', () {
      test(
        'hasLocationPermission should return true for granted permission',
        () async {
          // Arrange
          when(
            mockLocation.hasPermission(),
          ).thenAnswer((_) async => loc.PermissionStatus.granted);

          // Act
          final result = await repository.hasLocationPermission();

          // Assert
          expect(result, isTrue);
        },
      );

      test(
        'hasLocationPermission should return false for denied permission',
        () async {
          // Arrange
          when(
            mockLocation.hasPermission(),
          ).thenAnswer((_) async => loc.PermissionStatus.denied);

          // Act
          final result = await repository.hasLocationPermission();

          // Assert
          expect(result, isFalse);
        },
      );

      test('startLocationSession should delegate to startSession', () async {
        // Arrange
        const sessionName = 'Test Session';
        final responseData = {
          'id': 'session_123',
          'name': sessionName,
          'startTime': '2024-01-01T10:00:00.000Z',
          'endTime': null,
          'locations': [],
          'isActive': true,
          'description': null,
        };

        when(
          mockDio.post('/api/location/sessions', data: anyNamed('data')),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/location/sessions'),
          ),
        );

        // Act
        final result = await repository.startLocationSession(sessionName);

        // Assert
        expect(result.name, equals(sessionName));
        verify(
          mockDio.post('/api/location/sessions', data: {'name': sessionName}),
        ).called(1);
      });

      test('stopLocationSession should delegate to stopSession', () async {
        // Arrange
        const sessionId = 'session_123';
        final responseData = {
          'id': sessionId,
          'name': 'Test Session',
          'startTime': '2024-01-01T10:00:00.000Z',
          'endTime': '2024-01-01T12:00:00.000Z',
          'locations': [],
          'isActive': false,
          'description': null,
        };

        when(mockDio.put('/api/location/sessions/$sessionId/stop')).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId/stop',
            ),
          ),
        );

        // Act
        final result = await repository.stopLocationSession(sessionId);

        // Assert
        expect(result.id, equals(sessionId));
        expect(result.isActive, isFalse);
      });

      test(
        'saveLocationData should delegate to addLocationToSession',
        () async {
          // Arrange
          const sessionId = 'session_123';

          when(
            mockDio.post(
              '/api/location/sessions/$sessionId/locations',
              data: anyNamed('data'),
            ),
          ).thenAnswer(
            (_) async => Response(
              statusCode: 200,
              requestOptions: RequestOptions(
                path: '/api/location/sessions/$sessionId/locations',
              ),
            ),
          );

          // Act
          await repository.saveLocationData(sessionId, testLocationData);

          // Assert
          verify(
            mockDio.post(
              '/api/location/sessions/$sessionId/locations',
              data: anyNamed('data'),
            ),
          ).called(1);
        },
      );

      test('getLocationSessions should delegate to getUserSessions', () async {
        // Arrange
        final responseData = {
          'sessions': [
            {
              'id': 'session_1',
              'name': 'Session 1',
              'startTime': '2024-01-01T10:00:00.000Z',
              'endTime': null,
              'locations': [],
              'isActive': true,
              'description': null,
            },
          ],
        };

        when(mockDio.get('/api/location/sessions')).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/location/sessions'),
          ),
        );

        // Act
        final result = await repository.getLocationSessions();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals('session_1'));
      });

      test('deleteLocationSession should delegate to deleteSession', () async {
        // Arrange
        const sessionId = 'session_123';
        when(mockDio.delete('/api/location/sessions/$sessionId')).thenAnswer(
          (_) async => Response(
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId',
            ),
          ),
        );

        // Act
        await repository.deleteLocationSession(sessionId);

        // Assert
        verify(mockDio.delete('/api/location/sessions/$sessionId')).called(1);
      });

      test('exportLocationSession should return true on success', () async {
        // Arrange
        const sessionId = 'session_123';
        when(
          mockDio.get('/api/location/sessions/$sessionId/export'),
        ).thenAnswer(
          (_) async => Response(
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId/export',
            ),
          ),
        );

        // Act
        final result = await repository.exportLocationSession(sessionId);

        // Assert
        expect(result, isTrue);
        verify(
          mockDio.get('/api/location/sessions/$sessionId/export'),
        ).called(1);
      });

      test('exportLocationSession should return false on error', () async {
        // Arrange
        const sessionId = 'session_123';
        when(mockDio.get('/api/location/sessions/$sessionId/export')).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/location/sessions/$sessionId/export',
            ),
          ),
        );

        // Act
        final result = await repository.exportLocationSession(sessionId);

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
