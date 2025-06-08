import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:location/location.dart' as loc;

import '../../domain/entities/location_data.dart';
import '../../domain/entities/location_session.dart';
import '../../domain/repositories/location_tracking_repository.dart';

/// API-based implementation of LocationTrackingRepository
@LazySingleton(as: LocationTrackingRepository)
class ApiLocationTrackingRepository implements LocationTrackingRepository {
  ApiLocationTrackingRepository(this._dio, this._location);

  final Dio _dio;
  final loc.Location _location;

  StreamController<LocationData>? _locationStreamController;

  @override
  Future<LocationSession> startSession({
    required String name,
    String? description,
  }) async {
    try {
      final data = {
        'name': name,
        if (description != null) 'description': description,
      };

      final response = await _dio.post('/api/location/sessions', data: data);

      final sessionData = response.data;
      return LocationSession(
        id: sessionData['id'] as String,
        name: sessionData['name'] as String,
        startTime: DateTime.parse(sessionData['startTime'] as String),
        endTime: sessionData['endTime'] != null
            ? DateTime.parse(sessionData['endTime'] as String)
            : null,
        locations:
            (sessionData['locations'] as List<dynamic>?)
                ?.map(
                  (locData) => LocationData(
                    latitude: (locData['latitude'] as num).toDouble(),
                    longitude: (locData['longitude'] as num).toDouble(),
                    timestamp: DateTime.parse(locData['timestamp'] as String),
                    accuracy: (locData['accuracy'] as num?)?.toDouble(),
                    altitude: (locData['altitude'] as num?)?.toDouble(),
                    speed: (locData['speed'] as num?)?.toDouble(),
                    heading: (locData['heading'] as num?)?.toDouble(),
                    address: locData['address'] as String?,
                  ),
                )
                .toList() ??
            [],
        isActive: sessionData['isActive'] as bool? ?? false,
        description: sessionData['description'] as String?,
      );
    } catch (e) {
      throw Exception('Failed to start location session: $e');
    }
  }

  @override
  Future<LocationSession> stopSession(String sessionId) async {
    try {
      final response = await _dio.put('/api/location/sessions/$sessionId/stop');

      final sessionData = response.data;
      return LocationSession(
        id: sessionData['id'] as String,
        name: sessionData['name'] as String,
        startTime: DateTime.parse(sessionData['startTime'] as String),
        endTime: sessionData['endTime'] != null
            ? DateTime.parse(sessionData['endTime'] as String)
            : null,
        locations:
            (sessionData['locations'] as List<dynamic>?)
                ?.map(
                  (locData) => LocationData(
                    latitude: (locData['latitude'] as num).toDouble(),
                    longitude: (locData['longitude'] as num).toDouble(),
                    timestamp: DateTime.parse(locData['timestamp'] as String),
                    accuracy: (locData['accuracy'] as num?)?.toDouble(),
                    altitude: (locData['altitude'] as num?)?.toDouble(),
                    speed: (locData['speed'] as num?)?.toDouble(),
                    heading: (locData['heading'] as num?)?.toDouble(),
                    address: locData['address'] as String?,
                  ),
                )
                .toList() ??
            [],
        isActive: sessionData['isActive'] as bool? ?? false,
        description: sessionData['description'] as String?,
      );
    } catch (e) {
      throw Exception('Failed to stop location session: $e');
    }
  }

  @override
  Future<void> addLocationToSession({
    required String sessionId,
    required LocationData location,
  }) async {
    try {
      final data = {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'timestamp': location.timestamp.toIso8601String(),
        if (location.accuracy != null) 'accuracy': location.accuracy,
        if (location.altitude != null) 'altitude': location.altitude,
        if (location.speed != null) 'speed': location.speed,
        if (location.heading != null) 'heading': location.heading,
        if (location.address != null) 'address': location.address,
      };

      await _dio.post(
        '/api/location/sessions/$sessionId/locations',
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to add location to session: $e');
    }
  }

  @override
  Future<LocationData> getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();

      return LocationData(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          locationData.time!.toInt(),
        ),
        accuracy: locationData.accuracy,
        altitude: locationData.altitude,
        speed: locationData.speed,
        heading: locationData.heading,
      );
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  @override
  Stream<LocationData> getLocationStream() {
    _locationStreamController?.close();
    _locationStreamController = StreamController<LocationData>();

    _location.onLocationChanged.listen(
      (locationData) {
        if (!_locationStreamController!.isClosed) {
          _locationStreamController!.add(
            LocationData(
              latitude: locationData.latitude!,
              longitude: locationData.longitude!,
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                locationData.time!.toInt(),
              ),
              accuracy: locationData.accuracy,
              altitude: locationData.altitude,
              speed: locationData.speed,
              heading: locationData.heading,
            ),
          );
        }
      },
      onError: (error) {
        if (!_locationStreamController!.isClosed) {
          _locationStreamController!.addError(error);
        }
      },
    );

