import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../domain/entities/location_data.dart';
import '../domain/repositories/location_tracking_repository.dart';
import 'location_tracking_event.dart';
import 'location_tracking_state.dart';

/// BLoC for managing location tracking state and business logic
@injectable
class LocationTrackingBloc
    extends Bloc<LocationTrackingEvent, LocationTrackingState> {
  LocationTrackingBloc(this._repository)
    : super(const LocationTrackingInitial()) {
    on<LocationPermissionRequested>(_onLocationPermissionRequested);
    on<LocationTrackingStarted>(_onLocationTrackingStarted);
    on<LocationTrackingStopped>(_onLocationTrackingStopped);
    on<LocationDataReceived>(_onLocationDataReceived);
    on<LocationSessionsRequested>(_onLocationSessionsRequested);
    on<LocationSessionDeleted>(_onLocationSessionDeleted);
    on<LocationSessionExported>(_onLocationSessionExported);
  }

  final LocationTrackingRepository _repository;
  StreamSubscription<LocationData>? _locationSubscription;

  /// Handle location permission request
  Future<void> _onLocationPermissionRequested(
    LocationPermissionRequested event,
    Emitter<LocationTrackingState> emit,
  ) async {
    emit(const LocationTrackingLoading());

    try {
      final permissionStatus = await _repository.requestLocationPermission();

      if (permissionStatus == LocationPermissionStatus.always ||
          permissionStatus == LocationPermissionStatus.whileInUse) {
        emit(const LocationPermissionGranted());
      } else {
        emit(const LocationTrackingError('Location permission denied'));
      }
    } catch (e) {
      emit(LocationTrackingError('Failed to request permission: $e'));
    }
  }

  /// Handle starting location tracking
  Future<void> _onLocationTrackingStarted(
    LocationTrackingStarted event,
    Emitter<LocationTrackingState> emit,
  ) async {
    try {
      emit(const LocationTrackingLoading());

      // Check permission first
      final hasPermission = await _repository.hasLocationPermission();
      if (!hasPermission) {
        emit(const LocationTrackingError('Location permission required'));
        return;
      }

      // Start new session
      final session = await _repository.startLocationSession(event.sessionName);

      // Start listening to location updates
      _locationSubscription = _repository.getLocationStream().listen(
        (location) => add(LocationDataReceived(location)),
        onError: (error) =>
            add(LocationTrackingErrorOccurred(error.toString())),
      );

      emit(
        LocationTrackingActive(
          currentSession: session,
          locationData: const [],
          isRecording: true,
        ),
      );
    } catch (e) {
      emit(LocationTrackingError('Failed to start tracking: $e'));
    }
  }

  /// Handle stopping location tracking
  Future<void> _onLocationTrackingStopped(
    LocationTrackingStopped event,
    Emitter<LocationTrackingState> emit,
  ) async {
    try {
      await _locationSubscription?.cancel();
      _locationSubscription = null;

      if (state is LocationTrackingActive) {
        final activeState = state as LocationTrackingActive;
        final updatedSession = await _repository.stopLocationSession(
          activeState.currentSession.id,
        );

        emit(LocationTrackingInactive(lastSession: updatedSession));
      } else {
        emit(const LocationTrackingInactive());
      }
    } catch (e) {
      emit(LocationTrackingError('Failed to stop tracking: $e'));
    }
  }

  /// Handle new location data
  Future<void> _onLocationDataReceived(
    LocationDataReceived event,
    Emitter<LocationTrackingState> emit,
  ) async {
    if (state is LocationTrackingActive) {
      final activeState = state as LocationTrackingActive;

      try {
        // Save location to repository
        await _repository.saveLocationData(
          activeState.currentSession.id,
          event.locationData,
        );

        // Update state with new location
        final updatedLocations = List<LocationData>.from(
          activeState.locationData,
        )..add(event.locationData);

        // Update session with new data
        final updatedSession = activeState.currentSession.copyWith(
          endTime: event.locationData.timestamp,
          locations: updatedLocations,
        );

        emit(
          activeState.copyWith(
            currentSession: updatedSession,
            locationData: updatedLocations,
            currentLocation: event.locationData,
          ),
        );
      } catch (e) {
        emit(LocationTrackingError('Failed to save location: $e'));
      }
    }
  }

  /// Handle loading location sessions
  Future<void> _onLocationSessionsRequested(
    LocationSessionsRequested event,
    Emitter<LocationTrackingState> emit,
  ) async {
    emit(const LocationTrackingLoading());

    try {
      final sessions = await _repository.getLocationSessions();
      emit(LocationSessionsLoaded(sessions));
    } catch (e) {
      emit(LocationTrackingError('Failed to load sessions: $e'));
    }
  }

  /// Handle deleting a location session
  Future<void> _onLocationSessionDeleted(
    LocationSessionDeleted event,
    Emitter<LocationTrackingState> emit,
  ) async {
    try {
      await _repository.deleteLocationSession(event.sessionId);

      // Reload sessions
      add(const LocationSessionsRequested());
    } catch (e) {
      emit(LocationTrackingError('Failed to delete session: $e'));
    }
  }

  /// Handle exporting a location session
  Future<void> _onLocationSessionExported(
    LocationSessionExported event,
    Emitter<LocationTrackingState> emit,
  ) async {
    try {
      final exported = await _repository.exportLocationSession(event.sessionId);

      if (exported) {
        // Could emit a success message or show snackbar
        emit(const LocationSessionExportSuccess());
      } else {
        emit(const LocationTrackingError('Failed to export session'));
      }
    } catch (e) {
      emit(LocationTrackingError('Failed to export session: $e'));
    }
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}

/// Additional event for internal error handling
class LocationTrackingErrorOccurred extends LocationTrackingEvent {
  const LocationTrackingErrorOccurred(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
