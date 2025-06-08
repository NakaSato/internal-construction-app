import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../navigation/app_router.dart';
import '../../features/authentication/application/auth_bloc.dart';
import '../../features/authentication/application/auth_state.dart';
import '../../features/authentication/application/auth_event.dart';
import '../../features/location_tracking/presentation/screens/location_tracking_screen.dart';
import '../../features/work_calendar/presentation/screens/calendar_screen.dart';
import '../../utils/api_config_verifier.dart';
import 'app_bottom_bar.dart';
import 'common_widgets.dart';
import 'app_header.dart';

/// Main application screen that handles authentication state and bottom navigation
class MainAppScreen extends StatefulWidget {
  /// Optional initial tab index for deep linking support
  final int? initialTabIndex;

  const MainAppScreen({super.key, this.initialTabIndex});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex ?? 0;
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
          if (state is AuthLoading) {
            return const Scaffold(body: LoadingIndicator());
          }

          if (state is AuthAuthenticated) {
            return _buildAuthenticatedApp(context, state);
          }

          // For unauthenticated state, the listener will handle navigation
          return const Scaffold(body: LoadingIndicator());
        },
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
          // Location Tracking
          const LocationTrackingScreen(),
          // Profile - simplified version for now
          _buildProfileTab(context, state),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (mounted) {
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
        showNotificationBadge: true,
        notificationCount: 3,
        onProfileTap: () {
          // Navigate to profile tab
          setState(() {
            _currentIndex = 3;
          });
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(context, state.user),
            const SizedBox(height: 24),
            _buildFeatureGrid(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
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

  Widget _buildWelcomeSection(BuildContext context, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (user.name.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(user.name, style: Theme.of(context).textTheme.titleMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.image,
        title: 'Image Upload',
        subtitle: 'Manage your images',
        onTap: () =>
            setState(() => _currentIndex = 3), // Navigate to profile for now
      ),
      _FeatureItem(
        icon: Icons.location_on,
        title: 'Location Tracking',
        subtitle: 'Track your location',
        onTap: () => setState(() => _currentIndex = 2),
      ),
      _FeatureItem(
        icon: Icons.calendar_today,
        title: 'Work Calendar',
        subtitle: 'Manage your schedule',
        onTap: () => setState(() => _currentIndex = 1),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3, // Increased from 1.1 to 1.3 for more height
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(context, feature);
      },
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureItem feature) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: feature.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Reduced from 16.0 to 12.0
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                feature.icon,
                size: 40, // Reduced from 48 to 40
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8), // Reduced from 12 to 8
              Text(
                feature.title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall, // Changed from titleMedium to titleSmall
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // Reduced from 4 to 2
              Text(
                feature.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Upload Image',
                  onTap: () {
                    // Navigate to image upload functionality
                    context.push(AppRoutes.imageUpload);
                  },
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Add Event',
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.location_on,
                  label: 'Check In',
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user.name.isNotEmpty
                    ? user.name[0].toUpperCase()
                    : user.email[0].toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
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
                    style: Theme.of(context).textTheme.titleLarge,
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit profile coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItems(BuildContext context) {
    final menuItems = [
      _ProfileMenuItem(
        icon: Icons.person,
        title: 'Edit Profile',
        subtitle: 'Update your personal information',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit profile coming soon!')),
          );
        },
      ),
      _ProfileMenuItem(
        icon: Icons.notifications,
        title: 'Notifications',
        subtitle: 'Manage notification preferences',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification settings coming soon!')),
          );
        },
      ),
      _ProfileMenuItem(
        icon: Icons.security,
        title: 'Privacy & Security',
        subtitle: 'Manage your account security',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Security settings coming soon!')),
          );
        },
      ),
      _ProfileMenuItem(
        icon: Icons.help,
        title: 'Help & Support',
        subtitle: 'Get help and contact support',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Help center coming soon!')),
          );
        },
      ),
      _ProfileMenuItem(
        icon: Icons.logout,
        title: 'Sign Out',
        subtitle: 'Sign out of your account',
        onTap: () => _showLogoutDialog(context),
        isDestructive: true,
      ),
    ];

    return Column(
      children: menuItems
          .map((item) => _buildProfileMenuItem(context, item))
          .toList(),
    );
  }

  Widget _buildProfileMenuItem(BuildContext context, _ProfileMenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: item.isDestructive
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          item.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: item.isDestructive
                ? Theme.of(context).colorScheme.error
                : null,
          ),
        ),
        subtitle: Text(item.subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: item.onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  /// Debug section showing API configuration (only in development)
  Widget _buildApiConfigDebugSection(BuildContext context) {
    final config = ApiConfigVerifier.getConfigSummary();

    return Card(
      color: Colors.grey[100],
      child: ExpansionTile(
        leading: Icon(
          config['isCorrectHost'] ? Icons.check_circle : Icons.warning,
          color: config['isCorrectHost'] ? Colors.green : Colors.orange,
        ),
        title: const Text(
          'API Configuration',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Host: ${config['apiBaseUrl']}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConfigRow('Environment', config['environment']),
                _buildConfigRow('Debug Mode', config['debugMode'].toString()),
                _buildConfigRow('API Base URL', config['apiBaseUrl']),
                _buildConfigRow(
                  'Env File Loaded',
                  config['envFileLoaded'].toString(),
                ),
                _buildConfigRow(
                  'Correct Host',
                  config['isCorrectHost'].toString(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

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
