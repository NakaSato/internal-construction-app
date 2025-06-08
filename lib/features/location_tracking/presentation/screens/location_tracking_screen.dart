import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/location_tracking_bloc.dart';
import '../../application/location_tracking_event.dart';
import '../../application/location_tracking_state.dart';
import '../widgets/location_sessions_list.dart';
import '../widgets/location_tracking_controls.dart';
import '../widgets/location_tracking_stats.dart';

class LocationTrackingScreen extends StatefulWidget {
  const LocationTrackingScreen({super.key});

  @override
  State<LocationTrackingScreen> createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Request initial data
    context.read<LocationTrackingBloc>().add(const LocationSessionsRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracking'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.play_arrow), text: 'Tracking'),
            Tab(icon: Icon(Icons.history), text: 'Sessions'),
          ],
        ),
        actions: [
          BlocBuilder<LocationTrackingBloc, LocationTrackingState>(
            builder: (context, state) {
              if (state is LocationTrackingActive) {
                return IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () {
                    context.read<LocationTrackingBloc>().add(
                      const LocationTrackingStopped(),
                    );
                  },
                  tooltip: 'Stop Tracking',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocListener<LocationTrackingBloc, LocationTrackingState>(
        listener: (context, state) {
          if (state is LocationTrackingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is LocationSessionExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session exported successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [_buildTrackingTab(), _buildSessionsTab()],
        ),
      ),
    );
  }

  Widget _buildTrackingTab() {
    return BlocBuilder<LocationTrackingBloc, LocationTrackingState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Permission status and controls
              const LocationTrackingControls(),

              const SizedBox(height: 24),

              // Current session stats
              if (state is LocationTrackingActive) ...[
                const LocationTrackingStats(),
                const SizedBox(height: 24),
              ],

              // Status card
              _buildStatusCard(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionsTab() {
    return BlocBuilder<LocationTrackingBloc, LocationTrackingState>(
      builder: (context, state) {
        if (state is LocationTrackingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LocationSessionsLoaded) {
          return LocationSessionsList(sessions: state.sessions);
        }

        return const Center(child: Text('No sessions found'));
      },
    );
  }

  Widget _buildStatusCard(LocationTrackingState state) {
    IconData icon;
    String title;
    String subtitle;
    Color color;

    switch (state.runtimeType) {
      case LocationTrackingActive:
        icon = Icons.radio_button_checked;
        title = 'Tracking Active';
        subtitle = 'Recording location data...';
        color = Colors.green;
        break;
      case LocationTrackingInactive:
        icon = Icons.radio_button_unchecked;
        title = 'Tracking Stopped';
        subtitle = 'Ready to start new session';
        color = Colors.orange;
        break;
      case LocationPermissionGranted:
        icon = Icons.check_circle;
        title = 'Permission Granted';
        subtitle = 'Ready to start tracking';
        color = Colors.blue;
        break;
      default:
        icon = Icons.location_disabled;
        title = 'Location Tracking';
        subtitle = 'Request permission to start';
        color = Colors.grey;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
