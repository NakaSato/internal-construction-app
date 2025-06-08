import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/location_tracking_bloc.dart';
import '../../application/location_tracking_event.dart';
import '../../domain/entities/location_session.dart';

class LocationSessionsList extends StatelessWidget {
  const LocationSessionsList({super.key, required this.sessions});

  final List<LocationSession> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tracking sessions yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start a new tracking session to see it here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<LocationTrackingBloc>().add(
          const LocationSessionsRequested(),
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return _SessionCard(session: session);
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final LocationSession session;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          session.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_formatSessionSubtitle()),
        leading: CircleAvatar(
          backgroundColor: session.isActive
              ? Colors.green
              : Theme.of(context).primaryColor,
          child: Icon(
            session.isActive ? Icons.radio_button_checked : Icons.history,
            color: Colors.white,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Session statistics
                Row(
                  children: [
                    Expanded(
                      child: _buildStatColumn(
                        'Duration',
                        _formatDuration(session.duration),
                        Icons.timer,
                        context,
                      ),
                    ),
                    Expanded(
                      child: _buildStatColumn(
                        'Distance',
                        session.formattedDistance,
                        Icons.straighten,
                        context,
                      ),
                    ),
                    Expanded(
                      child: _buildStatColumn(
                        'Points',
                        '${session.locations.length}',
                        Icons.location_on,
                        context,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _showSessionDetails(context, session);
                      },
                      icon: const Icon(Icons.info),
                      label: const Text('Details'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        context.read<LocationTrackingBloc>().add(
                          LocationSessionExported(session.id),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Export'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _showDeleteConfirmation(context, session);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  String _formatSessionSubtitle() {
    final startTime = session.startTime;
    final date = '${startTime.day}/${startTime.month}/${startTime.year}';
    final time =
        '${startTime.hour.toString().padLeft(2, '0')}:'
        '${startTime.minute.toString().padLeft(2, '0')}';

    return '$date at $time';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  void _showSessionDetails(BuildContext context, LocationSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Start Time', _formatDateTime(session.startTime)),
              if (session.endTime != null)
                _buildDetailRow('End Time', _formatDateTime(session.endTime!)),
              _buildDetailRow('Duration', _formatDuration(session.duration)),
              _buildDetailRow('Distance', session.formattedDistance),
              _buildDetailRow('Location Points', '${session.locations.length}'),
              if (session.locations.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'First Location:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(session.locations.first.coordinatesString),
                const SizedBox(height: 4),
                const Text(
                  'Last Location:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(session.locations.last.coordinatesString),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext context, LocationSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text(
          'Are you sure you want to delete "${session.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<LocationTrackingBloc>().add(
                LocationSessionDeleted(session.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
