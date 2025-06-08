import 'package:equatable/equatable.dart';

import '../domain/entities/location_data.dart';

/// Base class for location tracking events
abstract class LocationTrackingEvent extends Equatable {
  const LocationTrackingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request location permission
class LocationPermissionRequested extends LocationTrackingEvent {
  const LocationPermissionRequested();
}

/// Event to start location tracking
class LocationTrackingStarted extends LocationTrackingEvent {
  const LocationTrackingStarted(this.sessionName);

  final String sessionName;

  @override
  List<Object> get props => [sessionName];
}

/// Event to stop location tracking
class LocationTrackingStopped extends LocationTrackingEvent {
  const LocationTrackingStopped();
}

/// Event when new location data is received
class LocationDataReceived extends LocationTrackingEvent {
  const LocationDataReceived(this.locationData);

  final LocationData locationData;

  @override
  List<Object> get props => [locationData];
}

/// Event to request loading of location sessions
class LocationSessionsRequested extends LocationTrackingEvent {
  const LocationSessionsRequested();
}

/// Event to delete a location session
class LocationSessionDeleted extends LocationTrackingEvent {
  const LocationSessionDeleted(this.sessionId);

  final String sessionId;

  @override
  List<Object> get props => [sessionId];
}

/// Event to export a location session
class LocationSessionExported extends LocationTrackingEvent {
  const LocationSessionExported(this.sessionId);

  final String sessionId;

  @override
  List<Object> get props => [sessionId];
}

// Legacy events for backward compatibility (can be removed if not used elsewhere)

/// Event to start a new tracking session
class StartTrackingSessionEvent extends LocationTrackingEvent {
  const StartTrackingSessionEvent({required this.name, this.description});

  final String name;
  final String? description;

  @override
  List<Object?> get props => [name, description];
}

/// Event to stop the current tracking session
class StopTrackingSessionEvent extends LocationTrackingEvent {
  const StopTrackingSessionEvent(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

/// Event to load user sessions
class LoadUserSessionsEvent extends LocationTrackingEvent {
  const LoadUserSessionsEvent();
}

/// Event to load a specific session
class LoadSessionEvent extends LocationTrackingEvent {
  const LoadSessionEvent(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

/// Event to delete a session
class DeleteSessionEvent extends LocationTrackingEvent {
  const DeleteSessionEvent(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

/// Event to update session metadata
class UpdateSessionEvent extends LocationTrackingEvent {
  const UpdateSessionEvent({
    required this.sessionId,
    this.name,
    this.description,
  });

  final String sessionId;
  final String? name;
  final String? description;

  @override
  List<Object?> get props => [sessionId, name, description];
}

/// Event to get current location
class GetCurrentLocationEvent extends LocationTrackingEvent {
  const GetCurrentLocationEvent();
}

/// Event when location is updated
class LocationUpdatedEvent extends LocationTrackingEvent {
  const LocationUpdatedEvent(this.location);

  final LocationData location;

  @override
  List<Object?> get props => [location];
}

/// Event to check location permission
class CheckLocationPermissionEvent extends LocationTrackingEvent {
  const CheckLocationPermissionEvent();
}

/// Event to request location permission
class RequestLocationPermissionEvent extends LocationTrackingEvent {
  const RequestLocationPermissionEvent();
}

/// Event to check active session
class CheckActiveSessionEvent extends LocationTrackingEvent {
  const CheckActiveSessionEvent();
}

/// Event to start location stream
class StartLocationStreamEvent extends LocationTrackingEvent {
  const StartLocationStreamEvent();
}

/// Event to stop location stream
class StopLocationStreamEvent extends LocationTrackingEvent {
  const StopLocationStreamEvent();
}
