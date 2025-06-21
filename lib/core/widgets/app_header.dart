import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../features/authentication/domain/entities/user.dart';

// MARK: - Constants
class _AppHeaderConstants {
  // Size constants
  static const double toolbarHeightOffset = 8.0;
  static const double avatarRadius = 22.0;
  static const double iconSize = 22.0;
  static const double iconPadding = 12.0;
  static const double iconBorderRadius = 14.0;
  static const double verifiedIconSize = 16.0;
  static const double onlineIndicatorSize = 6.0;

  // Animation constants
  static const Duration animationDuration = Duration(milliseconds: 800);
  static const Duration badgeAnimationDuration = Duration(milliseconds: 600);
  static const Duration scaleAnimationDuration = Duration(milliseconds: 400);
  static const Duration snackBarDuration = Duration(seconds: 2);

  // Spacing constants
  static const double searchIconRightSpacing = 8.0;
  static const double notificationIconRightSpacing = 12.0;
  static const double customActionLeftSpacing = 8.0;
  static const double customActionRightSpacing = 4.0;
  static const double userInfoSpacing = 12.0;
  static const double verifiedIconSpacing = 4.0;
  static const double onlineIndicatorSpacing = 6.0;

  // Numeric constants
  static const int maxNotificationCount = 99;
  static const double scaleAnimationStart = 0.8;
  static const double scaleAnimationRange = 0.2;

  // Private constructor to prevent instantiation
  const _AppHeaderConstants._();
}

/// Custom app header with enhanced UI, animations, and modern Material 3 design
class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  final User user;
  final String? title;
  final List<Widget>? actions;
  final VoidCallback? onProfileTap;
  final bool showNotificationBadge;
  final int notificationCount;
  final Color? backgroundColor;
  final bool centerTitle;
  final bool showSearchIcon;
  final bool showNotificationIcon;
  final VoidCallback? onSearchTap;
  final String? subtitle;
  final bool showGradient;
  final bool showOnlineStatus;
  final bool showUserRole; // Show user's role badge in header
  final String userStatus; // User status: 'online', 'away', 'busy', 'offline'
  final String? workspaceTitle;
  final VoidCallback? onNotificationTap;
  final String? heroContext; // Add unique context identifier

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
    this.showSearchIcon = true,
    this.showNotificationIcon = true,
    this.onSearchTap,
    this.subtitle,
    this.showGradient = true,
    this.showOnlineStatus = true,
    this.showUserRole = true,
    this.userStatus = 'online',
    this.workspaceTitle,
    this.onNotificationTap,
    this.heroContext, // Add unique context identifier
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(
    kToolbarHeight + _AppHeaderConstants.toolbarHeightOffset,
  );
}

