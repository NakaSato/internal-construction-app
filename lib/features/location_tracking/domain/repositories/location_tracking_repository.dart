import '../entities/location_data.dart';
import '../entities/location_session.dart';

/// Repository interface for location tracking operations
abstract class LocationTrackingRepository {
  /// Start a new location tracking session
  Future<LocationSession> startSession({
    required String name,
    String? description,
  });

  /// Stop the current active session
  Future<LocationSession> stopSession(String sessionId);

  /// Add location data to an active session
  Future<void> addLocationToSession({
    required String sessionId,
    required LocationData location,
  });

  /// Get current location
  Future<LocationData> getCurrentLocation();

  /// Get location stream for real-time tracking
  Stream<LocationData> getLocationStream();

  /// Get all sessions for the current user
  Future<List<LocationSession>> getUserSessions();

  /// Get a specific session by ID
  Future<LocationSession?> getSessionById(String sessionId);

  /// Delete a session
  Future<void> deleteSession(String sessionId);

  /// Update session metadata
  Future<LocationSession> updateSession({
    required String sessionId,
    String? name,
    String? description,
  });

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled();

  /// Check location permission status
  Future<LocationPermissionStatus> checkLocationPermission();

  /// Request location permission
  Future<LocationPermissionStatus> requestLocationPermission();

  /// Get active session if any
  Future<LocationSession?> getActiveSession();

  // Methods expected by BLoC - add these for compatibility
  /// Check if location permission is granted (convenience method)
  Future<bool> hasLocationPermission();

  /// Start location session with simple name (compatibility method)
  Future<LocationSession> startLocationSession(String name);

  /// Stop location session (compatibility method)
  Future<LocationSession> stopLocationSession(String sessionId);

  /// Save location data (compatibility method)
  Future<void> saveLocationData(String sessionId, LocationData location);

  /// Get location sessions (compatibility method)
  Future<List<LocationSession>> getLocationSessions();

  /// Delete location session (compatibility method)
  Future<void> deleteLocationSession(String sessionId);

  /// Export location session (compatibility method)
  Future<bool> exportLocationSession(String sessionId);
}

/// Location permission status enum
enum LocationPermissionStatus {
  denied,
  deniedForever,
  whileInUse,
  always,
  unableToDetermine,
}
