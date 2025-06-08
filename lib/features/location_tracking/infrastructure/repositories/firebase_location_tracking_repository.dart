import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:location/location.dart' as loc;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/location_data.dart';
import '../../domain/entities/location_session.dart';
import '../../domain/repositories/location_tracking_repository.dart';
import '../models/location_data_model.dart';
import '../models/location_session_model.dart';

/// Firebase implementation of LocationTrackingRepository
@LazySingleton(as: LocationTrackingRepository)
class FirebaseLocationTrackingRepository implements LocationTrackingRepository {
  FirebaseLocationTrackingRepository(this._firestore, this._location);

  final FirebaseFirestore _firestore;
  final loc.Location _location;

  static const String _sessionsCollection = 'location_sessions';
  static const String _locationsSubcollection = 'locations';

  // Core interface methods
  @override
  Future<LocationSession> startSession({
    required String name,
    String? description,
  }) async {
    try {
      final sessionId = _firestore.collection(_sessionsCollection).doc().id;
      final now = DateTime.now();

      final session = LocationSession(
        id: sessionId,
        name: name,
        startTime: now,
        isActive: true,
        description: description,
        locations: [],
      );

      final sessionModel = LocationSessionModel.fromEntity(session);

      await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .set(sessionModel.toJson());

      return session;
    } catch (e) {
      throw Exception('Failed to start session: $e');
    }
  }

  @override
  Future<LocationSession> stopSession(String sessionId) async {
    try {
      final sessionDoc = await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .get();

      if (!sessionDoc.exists) {
        throw Exception('Session not found');
      }

      final sessionData = sessionDoc.data()!;
      final sessionModel = LocationSessionModel.fromJson(sessionData);

      final updatedModel = sessionModel.copyWith(
        endTime: DateTime.now(),
        isActive: false,
      );

      await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .update(updatedModel.toJson());

      return updatedModel.toEntity();
    } catch (e) {
      throw Exception('Failed to stop session: $e');
    }
  }

