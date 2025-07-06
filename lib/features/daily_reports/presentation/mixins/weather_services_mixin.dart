import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

import '../../application/cubits/daily_reports_cubit.dart';
import '../../application/states/daily_reports_state.dart';

/// Mixin that provides weather functionality for daily reports
mixin WeatherServicesMixin<T extends StatefulWidget> on State<T> {
  /// Fetches current weather based on location data
  Future<void> fetchCurrentWeather({
    required LocationData? locationData,
    required TextEditingController weatherController,
  }) async {
    if (locationData == null) {
      _showWeatherError('Unable to get your location for weather data');
      return;
    }

    _showWeatherLoading();

    try {
      // Use the cubit to fetch weather
      await context.read<DailyReportsCubit>().fetchCurrentWeather(
        locationData.latitude ?? 0,
        locationData.longitude ?? 0,
      );

      // Listen to the state changes
      final state = context.read<DailyReportsCubit>().state;
      if (state is WeatherDataState && state.weatherData != null) {
        weatherController.text = state.weatherData!;
        _showWeatherSuccess();
      } else {
        _showWeatherError('Could not fetch weather data');
      }
    } catch (e) {
      _showWeatherError('Error fetching weather: $e');
    }
  }

  /// Shows weather loading message
  void _showWeatherLoading() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fetching current weather...')));
    }
  }

  /// Shows weather success message
  void _showWeatherSuccess() {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Weather information updated'), backgroundColor: Colors.green));
    }
  }

  /// Shows weather error message
  void _showWeatherError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  /// Creates a weather field widget with refresh button
  Widget buildWeatherField({required TextEditingController controller, required VoidCallback onRefresh}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Weather Conditions',
        hintText: 'Describe weather at the worksite',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        suffixIcon: IconButton(icon: const Icon(Icons.wb_sunny), onPressed: onRefresh, tooltip: 'Get Current Weather'),
      ),
    );
  }
}
