import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../navigation/app_router.dart';
import '../../features/authentication/application/auth_bloc.dart';
import '../../features/authentication/application/auth_state.dart';
import '../../features/authentication/application/auth_event.dart';
import '../../features/work_calendar/presentation/screens/calendar_screen.dart';
import '../../features/project_management/application/project_bloc.dart';
import '../../features/project_management/application/project_state.dart';
import '../../features/project_management/application/project_event.dart';
import '../../features/project_management/domain/entities/project.dart';
import '../utils/api_config_verifier.dart';
import 'app_bottom_bar.dart';
import 'common_widgets.dart';
import 'app_header.dart';

/// Tab indices for bottom navigation
enum AppTab {
  dashboard(0),
  calendar(1),
  profile(2);

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
  static const double _profileAvatarRadius = 32.0;

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
            AuthFailure() => _buildErrorState(context, state),
            _ => const Scaffold(body: Center(child: LoadingIndicator())),
          };
        },
      ),
    );
  }

  /// Builds error state UI
  Widget _buildErrorState(BuildContext context, AuthFailure state) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(_defaultPadding),
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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home/Dashboard - uses the existing authenticated home
          _buildDashboardTab(context, state),
          // Calendar
          const CalendarScreen(),
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
        heroContext: 'dashboard', // Add unique context
        showNotificationBadge: true,
        notificationCount: 3,
        onProfileTap: () {
          // Navigate to profile tab
          setState(() {
            _currentIndex = AppTab.profile.value;
          });
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(_defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProjectListCard(context),
            const SizedBox(height: 24),
            _buildApiConfigDebugSection(context),
          ],
        ),
      ),
    );
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
            onPressed: () {
              // Navigate to settings or profile edit
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
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

  /// Project list card with recent projects
  Widget _buildProjectListCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(_defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Projects',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full project list
                    context.push('/projects');
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (context) =>
                  GetIt.instance<ProjectBloc>()
                    ..add(const ProjectLoadRequested()),
              child: BlocBuilder<ProjectBloc, ProjectState>(
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProjectLoaded) {
                    final recentProjects = state.projects.take(3).toList();

                    if (recentProjects.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 48,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No projects yet',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to create project
                                context.push('/projects/create');
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Create Project'),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: recentProjects.map((project) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildProjectSummaryCard(context, project),
                        );
                      }).toList(),
                    );
                  } else if (state is ProjectError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load projects',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              context.read<ProjectBloc>().add(
                                const ProjectRefreshRequested(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a compact project summary card for the dashboard
  Widget _buildProjectSummaryCard(BuildContext context, Project project) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          // Navigate to project detail
          context.push('/projects/${project.id}');
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(context, project.projectStatus),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Project info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Progress indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${project.completionPercentage}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: project.completionPercentage / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gets color for project status
  Color _getStatusColor(BuildContext context, ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Theme.of(context).colorScheme.outline;
      case ProjectStatus.inProgress:
        return Theme.of(context).colorScheme.primary;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.onHold:
        return Colors.orange;
      case ProjectStatus.cancelled:
        return Theme.of(context).colorScheme.error;
    }
  }

  /// Profile header with user avatar and information
  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    final initials = _getUserInitials(user);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(_defaultPadding),
        child: Row(
          children: [
            CircleAvatar(
              radius: _profileAvatarRadius,
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
                    user.name.isNotEmpty ? user.name : 'User',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
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

  /// Gets user initials for avatar
  String _getUserInitials(dynamic user) {
    if (user.name.isNotEmpty) {
      final nameParts = user.name.trim().split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
      }
      return user.name[0].toUpperCase();
    }
    return user.email[0].toUpperCase();
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

  /// Debug section showing API configuration (only visible in development)
  Widget _buildApiConfigDebugSection(BuildContext context) {
    final config = ApiConfigVerifier.getConfigSummary();
    final isConfigValid = config['isCorrectHost'] ?? false;

    return Card(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      elevation: 1,
      child: ExpansionTile(
        leading: Icon(
          isConfigValid ? Icons.check_circle : Icons.warning,
          color: isConfigValid ? Colors.green : Colors.orange,
        ),
        title: Text(
          'API Configuration',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Host: ${config['apiBaseUrl']}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(_defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConfigRow(
                  'Environment',
                  config['environment']?.toString() ?? 'N/A',
                ),
                _buildConfigRow(
                  'Debug Mode',
                  config['debugMode']?.toString() ?? 'N/A',
                ),
                _buildConfigRow(
                  'API Base URL',
                  config['apiBaseUrl']?.toString() ?? 'N/A',
                ),
                _buildConfigRow(
                  'Env File Loaded',
                  config['envFileLoaded']?.toString() ?? 'N/A',
                ),
                _buildConfigRow(
                  'Correct Host',
                  config['isCorrectHost']?.toString() ?? 'N/A',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds configuration row for debug section
  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
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