  @override
  Future<void> addLocationToSession({
    required String sessionId,
    required LocationData location,
  }) async {
    try {
      final locationModel = LocationDataModel.fromEntity(location);

      // Save location data to subcollection
      await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection(_locationsSubcollection)
          .add(locationModel.toJson());
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
        timestamp: DateTime.now(),
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
    return _location.onLocationChanged.map((locationData) {
      return LocationData(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        timestamp: DateTime.now(),
        accuracy: locationData.accuracy,
        altitude: locationData.altitude,
        speed: locationData.speed,
        heading: locationData.heading,
      );
    });
  }

  @override
  Future<List<LocationSession>> getUserSessions() async {
    try {
      final sessionsSnapshot = await _firestore
          .collection(_sessionsCollection)
          .orderBy('startTime', descending: true)
          .get();

      final sessions = <LocationSession>[];

      for (final doc in sessionsSnapshot.docs) {
        final sessionModel = LocationSessionModel.fromJson(doc.data());

        // Get location data for this session
        final locationsSnapshot = await _firestore
            .collection(_sessionsCollection)
            .doc(doc.id)
            .collection(_locationsSubcollection)
            .orderBy('timestamp')
            .get();

        final locations = locationsSnapshot.docs
            .map(
              (locDoc) => LocationDataModel.fromJson(locDoc.data()).toEntity(),
            )
            .toList();

        final sessionWithLocations = sessionModel.copyWith(
          locations: locations
              .map((e) => LocationDataModel.fromEntity(e))
              .toList(),
        );

        sessions.add(sessionWithLocations.toEntity());
      }

      return sessions;
    } catch (e) {
      throw Exception('Failed to get user sessions: $e');
    }
  }

  @override
  Future<LocationSession?> getSessionById(String sessionId) async {
    try {
      final sessionDoc = await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .get();

      if (!sessionDoc.exists) {
        return null;
      }

      final sessionModel = LocationSessionModel.fromJson(sessionDoc.data()!);

      // Get location data for this session
      final locationsSnapshot = await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection(_locationsSubcollection)
          .orderBy('timestamp')
          .get();

      final locations = locationsSnapshot.docs
          .map((doc) => LocationDataModel.fromJson(doc.data()).toEntity())
          .toList();

      final sessionWithLocations = sessionModel.copyWith(
        locations: locations
            .map((e) => LocationDataModel.fromEntity(e))
            .toList(),
      );

      return sessionWithLocations.toEntity();
    } catch (e) {
      throw Exception('Failed to get session: $e');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      // Delete all location data in subcollection
      final locationsSnapshot = await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .collection(_locationsSubcollection)
          .get();

      final batch = _firestore.batch();

      for (final doc in locationsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the session document
      batch.delete(_firestore.collection(_sessionsCollection).doc(sessionId));

      await batch.commit();
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
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;

      await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .update(updates);

      final session = await getSessionById(sessionId);
      return session!;
    } catch (e) {
      throw Exception('Failed to update session: $e');
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<LocationPermissionStatus> checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return _mapPermissionStatus(permission);
    } catch (e) {
      return LocationPermissionStatus.unableToDetermine;
    }
  }

  @override
  Future<LocationPermissionStatus> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Also request permission from location package
      final serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        final serviceRequested = await _location.requestService();
        if (!serviceRequested) {
          return LocationPermissionStatus.denied;
        }
      }

      var locationPermission = await _location.hasPermission();
      if (locationPermission == loc.PermissionStatus.denied) {
        locationPermission = await _location.requestPermission();
      }

      return _mapPermissionStatus(permission);
    } catch (e) {
      return LocationPermissionStatus.unableToDetermine;
    }
  }

  @override
  Future<LocationSession?> getActiveSession() async {
    try {
      final sessionsSnapshot = await _firestore
          .collection(_sessionsCollection)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (sessionsSnapshot.docs.isEmpty) {
        return null;
      }

      final doc = sessionsSnapshot.docs.first;
      return await getSessionById(doc.id);
    } catch (e) {
      return null;
    }
  }

  // Compatibility methods for BLoC
  @override
  Future<bool> hasLocationPermission() async {
    final status = await checkLocationPermission();
    return status == LocationPermissionStatus.always ||
        status == LocationPermissionStatus.whileInUse;
  }

  @override
  Future<LocationSession> startLocationSession(String name) async {
    return await startSession(name: name);
  }

  @override
  Future<LocationSession> stopLocationSession(String sessionId) async {
    return await stopSession(sessionId);
  }

  @override
  Future<void> saveLocationData(String sessionId, LocationData location) async {
    await addLocationToSession(sessionId: sessionId, location: location);
  }

  @override
  Future<List<LocationSession>> getLocationSessions() async {
    return await getUserSessions();
  }

  @override
  Future<void> deleteLocationSession(String sessionId) async {
    await deleteSession(sessionId);
  }

  @override
  Future<bool> exportLocationSession(String sessionId) async {
    try {
      final session = await getSessionById(sessionId);
      if (session == null) {
        return false;
      }

      // Create GPX content
      final gpxContent = _generateGpxContent(session);

      // Save to device storage
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final file = File(
          '${directory.path}/${session.name}_${session.id}.gpx',
        );
        await file.writeAsString(gpxContent);
        return true;
      }

      return false;
    } catch (e) {
      print('Failed to export session: $e');
      return false;
    }
  }

  // Helper methods
  LocationPermissionStatus _mapPermissionStatus(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.whileInUse;
      case LocationPermission.always:
        return LocationPermissionStatus.always;
      default:
        return LocationPermissionStatus.unableToDetermine;
    }
  }

  /// Generate GPX content for export
  String _generateGpxContent(LocationSession session) {
    final buffer = StringBuffer();

    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<gpx version="1.1" creator="Flutter Architecture App">');
    buffer.writeln('  <metadata>');
    buffer.writeln('    <name>${session.name}</name>');
    buffer.writeln('    <time>${session.startTime.toIso8601String()}</time>');
    buffer.writeln('  </metadata>');
    buffer.writeln('  <trk>');
    buffer.writeln('    <name>${session.name}</name>');
    buffer.writeln('    <trkseg>');

    for (final location in session.locations) {
      buffer.writeln(
        '      <trkpt lat="${location.latitude}" lon="${location.longitude}">',
      );
      if (location.altitude != null) {
        buffer.writeln('        <ele>${location.altitude}</ele>');
      }
      buffer.writeln(
        '        <time>${location.timestamp.toIso8601String()}</time>',
      );
      buffer.writeln('      </trkpt>');
    }

    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');

    return buffer.toString();
  }
}
