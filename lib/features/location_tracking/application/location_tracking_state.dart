import 'package:equatable/equatable.dart';

import '../domain/entities/location_data.dart';
import '../domain/entities/location_session.dart';

/// Base class for location tracking states
abstract class LocationTrackingState extends Equatable {
  const LocationTrackingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class LocationTrackingInitial extends LocationTrackingState {
  const LocationTrackingInitial();
}

/// Loading state
class LocationTrackingLoading extends LocationTrackingState {
  const LocationTrackingLoading({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Permission granted state
class LocationPermissionGranted extends LocationTrackingState {
  const LocationPermissionGranted();
}

/// Active tracking state
class LocationTrackingActive extends LocationTrackingState {
  const LocationTrackingActive({
    required this.currentSession,
    required this.locationData,
    required this.isRecording,
    this.currentLocation,
  });

  final LocationSession currentSession;
  final List<LocationData> locationData;
  final bool isRecording;
  final LocationData? currentLocation;

  @override
  List<Object?> get props => [
    currentSession,
    locationData,
    isRecording,
    currentLocation,
  ];

  /// Copy with method for immutable updates
  LocationTrackingActive copyWith({
    LocationSession? currentSession,
    List<LocationData>? locationData,
    bool? isRecording,
    LocationData? currentLocation,
  }) {
    return LocationTrackingActive(
      currentSession: currentSession ?? this.currentSession,
      locationData: locationData ?? this.locationData,
      isRecording: isRecording ?? this.isRecording,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}

/// Inactive tracking state
class LocationTrackingInactive extends LocationTrackingState {
  const LocationTrackingInactive({this.lastSession});

  final LocationSession? lastSession;

  @override
  List<Object?> get props => [lastSession];
}

/// Sessions loaded state
class LocationSessionsLoaded extends LocationTrackingState {
  const LocationSessionsLoaded(this.sessions);

  final List<LocationSession> sessions;

  @override
  List<Object?> get props => [sessions];
}

/// Session export success state
class LocationSessionExportSuccess extends LocationTrackingState {
  const LocationSessionExportSuccess();
}

/// Error state
class LocationTrackingError extends LocationTrackingState {
  const LocationTrackingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// Legacy states for backward compatibility (can be removed if not used elsewhere)

/// Session started state
class SessionStarted extends LocationTrackingState {
  const SessionStarted(this.session);

  final LocationSession session;

  @override
  List<Object?> get props => [session];
}

/// Session stopped state
class SessionStopped extends LocationTrackingState {
  const SessionStopped(this.session);

  final LocationSession session;

  @override
  List<Object?> get props => [session];
}

/// Sessions loaded state
class SessionsLoaded extends LocationTrackingState {
  const SessionsLoaded(this.sessions);

  final List<LocationSession> sessions;

  @override
  List<Object?> get props => [sessions];
}

/// Session loaded state
class SessionLoaded extends LocationTrackingState {
  const SessionLoaded(this.session);

  final LocationSession session;

  @override
  List<Object?> get props => [session];
}

/// Session deleted state
class SessionDeleted extends LocationTrackingState {
  const SessionDeleted(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

/// Session updated state
class SessionUpdated extends LocationTrackingState {
  const SessionUpdated(this.session);

  final LocationSession session;

  @override
  List<Object?> get props => [session];
}

/// Current location state
class CurrentLocationLoaded extends LocationTrackingState {
  const CurrentLocationLoaded(this.location);

  final LocationData location;

  @override
  List<Object?> get props => [location];
}

/// Location updated state (during tracking)
class LocationUpdated extends LocationTrackingState {
  const LocationUpdated({required this.location, this.activeSession});

  final LocationData location;
  final LocationSession? activeSession;

  @override
  List<Object?> get props => [location, activeSession];
}

/// Active session state
class ActiveSessionLoaded extends LocationTrackingState {
  const ActiveSessionLoaded(this.session);

  final LocationSession? session;

  @override
  List<Object?> get props => [session];
}

/// Location tracking state (when actively tracking)
class LocationTracking extends LocationTrackingState {
  const LocationTracking({required this.activeSession, this.currentLocation});

  final LocationSession activeSession;
  final LocationData? currentLocation;

  @override
  List<Object?> get props => [activeSession, currentLocation];
}

/// Permission denied state
class LocationPermissionDenied extends LocationTrackingState {
  const LocationPermissionDenied(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Location service disabled state
class LocationServiceDisabled extends LocationTrackingState {
  const LocationServiceDisabled();
}
