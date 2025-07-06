import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Core imports
import '../navigation/app_router.dart';
import 'app_bottom_bar.dart';
import '../../common/widgets/common_widgets.dart';
import 'dashboard/dashboard_tab.dart';

// Feature imports - Authentication
import '../../features/authentication/application/auth_bloc.dart';
import '../../features/authentication/application/auth_state.dart';

// Feature imports - Calendar Management
import '../../features/calendar/presentation/screens/calendar_tab_screen.dart';
import '../../features/calendar/config/mock_calendar_management_di.dart';

// Feature imports - Work Request Approval
import '../../features/work_request_approval/presentation/screens/approvals_tab_screen.dart';

// Feature imports - Profile
import '../../features/profile/presentation/screens/profile_screen.dart';

/// Tab indices for bottom navigation
enum AppTab {
  dashboard(0),
  calendar(1),
  approvals(2),
  profile(3);

  const AppTab(this.value);
  final int value;
}

/// Main application screen that handles authentication state and bottom navigation
class MainAppScreen extends StatefulWidget {
  /// Optional initial tab index for deep linking support
  final int? initialTabIndex;

  const MainAppScreen({super.key, this.initialTabIndex});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex ?? AppTab.dashboard.value;
    _tabController = TabController(length: AppTab.values.length, vsync: this, initialIndex: _currentIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Redirect to login if user becomes unauthenticated
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return switch (state) {
            AuthLoading() => const Scaffold(body: Center(child: LoadingIndicator())),
            AuthAuthenticated() => _buildAuthenticatedApp(context, state),
            AuthUnauthenticated() => const Scaffold(body: Center(child: LoadingIndicator())),
            AuthFailure() => _buildAuthErrorState(context, state),
            _ => const Scaffold(body: Center(child: LoadingIndicator())),
          };
        },
      ),
    );
  }

  /// Builds authentication error state UI
  Widget _buildAuthErrorState(BuildContext context, AuthFailure state) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Authentication Error',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(state.message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => context.go(AppRoutes.login), child: const Text('Go to Login')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedApp(BuildContext context, AuthAuthenticated state) {
    // Initialize calendar management dependencies
    configureCalendarManagementDependencies();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home/Dashboard - uses the extracted dashboard tab
          DashboardTab(authState: state, onProfileTap: _navigateToProfileTab),
          // Calendar - Enhanced Calendar Management with API integration
          const CalendarTabScreen(),
          // Work Request Approvals
          const ApprovalsTabScreen(),
          // Profile - extracted to dedicated screen
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(currentIndex: _currentIndex, onTap: _handleTabChange),
    );
  }

  /// Navigate to profile tab
  void _navigateToProfileTab() {
    if (mounted) {
      setState(() {
        _currentIndex = AppTab.profile.value;
      });
    }
  }

  /// Handle tab change with proper validation
  void _handleTabChange(int index) {
    if (mounted && index != _currentIndex && index >= 0 && index < AppTab.values.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}
