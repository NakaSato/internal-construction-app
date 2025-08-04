import 'package:flutter/material.dart';
import '../../../features/authentication/domain/entities/user.dart';
import 'app_header_constants.dart';

/// User info display component for the app header
class AppHeaderUserInfo extends StatelessWidget {
  const AppHeaderUserInfo({
    super.key,
    required this.user,
    this.title,
    this.subtitle,
    this.workspaceTitle,
    this.showUserRole = false,
    this.showOnlineStatus = false,
    this.userStatus = 'online',
  });

  final User user;
  final String? title;
  final String? subtitle;
  final String? workspaceTitle;
  final bool showUserRole;
  final bool showOnlineStatus;
  final String userStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_buildUserNameRow(context), const SizedBox(height: 3), _buildSubtitleContent(context)],
    );
  }

  Widget _buildUserNameRow(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            _getDisplayName(user),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 0.1,
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (user.isEmailVerified) ...[
          const SizedBox(width: AppHeaderConstants.verifiedIconSpacing),
          Icon(
            Icons.verified_rounded,
            size: AppHeaderConstants.verifiedIconSize,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ],
    );
  }

  Widget _buildSubtitleContent(BuildContext context) {
    if (workspaceTitle != null) {
      return _buildWorkspaceTitle(context);
    } else if (title != null) {
      return _buildRegularTitle(context);
    } else if (subtitle != null) {
      return _buildSubtitle(context);
    } else {
      // Show role name with online status
      return _buildRoleAndStatus(context);
    }
  }

  Widget _buildWorkspaceTitle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        workspaceTitle!,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          letterSpacing: 0.3,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRegularTitle(BuildContext context) {
    return Text(
      title!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      subtitle!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRoleAndStatus(BuildContext context) {
    // If neither role nor status should be shown, return empty
    if (!showUserRole && !showOnlineStatus) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // Role badge (if enabled)
        if (showUserRole) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _getRoleColor(user.roleName).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getRoleColor(user.roleName).withValues(alpha: _isElevatedRole(user.roleName) ? 0.5 : 0.3),
                width: _isElevatedRole(user.roleName) ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getRoleColor(user.roleName).withValues(alpha: _isElevatedRole(user.roleName) ? 0.15 : 0.1),
                  blurRadius: _isElevatedRole(user.roleName) ? 3 : 2,
                  offset: Offset(0, _isElevatedRole(user.roleName) ? 1.5 : 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(color: _getRoleColor(user.roleName), shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatRoleName(user.roleName),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getRoleColor(user.roleName),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          if (showOnlineStatus) const SizedBox(width: 8),
        ],
        // Online indicator (if enabled)
        if (showOnlineStatus) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: AppHeaderConstants.onlineIndicatorSize,
            height: AppHeaderConstants.onlineIndicatorSize,
            decoration: BoxDecoration(
              color: _getStatusColor(userStatus),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: _getStatusColor(userStatus).withValues(alpha: 0.3), blurRadius: 3, spreadRadius: 1),
              ],
            ),
          ),
          const SizedBox(width: AppHeaderConstants.onlineIndicatorSpacing),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _getStatusText(userStatus),
              key: ValueKey(userStatus),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getStatusColor(userStatus).withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Helper methods for display name, role, and status
  String _getDisplayName(User user) {
    if (user.name.isNotEmpty) {
      return user.name;
    }

    // Extract name from email if no name is provided
    final emailParts = user.email.split('@');
    if (emailParts.isNotEmpty && emailParts[0].isNotEmpty) {
      return emailParts[0].replaceAll(RegExp(r'[._]'), ' ').split(' ').map(_capitalizeWord).join(' ');
    }
    return 'User';
  }

  String _capitalizeWord(String word) {
    if (word.isEmpty) return word;
    return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
  }

  String _formatRoleName(String roleName) {
    const roleMapping = {
      // Admin roles
      'admin': 'Admin',
      'administrator': 'Admin',

      // Project Manager roles
      'manager': 'Project Manager',
      'project_manager': 'Project Manager',
      'site_supervisor': 'Project Manager',
      'supervisor': 'Project Manager',

      // User roles (operational)
      'user': 'User',
      'member': 'User',
      'technician': 'User',
      'tech': 'User',
      'field_technician': 'User',
      'engineer': 'User',
      'developer': 'User',
      'dev': 'User',
      'contractor': 'User',
      'analyst': 'User',
      'qa': 'User',
      'quality_assurance': 'User',
      'finance': 'User',
      'accounting': 'User',
      'hr': 'User',
      'human_resources': 'User',
      'sales': 'User',
      'support': 'User',

      // Viewer roles (read-only)
      'viewer': 'Viewer',
      'guest': 'Viewer',
      'client': 'Viewer',
      'customer': 'Viewer',
    };

    return roleMapping[roleName.toLowerCase()] ?? 'User';
  }

  Color _getRoleColor(String roleName) {
    // Using the new solar color scheme
    final roleColors = {
      // Admin - Highest authority (Solar Orange for attention)
      'admin': const Color(0xFFEA580C), // solarOrange
      'administrator': const Color(0xFFEA580C), // solarOrange
      // Project Manager - Management roles (Solar Gold)
      'manager': const Color(0xFFF59E0B), // solarGold
      'project_manager': const Color(0xFFF59E0B), // solarGold
      'site_supervisor': const Color(0xFFF59E0B), // solarGold
      'supervisor': const Color(0xFFF59E0B), // solarGold
      // User - Operational roles (Solar Blue - primary)
      'user': const Color(0xFF2563EB), // solarBlue
      'member': const Color(0xFF2563EB), // solarBlue
      'technician': const Color(0xFF2563EB), // solarBlue
      'tech': const Color(0xFF2563EB), // solarBlue
      'field_technician': const Color(0xFF2563EB), // solarBlue
      'engineer': const Color(0xFF2563EB), // solarBlue
      'developer': const Color(0xFF2563EB), // solarBlue
      'dev': const Color(0xFF2563EB), // solarBlue
      'contractor': const Color(0xFF2563EB), // solarBlue
      'analyst': const Color(0xFF2563EB), // solarBlue
      'qa': const Color(0xFF2563EB), // solarBlue
      'quality_assurance': const Color(0xFF2563EB), // solarBlue
      'finance': const Color(0xFF059669), // solarGreen
      'accounting': const Color(0xFF059669), // solarGreen
      'hr': const Color(0xFF059669), // solarGreen
      'human_resources': const Color(0xFF059669), // solarGreen
      'sales': const Color(0xFF8B5CF6), // energyOptimal
      'support': const Color(0xFF8B5CF6), // energyOptimal
      // Viewer - Read-only roles (Gray)
      'viewer': const Color(0xFF6B7280), // statusDraft
      'guest': const Color(0xFF6B7280), // statusDraft
      'client': const Color(0xFF6B7280), // statusDraft
      'customer': const Color(0xFF6B7280), // statusDraft
    };

    return roleColors[roleName.toLowerCase()] ?? const Color(0xFF2563EB);
  }

  Color _getStatusColor(String status) {
    // Using the new solar color scheme
    final statusColors = {
      'online': const Color(0xFF10B981), // energyHigh color
      'away': const Color(0xFFF59E0B), // energyMedium color
      'busy': const Color(0xFFEF4444), // energyLow color
      'dnd': const Color(0xFFEF4444), // energyLow color
      'do not disturb': const Color(0xFFEF4444), // energyLow color
      'offline': const Color(0xFF6B7280), // statusDraft color
    };

    return statusColors[status.toLowerCase()] ?? const Color(0xFF10B981);
  }

  String _getStatusText(String status) {
    const statusTexts = {
      'online': 'Online',
      'away': 'Away',
      'busy': 'Busy',
      'dnd': 'Busy',
      'do not disturb': 'Busy',
      'offline': 'Offline',
    };

    return statusTexts[status.toLowerCase()] ?? 'Online';
  }

  int _getRolePriority(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
      case 'administrator':
        return 10; // Admin
      case 'manager':
      case 'project_manager':
      case 'site_supervisor':
      case 'supervisor':
        return 8; // Project Manager
      case 'user':
      case 'engineer':
        return 2; // User
      case 'viewer':
      case 'guest':
      case 'client':
      case 'customer':
        return 0; // Viewer
      default:
        return 2; // Default to User level
    }
  }

  bool _isElevatedRole(String roleName) {
    return _getRolePriority(roleName) >= 8;
  }
}