class _AppHeaderState extends State<AppHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // MARK: - Animation Setup

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: _AppHeaderConstants.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: _buildHeaderDecoration(context),
          child: AppBar(
            backgroundColor: _getAppBarBackgroundColor(context),
            elevation: 0,
            centerTitle: widget.centerTitle,
            automaticallyImplyLeading: false,
            systemOverlayStyle: _buildSystemOverlayStyle(context),
            title: _buildLeftSide(context),
            actions: _buildRightSide(context),
            toolbarHeight:
                kToolbarHeight + _AppHeaderConstants.toolbarHeightOffset,
          ),
        ),
      ),
    );
  }

  // MARK: - UI Builders

  Widget _buildLeftSide(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProfileAvatar(context),
          const SizedBox(width: _AppHeaderConstants.userInfoSpacing),
          Expanded(child: _buildUserInfo(context)),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onProfileTap?.call();
        },
        borderRadius: BorderRadius.circular(26),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: _buildAvatarDecoration(context),
          child: _buildAvatarContent(context),
        ),
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context) {
    // Create a unique hero tag using multiple identifiers to ensure uniqueness
    final contextId =
        widget.heroContext ??
        widget.title?.replaceAll(' ', '_').toLowerCase() ??
        'default';
    final heroTag =
        'user_avatar_${widget.user.id}_${contextId}_${context.hashCode}';

    return Hero(
      tag: heroTag,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: _AppHeaderConstants.avatarRadius,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage: widget.user.profileImageUrl?.isNotEmpty == true
              ? NetworkImage(widget.user.profileImageUrl!)
              : null,
          child: widget.user.profileImageUrl?.isEmpty != false
              ? _buildAvatarInitials(context)
              : null,
        ),
      ),
    );
  }

  Widget _buildAvatarInitials(BuildContext context) {
    return Text(
      _getInitials(widget.user),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildUserNameRow(context),
        const SizedBox(height: 3),
        _buildSubtitleContent(context),
      ],
    );
  }

  Widget _buildUserNameRow(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            _getDisplayName(widget.user),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 0.1,
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.user.isEmailVerified) ...[
          const SizedBox(width: _AppHeaderConstants.verifiedIconSpacing),
          Icon(
            Icons.verified_rounded,
            size: _AppHeaderConstants.verifiedIconSize,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ],
    );
  }

  Widget _buildSubtitleContent(BuildContext context) {
    if (widget.workspaceTitle != null) {
      return _buildWorkspaceTitle(context);
    } else if (widget.title != null) {
      return _buildRegularTitle(context);
    } else if (widget.subtitle != null) {
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
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.workspaceTitle!,
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
      widget.title!,
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
      widget.subtitle!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRoleAndStatus(BuildContext context) {
    // If neither role nor status should be shown, return empty
    if (!widget.showUserRole && !widget.showOnlineStatus) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // Role badge (if enabled)
        if (widget.showUserRole) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _getRoleColor(
                widget.user.roleName,
              ).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getRoleColor(widget.user.roleName).withValues(
                  alpha: _isElevatedRole(widget.user.roleName) ? 0.5 : 0.3,
                ),
                width: _isElevatedRole(widget.user.roleName) ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getRoleColor(widget.user.roleName).withValues(
                    alpha: _isElevatedRole(widget.user.roleName) ? 0.15 : 0.1,
                  ),
                  blurRadius: _isElevatedRole(widget.user.roleName) ? 3 : 2,
                  offset: Offset(
                    0,
                    _isElevatedRole(widget.user.roleName) ? 1.5 : 1,
                  ),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _getRoleColor(widget.user.roleName),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatRoleName(widget.user.roleName),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getRoleColor(widget.user.roleName),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          if (widget.showOnlineStatus) const SizedBox(width: 8),
        ],
        // Online indicator (if enabled)
        if (widget.showOnlineStatus) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _AppHeaderConstants.onlineIndicatorSize,
            height: _AppHeaderConstants.onlineIndicatorSize,
            decoration: BoxDecoration(
              color: _getStatusColor(widget.userStatus),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor(
                    widget.userStatus,
                  ).withValues(alpha: 0.3),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: _AppHeaderConstants.onlineIndicatorSpacing),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _getStatusText(widget.userStatus),
              key: ValueKey(widget.userStatus),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getStatusColor(
                  widget.userStatus,
                ).withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildRightSide(BuildContext context) {
    final rightSideActions = <Widget>[];

    if (widget.showSearchIcon) {
      rightSideActions.add(_buildSearchIcon(context));
    }

    if (widget.showNotificationIcon) {
      rightSideActions.add(_buildNotificationIcon(context));
    }

    if (widget.actions != null) {
      rightSideActions.addAll(_buildCustomActions());
    }

    return rightSideActions;
  }

  Widget _buildSearchIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: _AppHeaderConstants.searchIconRightSpacing,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (widget.onSearchTap != null) {
              widget.onSearchTap!();
            } else {
              _showSearchSnackBar(context);
            }
          },
          borderRadius: BorderRadius.circular(
            _AppHeaderConstants.iconBorderRadius,
          ),
          child: Container(
            padding: const EdgeInsets.all(_AppHeaderConstants.iconPadding),
            decoration: _buildIconDecoration(context),
            child: Icon(
              Icons.search_rounded,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
              size: _AppHeaderConstants.iconSize,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: _AppHeaderConstants.notificationIconRightSpacing,
      ),
      child: TweenAnimationBuilder<double>(
        duration: _AppHeaderConstants.scaleAnimationDuration,
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale:
                _AppHeaderConstants.scaleAnimationStart +
                (_AppHeaderConstants.scaleAnimationRange * value),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildNotificationButton(context),
                if (widget.showNotificationBadge &&
                    widget.notificationCount > 0)
                  _buildNotificationBadge(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          if (widget.onNotificationTap != null) {
            widget.onNotificationTap!();
          } else {
            _showNotificationSnackBar(context);
          }
        },
        borderRadius: BorderRadius.circular(
          _AppHeaderConstants.iconBorderRadius,
        ),
        child: Container(
          padding: const EdgeInsets.all(_AppHeaderConstants.iconPadding),
          decoration: _buildIconDecoration(context),
          child: Icon(
            widget.showNotificationBadge && widget.notificationCount > 0
                ? Icons.notifications_active_rounded
                : Icons.notifications_outlined,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
            size: _AppHeaderConstants.iconSize,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(BuildContext context) {
    return Positioned(
      right: 6,
      top: 6,
      child: TweenAnimationBuilder<double>(
        duration: _AppHeaderConstants.badgeAnimationDuration,
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (context, badgeValue, child) {
          return Transform.scale(
            scale: badgeValue,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: _buildBadgeDecoration(context),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 16),
              child: Text(
                widget.notificationCount >
                        _AppHeaderConstants.maxNotificationCount
                    ? '${_AppHeaderConstants.maxNotificationCount}+'
                    : widget.notificationCount.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCustomActions() {
    return widget.actions!
        .map(
          (action) => Padding(
            padding: const EdgeInsets.only(
              left: _AppHeaderConstants.customActionLeftSpacing,
              right: _AppHeaderConstants.customActionRightSpacing,
            ),
            child: action,
          ),
        )
        .toList();
  }

  // MARK: - Style Helpers

  BoxDecoration _buildHeaderDecoration(BuildContext context) {
    if (widget.showGradient) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
            widget.backgroundColor?.withValues(alpha: 0.8) ??
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      );
    } else {
      return BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      );
    }
  }

  BoxDecoration _buildAvatarDecoration(BuildContext context) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.05),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
    );
  }

  BoxDecoration _buildIconDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(_AppHeaderConstants.iconBorderRadius),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
      ),
    );
  }

  BoxDecoration _buildBadgeDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.error,
          Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Theme.of(context).colorScheme.surface,
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Color? _getAppBarBackgroundColor(BuildContext context) {
    return widget.showGradient
        ? Colors.transparent
        : (widget.backgroundColor ?? Theme.of(context).colorScheme.surface);
  }

  SystemUiOverlayStyle _buildSystemOverlayStyle(BuildContext context) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    );
  }

  /// Get status color based on user status
  Color _getStatusColor(String status) {
    const statusColors = {
      'online': Colors.green,
      'away': Colors.amber,
      'busy': Colors.red,
      'dnd': Colors.red,
      'do not disturb': Colors.red,
      'offline': Colors.grey,
    };

    final colorScheme = statusColors[status.toLowerCase()] ?? Colors.green;
    return colorScheme.shade400;
  }

  /// Get status text based on user status
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

  // MARK: - Role Management Helpers

  /// Get role priority level (higher number = higher authority)
  ///
  /// Priority levels:
  /// - 10: Admin (highest authority)
  /// - 8: Project Manager (management level)
  /// - 2: User (operational level)
  /// - 0: Viewer (read-only access)
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

  /// Check if role should show elevated styling (Admin/Project Manager)
  bool _isElevatedRole(String roleName) {
    return _getRolePriority(roleName) >= 8;
  } // MARK: - Utility Methods

  /// Extract initials from user name or email
  String _getInitials(User user) {
    if (user.name.isNotEmpty) {
      final nameParts = user.name.trim().split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      }
      return user.name[0].toUpperCase();
    }
    return user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U';
  }

  /// Get display name from user object with fallback to email
  String _getDisplayName(User user) {
    if (user.name.isNotEmpty) {
      return user.name;
    }

    // Extract name from email if no name is provided
    final emailParts = user.email.split('@');
    if (emailParts.isNotEmpty && emailParts[0].isNotEmpty) {
      return emailParts[0]
          .replaceAll(RegExp(r'[._]'), ' ')
          .split(' ')
          .map(_capitalizeWord)
          .join(' ');
    }
    return 'User';
  }

  /// Capitalize first letter of a word
  String _capitalizeWord(String word) {
    if (word.isEmpty) return word;
    return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
  }

  /// Format role name to standardized display format
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

  /// Get role color based on standardized categories
  Color _getRoleColor(String roleName) {
    const roleColors = {
      // Admin - Highest authority
      'admin': Colors.red,
      'administrator': Colors.red,

      // Project Manager - Management roles
      'manager': Colors.purple,
      'project_manager': Colors.purple,
      'site_supervisor': Colors.purple,
      'supervisor': Colors.purple,

      // User - Operational roles
      'user': Colors.blue,
      'member': Colors.blue,
      'technician': Colors.blue,
      'tech': Colors.blue,
      'field_technician': Colors.blue,
      'engineer': Colors.blue,
      'developer': Colors.blue,
      'dev': Colors.blue,
      'contractor': Colors.blue,
      'analyst': Colors.blue,
      'qa': Colors.blue,
      'quality_assurance': Colors.blue,
      'finance': Colors.blue,
      'accounting': Colors.blue,
      'hr': Colors.blue,
      'human_resources': Colors.blue,
      'sales': Colors.blue,
      'support': Colors.blue,

      // Viewer - Read-only roles
      'viewer': Colors.grey,
      'guest': Colors.grey,
      'client': Colors.grey,
      'customer': Colors.grey,
    };

    final colorScheme = roleColors[roleName.toLowerCase()] ?? Colors.blue;
    return colorScheme.shade600;
  }

  // MARK: - Snackbar Helpers

  /// Show search functionality snackbar
  void _showSearchSnackBar(BuildContext context) {
    _showSnackBar(
      context,
      icon: Icons.search_rounded,
      message: 'Search functionality coming soon!',
    );
  }

  /// Show notification functionality snackbar
  void _showNotificationSnackBar(BuildContext context) {
    _showSnackBar(
      context,
      icon: Icons.notifications_active_rounded,
      message: 'Notifications feature coming soon!',
    );
  }

  /// Generic snackbar helper
  void _showSnackBar(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.onInverseSurface,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        duration: _AppHeaderConstants.snackBarDuration,
      ),
    );
  }
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
