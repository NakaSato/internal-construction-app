import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_event.dart';
import '../../../authentication/application/auth_state.dart';
import '../../../../core/widgets/app_header.dart';

/// Profile screen component extracted from MainAppScreen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Scaffold(
            appBar: AppHeader(
              user: state.user,
              title: 'My Profile',
              heroContext: 'profile', // Add unique context
              showSearchIcon: false, // Hide search icon
              showNotificationIcon: false, // Hide notification icon
              onProfileTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit profile coming soon!')),
                );
              },
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildProfileMenuItems(context),
                ],
              ),
            ),
          );
        }

        // Handle loading or error states
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
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
            color: Theme.of(dialogContext).colorScheme.error,
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
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}

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