    return _locationStreamController!.stream;
  }

  @override
  Future<List<LocationSession>> getUserSessions() async {
    try {
      final response = await _dio.get('/api/location/sessions');

      return (response.data['sessions'] as List<dynamic>)
          .map(
            (sessionData) => LocationSession(
              id: sessionData['id'] as String,
              name: sessionData['name'] as String,
              startTime: DateTime.parse(sessionData['startTime'] as String),
              endTime: sessionData['endTime'] != null
                  ? DateTime.parse(sessionData['endTime'] as String)
                  : null,
              locations:
                  (sessionData['locations'] as List<dynamic>?)
                      ?.map(
                        (locData) => LocationData(
                          latitude: (locData['latitude'] as num).toDouble(),
                          longitude: (locData['longitude'] as num).toDouble(),
                          timestamp: DateTime.parse(
                            locData['timestamp'] as String,
                          ),
                          accuracy: (locData['accuracy'] as num?)?.toDouble(),
                          altitude: (locData['altitude'] as num?)?.toDouble(),
                          speed: (locData['speed'] as num?)?.toDouble(),
                          heading: (locData['heading'] as num?)?.toDouble(),
                          address: locData['address'] as String?,
                        ),
                      )
                      .toList() ??
                  [],
              isActive: sessionData['isActive'] as bool? ?? false,
              description: sessionData['description'] as String?,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get user sessions: $e');
    }
  }

  @override
  Future<LocationSession?> getSessionById(String sessionId) async {
    try {
      final response = await _dio.get('/api/location/sessions/$sessionId');

      if (response.statusCode == 404) {
        return null;
      }

      final sessionData = response.data;
      return LocationSession(
        id: sessionData['id'] as String,
        name: sessionData['name'] as String,
        startTime: DateTime.parse(sessionData['startTime'] as String),
        endTime: sessionData['endTime'] != null
            ? DateTime.parse(sessionData['endTime'] as String)
            : null,
        locations:
            (sessionData['locations'] as List<dynamic>?)
                ?.map(
                  (locData) => LocationData(
                    latitude: (locData['latitude'] as num).toDouble(),
                    longitude: (locData['longitude'] as num).toDouble(),
                    timestamp: DateTime.parse(locData['timestamp'] as String),
                    accuracy: (locData['accuracy'] as num?)?.toDouble(),
                    altitude: (locData['altitude'] as num?)?.toDouble(),
                    speed: (locData['speed'] as num?)?.toDouble(),
                    heading: (locData['heading'] as num?)?.toDouble(),
                    address: locData['address'] as String?,
                  ),
                )
                .toList() ??
            [],
        isActive: sessionData['isActive'] as bool? ?? false,
        description: sessionData['description'] as String?,
      );
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to get session by ID: $e');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      await _dio.delete('/api/location/sessions/$sessionId');
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  @override
  Future<LocationSession> updateSession({
    required String sessionId,
    String? name,
    String? description,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;

      final response = await _dio.put(
        '/api/location/sessions/$sessionId',
        data: data,
      );

      final sessionData = response.data;
      return LocationSession(
        id: sessionData['id'] as String,
        name: sessionData['name'] as String,
        startTime: DateTime.parse(sessionData['startTime'] as String),
        endTime: sessionData['endTime'] != null
            ? DateTime.parse(sessionData['endTime'] as String)
            : null,
        locations:
            (sessionData['locations'] as List<dynamic>?)
                ?.map(
                  (locData) => LocationData(
                    latitude: (locData['latitude'] as num).toDouble(),
                    longitude: (locData['longitude'] as num).toDouble(),
                    timestamp: DateTime.parse(locData['timestamp'] as String),
                    accuracy: (locData['accuracy'] as num?)?.toDouble(),
                    altitude: (locData['altitude'] as num?)?.toDouble(),
                    speed: (locData['speed'] as num?)?.toDouble(),
                    heading: (locData['heading'] as num?)?.toDouble(),
                    address: locData['address'] as String?,
                  ),
                )
                .toList() ??
            [],
        isActive: sessionData['isActive'] as bool? ?? false,
        description: sessionData['description'] as String?,
      );
    } catch (e) {
      throw Exception('Failed to update session: $e');
    }
  }

  Future<String> _exportSessionData(String sessionId) async {
    try {
      final response = await _dio.get(
        '/api/location/sessions/$sessionId/export',
      );
      return response.data['exportData'] as String;
    } catch (e) {
      throw Exception('Failed to export session: $e');
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await _location.serviceEnabled();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<LocationPermissionStatus> checkLocationPermission() async {
    try {
      final permission = await _location.hasPermission();
      switch (permission) {
        case loc.PermissionStatus.granted:
        case loc.PermissionStatus.grantedLimited:
          return LocationPermissionStatus.whileInUse;
        case loc.PermissionStatus.denied:
          return LocationPermissionStatus.denied;
        case loc.PermissionStatus.deniedForever:
          return LocationPermissionStatus.deniedForever;
      }
    } catch (e) {
      return LocationPermissionStatus.unableToDetermine;
    }
  }

  @override
  Future<LocationPermissionStatus> requestLocationPermission() async {
    try {
      final permission = await _location.requestPermission();
      switch (permission) {
        case loc.PermissionStatus.granted:
        case loc.PermissionStatus.grantedLimited:
          return LocationPermissionStatus.whileInUse;
        case loc.PermissionStatus.denied:
          return LocationPermissionStatus.denied;
        case loc.PermissionStatus.deniedForever:
          return LocationPermissionStatus.deniedForever;
      }
    } catch (e) {
      return LocationPermissionStatus.unableToDetermine;
    }
  }

  @override
  Future<LocationSession?> getActiveSession() async {
    try {
      final response = await _dio.get('/api/location/sessions/active');

      if (response.statusCode == 404) {
        return null;
      }

      final sessionData = response.data;
      return LocationSession(
        id: sessionData['id'] as String,
        name: sessionData['name'] as String,
        startTime: DateTime.parse(sessionData['startTime'] as String),
        endTime: sessionData['endTime'] != null
            ? DateTime.parse(sessionData['endTime'] as String)
            : null,
        locations:
            (sessionData['locations'] as List<dynamic>?)
                ?.map(
                  (locData) => LocationData(
                    latitude: (locData['latitude'] as num).toDouble(),
                    longitude: (locData['longitude'] as num).toDouble(),
                    timestamp: DateTime.parse(locData['timestamp'] as String),
                    accuracy: (locData['accuracy'] as num?)?.toDouble(),
                    altitude: (locData['altitude'] as num?)?.toDouble(),
                    speed: (locData['speed'] as num?)?.toDouble(),
                    heading: (locData['heading'] as num?)?.toDouble(),
                    address: locData['address'] as String?,
                  ),
                )
                .toList() ??
            [],
        isActive: sessionData['isActive'] as bool? ?? true,
        description: sessionData['description'] as String?,
      );
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to get active session: $e');
    }
  }

  // Compatibility methods for BLoC
  @override
  Future<bool> hasLocationPermission() async {
    final status = await checkLocationPermission();
    return status == LocationPermissionStatus.whileInUse ||
        status == LocationPermissionStatus.always;
  }

  @override
  Future<LocationSession> startLocationSession(String name) async {
    return startSession(name: name);
  }

  @override
  Future<LocationSession> stopLocationSession(String sessionId) async {
    return stopSession(sessionId);
  }

  @override
  Future<void> saveLocationData(String sessionId, LocationData location) async {
    return addLocationToSession(sessionId: sessionId, location: location);
  }

  @override
  Future<List<LocationSession>> getLocationSessions() async {
    return getUserSessions();
  }

  @override
  Future<void> deleteLocationSession(String sessionId) async {
    return deleteSession(sessionId);
  }

  @override
  Future<bool> exportLocationSession(String sessionId) async {
    try {
      await _dio.get('/api/location/sessions/$sessionId/export');
      return true;
    } catch (e) {
      return false;
    }
  }
}
