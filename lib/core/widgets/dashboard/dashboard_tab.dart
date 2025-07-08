import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_header.dart';
import '../../../features/authentication/application/auth_state.dart';
import '../../../features/projects/application/project_bloc.dart';
import '../../../features/notifications/application/cubits/notification_cubit.dart';

import 'project_list_section.dart';
import 'dashboard_search_section.dart';
import 'dashboard_constants.dart';

/// Dashboard tab content with enhanced UI and notification integration
class DashboardTab extends StatefulWidget {
  final AuthAuthenticated authState;
  final VoidCallback onProfileTap;

  const DashboardTab({super.key, required this.authState, required this.onProfileTap});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  static const double _defaultPadding = DashboardConstants.defaultPadding;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, notificationState) {
        final unreadCount = notificationState.unreadCount;

        return Scaffold(
          appBar: AppHeader(
            user: widget.authState.user,
            title: 'Projects',
            heroContext: 'dashboard',
            showNotificationBadge: unreadCount > 0,
            notificationCount: unreadCount,
            showUserRole: true,
            showOnlineStatus: true,
            onProfileTap: widget.onProfileTap,
            onNotificationTap: () => context.push('/notifications'),
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
      },
    );
  }

  /// Refresh dashboard content
  Future<void> _refreshDashboard(BuildContext context) async {
    try {
      // Refresh projects
      final projectBloc = context.read<ProjectBloc>();
      projectBloc.add(const LoadProjectsRequested());

      // Refresh notifications
      final notificationCubit = context.read<NotificationCubit>();
      notificationCubit.fetchNotifications(refresh: true);

      // Wait a moment to show refresh indicator
      await Future.delayed(DashboardConstants.refreshDelay);
    } catch (e) {
      // Show error message if refresh fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${DashboardConstants.refreshErrorPrefix}${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: DashboardConstants.snackbarDuration,
          ),
        );
      }
    }
  }
}
