import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/notification.dart';
import '../../../domain/repositories/notification_repository.dart';

/// Handles real-time notification updates
class NotificationRealtimeHandler {
  final NotificationRepository _repository;
  StreamSubscription? _notificationStreamSubscription;
  StreamSubscription? _unreadCountStreamSubscription;

  NotificationRealtimeHandler(this._repository);

  /// Initialize real-time notification streams
  void initialize({
    required void Function(AppNotification) onNewNotification,
    required void Function(int) onUnreadCountChanged,
    required void Function(String) onError,
  }) {
    // Listen to real-time notification updates
    _notificationStreamSubscription = _repository.getNotificationStream().listen(
      onNewNotification,
      onError: (error) {
        onError('Failed to receive real-time notifications: $error');
      },
    );

    // Listen to unread count updates
    _unreadCountStreamSubscription = _repository.getUnreadCountStream().listen(
      onUnreadCountChanged,
      onError: (error) {
        // We don't want to show an error for unread count failures
        // Just log it for debugging
        debugPrint('❌ Unread count stream error: $error');
      },
    );
  }

  /// Clean up resources
  void dispose() {
    _notificationStreamSubscription?.cancel();
    _unreadCountStreamSubscription?.cancel();
  }
}
