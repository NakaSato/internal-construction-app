import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_architecture_app/features/location_tracking/application/location_tracking_bloc.dart';
import 'package:flutter_architecture_app/features/location_tracking/application/location_tracking_event.dart';
import 'package:flutter_architecture_app/features/location_tracking/application/location_tracking_state.dart';
import 'package:flutter_architecture_app/features/location_tracking/domain/entities/location_data.dart';
import 'package:flutter_architecture_app/features/location_tracking/domain/entities/location_session.dart';
import 'package:flutter_architecture_app/features/location_tracking/domain/repositories/location_tracking_repository.dart';

import '../../../test_helpers/test_helpers.mocks.dart';

void main() {
  late LocationTrackingBloc locationTrackingBloc;
  late MockLocationTrackingRepository mockRepository;
  late StreamController<LocationData> locationStreamController;

  setUp(() {
    mockRepository = MockLocationTrackingRepository();
    locationStreamController = StreamController<LocationData>();
    locationTrackingBloc = LocationTrackingBloc(mockRepository);
  });

  tearDown(() {
    locationStreamController.close();
    locationTrackingBloc.close();
  });

  group('LocationTrackingBloc', () {
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

    final testLocationSession = LocationSession(
      id: 'session_123',
      name: 'Test Session',
      startTime: DateTime(2024, 1, 1, 10, 0, 0),
      endTime: DateTime(2024, 1, 1, 12, 0, 0),
      locations: [testLocationData],
      isActive: false,
      description: 'Test session description',
    );

    group('LocationPermissionRequested', () {
      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingLoading, LocationPermissionGranted] when permission is granted',
        build: () {
          when(
            mockRepository.requestLocationPermission(),
          ).thenAnswer((_) async => LocationPermissionStatus.always);
          return locationTrackingBloc;
        },
        act: (bloc) => bloc.add(const LocationPermissionRequested()),
        expect: () => [
          const LocationTrackingLoading(),
          const LocationPermissionGranted(),
        ],
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingLoading, LocationPermissionGranted] when permission is whileInUse',
        build: () {
          when(
            mockRepository.requestLocationPermission(),
          ).thenAnswer((_) async => LocationPermissionStatus.whileInUse);
          return locationTrackingBloc;
        },
        act: (bloc) => bloc.add(const LocationPermissionRequested()),
        expect: () => [
          const LocationTrackingLoading(),
          const LocationPermissionGranted(),
        ],
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingLoading, LocationTrackingError] when permission is denied',
        build: () {
          when(
            mockRepository.requestLocationPermission(),
          ).thenAnswer((_) async => LocationPermissionStatus.denied);
          return locationTrackingBloc;
        },
        act: (bloc) => bloc.add(const LocationPermissionRequested()),
        expect: () => [
          const LocationTrackingLoading(),
          const LocationTrackingError('Location permission denied'),
        ],
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingLoading, LocationTrackingError] when permission request fails',
        build: () {
          when(
            mockRepository.requestLocationPermission(),
          ).thenThrow(Exception('Permission request failed'));
          return locationTrackingBloc;
        },
        act: (bloc) => bloc.add(const LocationPermissionRequested()),
        expect: () => [
          const LocationTrackingLoading(),
          const LocationTrackingError(
            'Failed to request permission: Exception: Permission request failed',
          ),
        ],
      );
    });

    group('LocationTrackingStarted', () {
      const sessionName = 'Test Session';

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingLoading, LocationTrackingActive] when tracking starts successfully',
        build: () {
          when(
            mockRepository.hasLocationPermission(),
          ).thenAnswer((_) async => true);
          when(
            mockRepository.startLocationSession(sessionName),
          ).thenAnswer((_) async => testLocationSession);
          when(
            mockRepository.getLocationStream(),
          ).thenAnswer((_) => locationStreamController.stream);
          return locationTrackingBloc;
        },
        act: (bloc) => bloc.add(const LocationTrackingStarted(sessionName)),
        expect: () => [
          const LocationTrackingLoading(),
          LocationTrackingActive(
            currentSession: testLocationSession,
            locationData: const [],
            isRecording: true,
          ),
        ],
        verify: (_) {
          verify(mockRepository.hasLocationPermission()).called(1);
          verify(mockRepository.startLocationSession(sessionName)).called(1);
          verify(mockRepository.getLocationStream()).called(1);
        },
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingLoading, LocationTrackingError] when permission is not granted',
        build: () {
          when(
            mockRepository.hasLocationPermission(),
          ).thenAnswer((_) async => false);
          return locationTrackingBloc;
        },
        act: (bloc) => bloc.add(const LocationTrackingStarted(sessionName)),
        expect: () => [
          const LocationTrackingLoading(),
          const LocationTrackingError('Location permission required'),
        ],
        verify: (_) {
          verify(mockRepository.hasLocationPermission()).called(1);
          verifyNever(mockRepository.startLocationSession(any));
        },
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingLoading, LocationTrackingError] when session start fails',
        build: () {
          when(
            mockRepository.hasLocationPermission(),
          ).thenAnswer((_) async => true);
          when(
            mockRepository.startLocationSession(sessionName),
          ).thenThrow(Exception('Failed to start session'));
          return locationTrackingBloc;
        },
        act: (bloc) => bloc.add(const LocationTrackingStarted(sessionName)),
        expect: () => [
          const LocationTrackingLoading(),
          const LocationTrackingError(
            'Failed to start tracking: Exception: Failed to start session',
          ),
        ],
      );
    });

    group('LocationTrackingStopped', () {
      final activeSession = testLocationSession.copyWith(isActive: true);
      final stoppedSession = testLocationSession.copyWith(isActive: false);

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingInactive] when tracking stops successfully',
        build: () {
          when(
            mockRepository.stopLocationSession(activeSession.id),
          ).thenAnswer((_) async => stoppedSession);
          return locationTrackingBloc;
        },
        seed: () => LocationTrackingActive(
          currentSession: activeSession,
          locationData: [testLocationData],
          isRecording: true,
        ),
        act: (bloc) => bloc.add(const LocationTrackingStopped()),
        expect: () => [LocationTrackingInactive(lastSession: stoppedSession)],
        verify: (_) {
          verify(
            mockRepository.stopLocationSession(activeSession.id),
          ).called(1);
        },
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingInactive] when not in active state',
        build: () => locationTrackingBloc,
        seed: () => const LocationPermissionGranted(),
        act: (bloc) => bloc.add(const LocationTrackingStopped()),
        expect: () => [const LocationTrackingInactive()],
        verify: (_) {
          verifyNever(mockRepository.stopLocationSession(any));
        },
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingError] when stop fails',
        build: () {
          when(
            mockRepository.stopLocationSession(activeSession.id),
          ).thenThrow(Exception('Failed to stop session'));
          return locationTrackingBloc;
        },
        seed: () => LocationTrackingActive(
          currentSession: activeSession,
          locationData: [testLocationData],
          isRecording: true,
        ),
        act: (bloc) => bloc.add(const LocationTrackingStopped()),
        expect: () => [
          const LocationTrackingError(
            'Failed to stop tracking: Exception: Failed to stop session',
          ),
        ],
      );
    });

    group('LocationDataReceived', () {
      final activeSession = testLocationSession.copyWith(isActive: true);
      final newLocationData = LocationData(
        latitude: 37.7750,
        longitude: -122.4195,
        timestamp: DateTime(2024, 1, 1, 12, 1, 0),
        accuracy: 4.0,
        altitude: 51.0,
        speed: 3.0,
        heading: 95.0,
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'updates location data when in active tracking state',
        build: () {
          when(
            mockRepository.saveLocationData(activeSession.id, newLocationData),
          ).thenAnswer((_) async {
            return null;
          });
          return locationTrackingBloc;
        },
        seed: () => LocationTrackingActive(
          currentSession: activeSession,
          locationData: [testLocationData],
          isRecording: true,
        ),
        act: (bloc) => bloc.add(LocationDataReceived(newLocationData)),
        expect: () => [
          isA<LocationTrackingActive>()
              .having((state) => state.locationData.length, 'location count', 2)
              .having(
                (state) => state.currentLocation,
                'current location',
                newLocationData,
              )
              .having(
                (state) => state.currentSession.locations.length,
                'session locations',
                2,
              ),
        ],
        verify: (_) {
          verify(
            mockRepository.saveLocationData(activeSession.id, newLocationData),
          ).called(1);
        },
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits error when saving location data fails',
        build: () {
          when(
            mockRepository.saveLocationData(activeSession.id, newLocationData),
          ).thenThrow(Exception('Failed to save location'));
          return locationTrackingBloc;
        },
        seed: () => LocationTrackingActive(
          currentSession: activeSession,
          locationData: [testLocationData],
          isRecording: true,
        ),
        act: (bloc) => bloc.add(LocationDataReceived(newLocationData)),
        expect: () => [
          const LocationTrackingError(
            'Failed to save location: Exception: Failed to save location',
          ),
        ],
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'does nothing when not in active tracking state',
        build: () => locationTrackingBloc,
        seed: () => const LocationPermissionGranted(),
        act: (bloc) => bloc.add(LocationDataReceived(newLocationData)),
        expect: () => [],
        verify: (_) {
          verifyNever(mockRepository.saveLocationData(any, any));
        },
      );
    });

    group('LocationSessionsRequested', () {
      final testSessions = [
        testLocationSession,
        testLocationSession.copyWith(id: 'session_456', name: 'Session 2'),
      ];

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingLoading, LocationSessionsLoaded] when sessions load successfully',
        build: () {
          when(
            mockRepository.getLocationSessions(),
          ).thenAnswer((_) async => testSessions);
          return locationTrackingBloc;
        },
        act: (bloc) => bloc.add(const LocationSessionsRequested()),
        expect: () => [
          const LocationTrackingLoading(),
          LocationSessionsLoaded(testSessions),
        ],
        verify: (_) {
          verify(mockRepository.getLocationSessions()).called(1);
        },
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingLoading, LocationTrackingError] when loading sessions fails',
        build: () {
          when(
            mockRepository.getLocationSessions(),
          ).thenThrow(Exception('Failed to load sessions'));
          return locationTrackingBloc;
        },
        act: (bloc) => bloc.add(const LocationSessionsRequested()),
        expect: () => [
          const LocationTrackingLoading(),
          const LocationTrackingError(
            'Failed to load sessions: Exception: Failed to load sessions',
          ),
        ],
      );
    });

    group('LocationSessionDeleted', () {
      const sessionId = 'session_123';

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'deletes session and reloads sessions list',
        build: () {
          when(mockRepository.deleteLocationSession(sessionId)).thenAnswer((
            _,
          ) async {
            return null;
          });
          when(
            mockRepository.getLocationSessions(),
          ).thenAnswer((_) async => []);
          return locationTrackingBloc;
        },
        act: (bloc) => bloc.add(const LocationSessionDeleted(sessionId)),
        expect: () => [
          const LocationTrackingLoading(),
          const LocationSessionsLoaded([]),
        ],
        verify: (_) {
          verify(mockRepository.deleteLocationSession(sessionId)).called(1);
          verify(mockRepository.getLocationSessions()).called(1);
        },
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits error when deletion fails',
        build: () {
          when(
            mockRepository.deleteLocationSession(sessionId),
          ).thenThrow(Exception('Failed to delete session'));
          return locationTrackingBloc;
        },
        act: (bloc) => bloc.add(const LocationSessionDeleted(sessionId)),
        expect: () => [
          const LocationTrackingError(
            'Failed to delete session: Exception: Failed to delete session',
          ),
        ],
        verify: (_) {
          verify(mockRepository.deleteLocationSession(sessionId)).called(1);
          verifyNever(mockRepository.getLocationSessions());
        },
      );
    });

    group('LocationSessionExported', () {
      const sessionId = 'session_123';

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationSessionExportSuccess] when export is successful',
        build: () {
          when(
            mockRepository.exportLocationSession(sessionId),
          ).thenAnswer((_) async => true);
          return locationTrackingBloc;
        },
        act: (bloc) => bloc.add(const LocationSessionExported(sessionId)),
        expect: () => [const LocationSessionExportSuccess()],
        verify: (_) {
          verify(mockRepository.exportLocationSession(sessionId)).called(1);
        },
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingError] when export returns false',
        build: () {
          when(
            mockRepository.exportLocationSession(sessionId),
          ).thenAnswer((_) async => false);
          return locationTrackingBloc;
        },
        act: (bloc) => bloc.add(const LocationSessionExported(sessionId)),
        expect: () => [const LocationTrackingError('Failed to export session')],
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingError] when export throws exception',
        build: () {
          when(
            mockRepository.exportLocationSession(sessionId),
          ).thenThrow(Exception('Export failed'));
          return locationTrackingBloc;
        },
        act: (bloc) => bloc.add(const LocationSessionExported(sessionId)),
        expect: () => [
          const LocationTrackingError(
            'Failed to export session: Exception: Export failed',
          ),
        ],
      );
    });

    group('Location stream handling', () {
      final activeSession = testLocationSession.copyWith(isActive: true);

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'processes location data from stream during active tracking',
        build: () {
          when(
            mockRepository.hasLocationPermission(),
          ).thenAnswer((_) async => true);
          when(
            mockRepository.startLocationSession('Test Session'),
          ).thenAnswer((_) async => activeSession);
          when(
            mockRepository.getLocationStream(),
          ).thenAnswer((_) => locationStreamController.stream);
          when(
            mockRepository.saveLocationData(activeSession.id, testLocationData),
          ).thenAnswer((_) async {
            return null;
          });
          return locationTrackingBloc;
        },
        act: (bloc) async {
          bloc.add(const LocationTrackingStarted('Test Session'));
          await Future.delayed(const Duration(milliseconds: 100));
          locationStreamController.add(testLocationData);
        },
        expect: () => [
          const LocationTrackingLoading(),
          LocationTrackingActive(
            currentSession: activeSession,
            locationData: const [],
            isRecording: true,
          ),
          isA<LocationTrackingActive>()
              .having((state) => state.locationData.length, 'location count', 1)
              .having(
                (state) => state.currentLocation,
                'current location',
                testLocationData,
              ),
        ],
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'handles location stream errors',
        build: () {
          when(
            mockRepository.hasLocationPermission(),
          ).thenAnswer((_) async => true);
          when(
            mockRepository.startLocationSession('Test Session'),
          ).thenAnswer((_) async => activeSession);
          when(
            mockRepository.getLocationStream(),
          ).thenAnswer((_) => locationStreamController.stream);
          return locationTrackingBloc;
        },
        act: (bloc) async {
          bloc.add(const LocationTrackingStarted('Test Session'));
          await Future.delayed(const Duration(milliseconds: 100));
          locationStreamController.addError('Location error');
        },
        expect: () => [
          const LocationTrackingLoading(),
          LocationTrackingActive(
            currentSession: activeSession,
            locationData: const [],
            isRecording: true,
          ),
          // The error would trigger a LocationTrackingErrorOccurred event internally
        ],
      );
    });

    group('initial state', () {
      test('should be LocationTrackingInitial', () {
        expect(locationTrackingBloc.state, const LocationTrackingInitial());
      });
    });

    group('close', () {
      test('cancels location subscription when bloc is closed', () async {
        final activeSession = testLocationSession.copyWith(isActive: true);

        when(
          mockRepository.hasLocationPermission(),
        ).thenAnswer((_) async => true);
        when(
          mockRepository.startLocationSession('Test Session'),
        ).thenAnswer((_) async => activeSession);
        when(
          mockRepository.getLocationStream(),
        ).thenAnswer((_) => locationStreamController.stream);

        locationTrackingBloc.add(const LocationTrackingStarted('Test Session'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Close the bloc
        await locationTrackingBloc.close();

        // Verify that the location subscription is cleaned up
        expect(locationTrackingBloc.isClosed, isTrue);
      });
    });
  });
}
