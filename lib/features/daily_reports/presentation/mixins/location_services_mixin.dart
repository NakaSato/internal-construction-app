import 'package:flutter/material.dart';
import 'package:location/location.dart';

/// Mixin that provides location services functionality for daily reports
mixin LocationServicesMixin<T extends StatefulWidget> on State<T> {
  final Location _location = Location();
  LocationData? _locationData;

  /// Gets the current device location
  Future<LocationData?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return null;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return null;
        }
      }

      _locationData = await _location.getLocation();
      return _locationData;
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  /// Formats location data as a display string
  String formatLocationData(LocationData? locationData) {
    if (locationData?.latitude == null || locationData?.longitude == null) {
      return 'Could not determine location';
    }

    return 'Lat: ${locationData!.latitude!.toStringAsFixed(5)}, '
        'Long: ${locationData.longitude!.toStringAsFixed(5)}';
  }

  /// Gets cached location data
  LocationData? get cachedLocationData => _locationData;

  /// Shows a location error message
  void showLocationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.orange));
  }
}
