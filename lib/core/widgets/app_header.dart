import 'package:flutter/material.dart';
import '../../features/authentication/domain/entities/user.dart';

/// Custom app header with user profile on the left and actions on the right
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final User user;
  final String? title;
  final List<Widget>? actions;
  final VoidCallback? onProfileTap;
  final bool showNotificationBadge;
  final int notificationCount;
  final Color? backgroundColor;
  final bool centerTitle;

  const AppHeader({
    super.key,
    required this.user,
    this.title,
    this.actions,
    this.onProfileTap,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.backgroundColor,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      title: _buildLeftSide(context),
      actions: _buildRightSide(context),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftSide(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Profile Avatar
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? Text(
                      _getInitials(user),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // User Info
        Flexible(
          child: GestureDetector(
            onTap: onProfileTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getDisplayName(user),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (title != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.green.shade400),
                      const SizedBox(width: 4),
                      Text(
                        'Online',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRightSide(BuildContext context) {
    final rightSideActions = <Widget>[];

    // Notification icon with badge
    rightSideActions.add(
      Stack(
        children: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
          if (showNotificationBadge && notificationCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  notificationCount > 99 ? '99+' : notificationCount.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );

    // Search icon
    rightSideActions.add(
      IconButton(
        icon: Icon(
          Icons.search_outlined,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Search coming soon!')));
        },
      ),
    );

    // Menu/More options
    rightSideActions.add(
      PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onSelected: (value) {
          switch (value) {
            case 'settings':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
              break;
            case 'help':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help center coming soon!')),
              );
              break;
            case 'feedback':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback form coming soon!')),
              );
              break;
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: 'settings',
            child: Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                const Text('Settings'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'help',
            child: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                const Text('Help & Support'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'feedback',
            child: Row(
              children: [
                Icon(
                  Icons.feedback_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                const Text('Send Feedback'),
              ],
            ),
          ),
        ],
      ),
    );

    // Add any custom actions passed in
    if (actions != null) {
      rightSideActions.addAll(actions!);
    }

    return rightSideActions;
  }

  String _getInitials(User user) {
    if (user.name.isNotEmpty) {
      final nameParts = user.name.split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      }
      return user.name[0].toUpperCase();
    }
    return user.email[0].toUpperCase();
  }

  String _getDisplayName(User user) {
    if (user.name.isNotEmpty) {
      return user.name;
    }
    // Extract name from email if no name is provided
    final emailParts = user.email.split('@');
    if (emailParts.isNotEmpty) {
      return emailParts[0].replaceAll('.', ' ').replaceAll('_', ' ');
    }
    return 'User';
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Simple header variant for specific use cases
class SimpleAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final User? user;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const SimpleAppHeader({
    super.key,
    required this.title,
    this.user,
    this.actions,
    this.onBackPressed,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
