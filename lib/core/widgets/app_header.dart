import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/authentication/domain/entities/user.dart';

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
  final VoidCallback? onSearchTap;
  final String? subtitle;
  final bool showGradient;
  final bool showOnlineStatus;
  final String? workspaceTitle;
  final VoidCallback? onNotificationTap;

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
    this.onSearchTap,
    this.subtitle,
    this.showGradient = true,
    this.showOnlineStatus = true,
    this.workspaceTitle,
    this.onNotificationTap,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}

class _AppHeaderState extends State<AppHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: widget.showGradient
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.backgroundColor ??
                          Theme.of(context).colorScheme.surface,
                      widget.backgroundColor?.withOpacity(0.8) ??
                          Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.95),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withOpacity(0.08),
                      offset: const Offset(0, 2),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.05),
                      offset: const Offset(0, 1),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                )
              : BoxDecoration(
                  color:
                      widget.backgroundColor ??
                      Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withOpacity(0.05),
                      offset: const Offset(0, 1),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
          child: AppBar(
            backgroundColor: widget.showGradient
                ? Colors.transparent
                : (widget.backgroundColor ??
                      Theme.of(context).colorScheme.surface),
            elevation: 0,
            centerTitle: widget.centerTitle,
            automaticallyImplyLeading: false,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
            ),
            title: _buildLeftSide(context),
            actions: _buildRightSide(context),
            toolbarHeight: kToolbarHeight + 8,
          ),
        ),
      ),
    );
  }

  Widget _buildLeftSide(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced Profile Avatar with modern glassmorphism effect
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onProfileTap?.call();
              },
              borderRadius: BorderRadius.circular(26),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.05),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.8),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Hero(
                      tag: 'user_avatar_${widget.user.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          backgroundImage: widget.user.profileImageUrl != null
                              ? NetworkImage(widget.user.profileImageUrl!)
                              : null,
                          child: widget.user.profileImageUrl == null
                              ? Text(
                                  _getInitials(widget.user),
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                      ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    // Online status indicator
                    if (widget.showOnlineStatus)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade400.withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Enhanced User Info with advanced typography and layout
          Flexible(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onProfileTap?.call();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _getDisplayName(widget.user),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    letterSpacing: 0.1,
                                    height: 1.2,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.user.isEmailVerified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      if (widget.workspaceTitle != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.workspaceTitle!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  letterSpacing: 0.3,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else if (widget.title != null) ...[
                        Text(
                          widget.title!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else if (widget.subtitle != null) ...[
                        Text(
                          widget.subtitle!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else if (widget.showOnlineStatus) ...[
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.green.shade400,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.shade400.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Online',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    letterSpacing: 0.3,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRightSide(BuildContext context) {
    final rightSideActions = <Widget>[];

    // Enhanced search icon with modern styling
    if (widget.showSearchIcon) {
      rightSideActions.add(
        Material(
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
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Icon(
                Icons.search_rounded,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                size: 22,
              ),
            ),
          ),
        ),
      );
    }

    // Enhanced notification icon with advanced badge and animation
    rightSideActions.add(
      TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Material(
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
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      child: Icon(
                        widget.showNotificationBadge &&
                                widget.notificationCount > 0
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_outlined,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.8),
                        size: 22,
                      ),
                    ),
                  ),
                ),
                if (widget.showNotificationBadge &&
                    widget.notificationCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.elasticOut,
                      builder: (context, badgeValue, child) {
                        return Transform.scale(
                          scale: badgeValue,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.error,
                                  Theme.of(
                                    context,
                                  ).colorScheme.error.withOpacity(0.8),
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.error.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 16,
                            ),
                            child: Text(
                              widget.notificationCount > 99
                                  ? '99+'
                                  : widget.notificationCount.toString(),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onError,
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
                  ),
              ],
            ),
          );
        },
      ),
    );

    // Add any custom actions passed in with enhanced styling
    if (widget.actions != null) {
      rightSideActions.addAll(
        widget.actions!.map(
          (action) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: action,
          ),
        ),
      );
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

  void _showSearchSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: Theme.of(context).colorScheme.onInverseSurface,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Search functionality coming soon!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showNotificationSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.notifications_active_rounded,
              color: Theme.of(context).colorScheme.onInverseSurface,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Notifications feature coming soon!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        duration: const Duration(seconds: 2),
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
