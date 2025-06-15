import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

// Core imports
import '../navigation/app_router.dart';
import 'app_bottom_bar.dart';
import 'common_widgets.dart';
import 'app_header.dart';

// Feature imports - Authentication
import '../../features/authentication/application/auth_bloc.dart';
import '../../features/authentication/application/auth_state.dart';
import '../../features/authentication/application/auth_event.dart';

// Feature imports - Calendar Management
import '../../features/calendar_management/presentation/screens/calendar_management_screen.dart';
import '../../features/calendar_management/application/calendar_management_bloc.dart';
import '../../features/calendar_management/application/calendar_management_event.dart'
    as cm_events;
import '../../features/calendar_management/config/mock_calendar_management_di.dart';

// Feature imports - Work Request Approval
import '../../features/work_request_approval/presentation/screens/my_work_requests_screen.dart';
import '../../features/work_request_approval/application/cubits/my_work_requests_cubit.dart';
import '../../features/work_request_approval/domain/usecases/get_my_work_requests_usecase.dart';
import '../../features/work_request_approval/infrastructure/repositories/mock_work_request_approval_repository.dart';

// Feature imports - Project Management
import '../../features/project_management/application/project_bloc.dart';
import '../../features/project_management/application/project_state.dart';
import '../../features/project_management/application/project_event.dart';
import '../../features/project_management/presentation/widgets/project_card.dart';

// Feature imports - Settings
import '../../features/settings/presentation/screens/settings_screen.dart';

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

