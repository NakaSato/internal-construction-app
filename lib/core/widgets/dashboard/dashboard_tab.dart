import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_header.dart';
import '../../../features/authentication/application/auth_state.dart';
import '../../../features/project_management/application/project_bloc.dart';
import '../../../features/project_management/application/project_event.dart';

import 'project_list_section.dart';
import 'dashboard_search_section.dart';
import 'dashboard_constants.dart';

/// Dashboard tab content with enhanced UI
class DashboardTab extends StatelessWidget {
  final AuthAuthenticated authState;
  final VoidCallback onProfileTap;

  const DashboardTab({
    super.key,
    required this.authState,
    required this.onProfileTap,
  });

  static const double _defaultPadding = DashboardConstants.defaultPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        user: authState.user,
        title: 'Projects',
        heroContext: 'dashboard',
        showNotificationBadge: true,
        notificationCount: 3,
        showUserRole: true, // Explicitly enable user role display
        showOnlineStatus: true, // Also show online status
        onProfileTap: onProfileTap,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshDashboard(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(_defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar Section
              DashboardSearchSection(
                onSearchChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
              const SizedBox(height: DashboardConstants.mediumSpacing),

              // Projects Section
              const ProjectListSection(),
              const SizedBox(height: _defaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  /// Refresh dashboard content
  Future<void> _refreshDashboard(BuildContext context) async {
    try {
      // Refresh projects
      final projectBloc = context.read<ProjectBloc>();
      projectBloc.add(const ProjectLoadRequested());

      // Wait a moment to show refresh indicator
      await Future.delayed(DashboardConstants.refreshDelay);
    } catch (e) {
      // Show error message if refresh fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${DashboardConstants.refreshErrorPrefix}${e.toString()}',
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: DashboardConstants.snackbarDuration,
          ),
        );
      }
    }
  }
}
