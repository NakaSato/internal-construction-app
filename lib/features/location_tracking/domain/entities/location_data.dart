import 'dart:math' as dart;
import 'package:equatable/equatable.dart';

/// Entity representing location data
class LocationData extends Equatable {
  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    this.address,
  });

  /// Latitude coordinate
  final double latitude;

  /// Longitude coordinate
  final double longitude;

  /// Timestamp when location was recorded
  final DateTime timestamp;

  /// Location accuracy in meters
  final double? accuracy;

  /// Altitude in meters
  final double? altitude;

  /// Speed in meters per second
  final double? speed;

  /// Heading in degrees
  final double? heading;

  /// Human-readable address
  final String? address;

  /// Distance from another location in meters
  double distanceTo(LocationData other) {
    const double earthRadius = 6371000; // Earth's radius in meters

    final double lat1Rad = latitude * (dart.pi / 180);
    final double lat2Rad = other.latitude * (dart.pi / 180);
    final double deltaLatRad = (other.latitude - latitude) * (dart.pi / 180);
    final double deltaLonRad = (other.longitude - longitude) * (dart.pi / 180);

    final double a =
        dart.pow(dart.sin(deltaLatRad / 2), 2) +
        dart.cos(lat1Rad) *
            dart.cos(lat2Rad) *
            dart.pow(dart.sin(deltaLonRad / 2), 2);

    final double c = 2 * dart.asin(dart.sqrt(a));

    return earthRadius * c;
  }

  /// Format coordinates as string
  String get coordinatesString => '$latitude, $longitude';

  /// Copy with method for immutable updates
  LocationData copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    String? address,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    timestamp,
    accuracy,
    altitude,
    speed,
    heading,
    address,
  ];

  @override
  String toString() =>
      'LocationData(lat: $latitude, lng: $longitude, time: $timestamp)';
}
