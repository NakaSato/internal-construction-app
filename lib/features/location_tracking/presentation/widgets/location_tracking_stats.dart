import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/location_tracking_bloc.dart';
import '../../application/location_tracking_state.dart';

class LocationTrackingStats extends StatelessWidget {
  const LocationTrackingStats({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationTrackingBloc, LocationTrackingState>(
      builder: (context, state) {
        if (state is! LocationTrackingActive) {
          return const SizedBox.shrink();
        }

        final session = state.currentSession;
        final currentLocation = state.currentLocation;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Session: ${session.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Statistics grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  children: [
                    _buildStatItem(
                      icon: Icons.timer,
                      label: 'Duration',
                      value: _formatDuration(session.duration),
                      context: context,
                    ),
                    _buildStatItem(
                      icon: Icons.straighten,
                      label: 'Distance',
                      value: session.formattedDistance,
                      context: context,
                    ),
                    _buildStatItem(
                      icon: Icons.location_on,
                      label: 'Points',
                      value: '${session.locations.length}',
                      context: context,
                    ),
                    _buildStatItem(
                      icon: Icons.speed,
                      label: 'Speed',
                      value: currentLocation?.speed != null
                          ? '${(currentLocation!.speed! * 3.6).toStringAsFixed(1)} km/h'
                          : 'N/A',
                      context: context,
                    ),
                  ],
                ),

                if (currentLocation != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  Text(
                    'Current Location',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latitude: ${currentLocation.latitude.toStringAsFixed(6)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Longitude: ${currentLocation.longitude.toStringAsFixed(6)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (currentLocation.accuracy != null)
                              Text(
                                'Accuracy: ${currentLocation.accuracy!.toStringAsFixed(1)}m',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Theme.of(context).primaryColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
