import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/location_tracking_bloc.dart';
import '../../application/location_tracking_event.dart';
import '../../application/location_tracking_state.dart';

class LocationTrackingControls extends StatefulWidget {
  const LocationTrackingControls({super.key});

  @override
  State<LocationTrackingControls> createState() =>
      _LocationTrackingControlsState();
}

class _LocationTrackingControlsState extends State<LocationTrackingControls> {
  final _sessionNameController = TextEditingController();

  @override
  void dispose() {
    _sessionNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationTrackingBloc, LocationTrackingState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Location Controls',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                if (state is! LocationTrackingActive) ...[
                  // Session name input
                  TextField(
                    controller: _sessionNameController,
                    decoration: const InputDecoration(
                      labelText: 'Session Name',
                      hintText: 'Enter a name for this tracking session',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Permission button
                if (state is LocationTrackingInitial ||
                    state is LocationTrackingError) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<LocationTrackingBloc>().add(
                        const LocationPermissionRequested(),
                      );
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text('Request Location Permission'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],

                // Start tracking button
                if (state is LocationPermissionGranted ||
                    state is LocationTrackingInactive) ...[
                  ElevatedButton.icon(
                    onPressed: _sessionNameController.text.trim().isEmpty
                        ? null
                        : () {
                            final sessionName = _sessionNameController.text
                                .trim();
                            context.read<LocationTrackingBloc>().add(
                              LocationTrackingStarted(sessionName),
                            );
                            _sessionNameController.clear();
                          },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Tracking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],

                // Stop tracking button
                if (state is LocationTrackingActive) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<LocationTrackingBloc>().add(
                        const LocationTrackingStopped(),
                      );
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Tracking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],

                // Loading indicator
                if (state is LocationTrackingLoading) ...[
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
