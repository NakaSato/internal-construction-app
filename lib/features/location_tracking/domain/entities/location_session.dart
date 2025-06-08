import 'package:equatable/equatable.dart';

import 'location_data.dart';

/// Entity representing a location tracking session
class LocationSession extends Equatable {
  const LocationSession({
    required this.id,
    required this.name,
    required this.startTime,
    this.endTime,
    this.locations = const [],
    this.isActive = false,
    this.description,
  });

  /// Unique identifier for the session
  final String id;

  /// Session name
  final String name;

  /// Start time of the session
  final DateTime startTime;

  /// End time of the session (null if active)
  final DateTime? endTime;

  /// List of recorded locations
  final List<LocationData> locations;

  /// Whether the session is currently active
  final bool isActive;

  /// Optional description
  final String? description;

  /// Session duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Total distance traveled in meters
  double get totalDistance {
    if (locations.length < 2) return 0.0;

    double total = 0.0;
    for (int i = 1; i < locations.length; i++) {
      total += locations[i - 1].distanceTo(locations[i]);
    }
    return total;
  }

  /// Average speed in m/s
  double get averageSpeed {
    if (duration.inSeconds == 0) return 0.0;
    return totalDistance / duration.inSeconds;
  }

  /// Format duration as string
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Format distance as string
  String get formattedDistance {
    if (totalDistance < 1000) {
      return '${totalDistance.toStringAsFixed(0)}m';
    } else {
      return '${(totalDistance / 1000).toStringAsFixed(2)}km';
    }
  }

  /// Copy with method for immutable updates
  LocationSession copyWith({
    String? id,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    List<LocationData>? locations,
    bool? isActive,
    String? description,
  }) {
    return LocationSession(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      locations: locations ?? this.locations,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    startTime,
    endTime,
    locations,
    isActive,
    description,
  ];

  @override
  String toString() =>
      'LocationSession(id: $id, name: $name, active: $isActive)';
}