class _MainAppScreenState extends State<MainAppScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late TabController _tabController;

  // Constants for better maintainability
  static const double _defaultPadding = 16.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex ?? AppTab.dashboard.value;
    _tabController = TabController(
      length: AppTab.values.length,
      vsync: this,
      initialIndex: _currentIndex,
    );
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
            AuthLoading() => const Scaffold(
              body: Center(child: LoadingIndicator()),
            ),
            AuthAuthenticated() => _buildAuthenticatedApp(context, state),
            AuthUnauthenticated() => const Scaffold(
              body: Center(child: LoadingIndicator()),
            ),
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
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Authentication Error',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Go to Login'),
              ),
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
          // Home/Dashboard - uses the existing authenticated home
          _buildDashboardTab(context, state),
          // Calendar - Enhanced Calendar Management with API integration
          MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    GetIt.instance<CalendarManagementBloc>()
                      ..add(const cm_events.CalendarEventsRequested()),
              ),
            ],
            child: const CalendarManagementScreen(),
          ),
          // Work Request Approvals
          BlocProvider(
            create: (context) => MyWorkRequestsCubit(
              GetMyWorkRequestsUseCase(MockWorkRequestApprovalRepository()),
            ),
            child: const MyWorkRequestsScreen(),
          ),
          // Profile - simplified version for now
          _buildProfileTab(context, state),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (mounted && index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }

  /// Dashboard tab content (replaces the original HomeScreen content)
  Widget _buildDashboardTab(BuildContext context, AuthAuthenticated state) {
    return Scaffold(
      appBar: AppHeader(
        user: state.user,
        title: 'Dashboard',
        heroContext: 'dashboard',
        showNotificationBadge: true,
        notificationCount: 3,
        onProfileTap: () => _navigateToProfileTab(),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshDashboard(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(_defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProjectListCard(context),
              // Add space for future dashboard sections
              const SizedBox(height: _defaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to profile tab
  void _navigateToProfileTab() {
    setState(() {
      _currentIndex = AppTab.profile.value;
    });
  }

  /// Refresh dashboard content
  Future<void> _refreshDashboard(BuildContext context) async {
    try {
      // Refresh projects
      final projectBloc = context.read<ProjectBloc>();
      projectBloc.add(const ProjectLoadRequested());

      // Wait a moment to show refresh indicator
      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      // Show error message if refresh fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing dashboard: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Profile tab content
  Widget _buildProfileTab(BuildContext context, AuthAuthenticated state) {
    return Scaffold(
      appBar: AppHeader(
        user: state.user,
        title: 'My Profile',
        heroContext: 'profile', // Add unique context
        onProfileTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit profile coming soon!')),
          );
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(context, state.user),
            const SizedBox(height: 24),
            _buildProfileMenuItems(context),
          ],
        ),
      ),
    );
  }

  /// Project list card with all projects in compact format
  Widget _buildProjectListCard(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.fromLTRB(
              _defaultPadding,
              _defaultPadding,
              _defaultPadding,
              8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Projects',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                BlocBuilder<ProjectBloc, ProjectState>(
                  builder: (context, state) {
                    if (state is ProjectLoaded) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${state.projects.length}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(_defaultPadding),
            child: BlocProvider(
              create: (context) =>
                  GetIt.instance<ProjectBloc>()
                    ..add(const ProjectLoadRequested()),
              child: BlocBuilder<ProjectBloc, ProjectState>(
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return _buildLoadingState(context);
                  } else if (state is ProjectLoaded) {
                    final allProjects = state.projects;

                    if (allProjects.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return _buildProjectList(context, allProjects);
                  } else if (state is ProjectError) {
                    return _buildErrorState(context, state.message);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading projects...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No projects yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first project to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                // Navigate to create project
                context.push('/projects/create');
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Project'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 32,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load projects',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                context.read<ProjectBloc>().add(
                  const ProjectRefreshRequested(),
                );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectList(BuildContext context, List<dynamic> allProjects) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProjectBloc>().add(const ProjectRefreshRequested());
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: allProjects.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final project = allProjects[index];
              return AnimatedContainer(
                duration: Duration(milliseconds: 200 + (index * 50)),
                curve: Curves.easeOutCubic,
                child: ProjectCard(
                  project: project,
                  isCompact: true,
                  onTap: () {
                    context.push('/projects/${project.id}');
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Profile header with user avatar and information
  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    final initials = _getUserInitials(user);
    final userName = _getUserDisplayName(user);
    final userEmail = _getUserEmail(user);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32.0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                initials,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showComingSoonSnackBar(context, 'Edit profile'),
              tooltip: 'Edit profile',
            ),
          ],
        ),
      ),
    );
  }

  /// Gets user initials for avatar with proper null safety
  String _getUserInitials(dynamic user) {
    try {
      final name = _getUserDisplayName(user);
      if (name != 'User') {
        final nameParts = name.trim().split(' ');
        if (nameParts.length >= 2) {
          return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
        }
        return name[0].toUpperCase();
      }

      // Fall back to email if no name
      final email = _getUserEmail(user);
      return email[0].toUpperCase();
    } catch (e) {
      // Return placeholder if anything fails
      return 'U';
    }
  }

  /// Gets user display name with proper null safety
  String _getUserDisplayName(dynamic user) {
    try {
      final name = user?.name as String?;
      return (name != null && name.isNotEmpty) ? name : 'User';
    } catch (e) {
      return 'User';
    }
  }

  /// Gets user email with proper null safety
  String _getUserEmail(dynamic user) {
    try {
      final email = user?.email as String?;
      return (email != null && email.isNotEmpty) ? email : 'No email';
    } catch (e) {
      return 'No email';
    }
  }

  /// Shows a coming soon snackbar
  void _showComingSoonSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Profile menu items with organized categories
  Widget _buildProfileMenuItems(BuildContext context) {
    final menuItems = _getProfileMenuItems(context);

    return Column(
      children: menuItems
          .map((item) => _buildProfileMenuItem(context, item))
          .toList(),
    );
  }

  /// Gets organized profile menu items
  List<_ProfileMenuItem> _getProfileMenuItems(BuildContext context) {
    return [
      _ProfileMenuItem(
        icon: Icons.person,
        title: 'Edit Profile',
        subtitle: 'Update your personal information',
        onTap: () => _showComingSoonSnackBar(context, 'Edit profile'),
      ),
      _ProfileMenuItem(
        icon: Icons.notifications,
        title: 'Notifications',
        subtitle: 'Manage notification preferences',
        onTap: () => _showComingSoonSnackBar(context, 'Notification settings'),
      ),
      _ProfileMenuItem(
        icon: Icons.security,
        title: 'Privacy & Security',
        subtitle: 'Manage your account security',
        onTap: () => _showComingSoonSnackBar(context, 'Security settings'),
      ),
      _ProfileMenuItem(
        icon: Icons.palette,
        title: 'Appearance',
        subtitle: 'Customize app appearance',
        onTap: () => _showComingSoonSnackBar(context, 'Appearance settings'),
      ),
      _ProfileMenuItem(
        icon: Icons.help,
        title: 'Help & Support',
        subtitle: 'Get help and contact support',
        onTap: () => _showComingSoonSnackBar(context, 'Help center'),
      ),
      _ProfileMenuItem(
        icon: Icons.logout,
        title: 'Sign Out',
        subtitle: 'Sign out of your account',
        onTap: () => _showLogoutDialog(context),
        isDestructive: true,
      ),
    ];
  }

  /// Builds individual profile menu item with proper styling
  Widget _buildProfileMenuItem(BuildContext context, _ProfileMenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: item.isDestructive
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            size: 20,
            color: item.isDestructive
                ? Theme.of(context).colorScheme.onErrorContainer
                : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          item.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: item.isDestructive
                ? Theme.of(context).colorScheme.error
                : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          item.subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: item.onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Shows confirmation dialog for sign out
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: Icon(
            Icons.logout,
            size: 32,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('Sign Out'),
          content: const Text(
            'Are you sure you want to sign out? You will need to log in again to access your account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  /// Navigate to the settings screen
  void _navigateToSettings(BuildContext context) {
    try {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
    } catch (e) {
      // Handle any navigation errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open settings: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// MARK: - Data Classes

/// Profile menu item data class
class _ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });
}
