import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../application/cubits/notification_cubit.dart';

/// Widget to display a notification badge with unread count
/// Can be used in any part of the app, typically in the app bar or bottom navigation
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    Key? key,
    this.icon = Icons.notifications,
    this.showCount = true,
    this.size = 24,
    this.color,
    this.badgeColor,
    this.onPressed,
  }) : super(key: key);

  /// Icon to display
  final IconData icon;
  
  /// Whether to show the count in the badge
  final bool showCount;
  
  /// Size of the icon
  final double size;
  
  /// Color of the icon
  final Color? color;
  
  /// Color of the badge
  final Color? badgeColor;
  
  /// Custom action when pressed, if null will navigate to notifications screen
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final unreadCount = state.unreadCount;
        final hasNewNotifications = state is NotificationLoaded && state.hasNewNotifications;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(
                icon,
                size: size,
                color: color,
              ),
              onPressed: onPressed ?? () {
                context.push('/notifications');
              },
            ),
            if (unreadCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(showCount ? 4 : 3),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Theme.of(context).colorScheme.error,
                    shape: showCount ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: showCount ? BorderRadius.circular(8) : null,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: showCount
                      ? Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : const SizedBox(width: 4, height: 4),
                ),
              ),
            if (hasNewNotifications && unreadCount == 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: badgeColor ?? Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
