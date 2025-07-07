import 'package:equatable/equatable.dart';

import '../../domain/entities/notification.dart';

/// Types of real-time notification updates
enum RealtimeNotificationUpdateType {
  added,
  updated,
  deleted,
  read,
  countChanged,
}

/// Real-time notification update model
class RealtimeNotificationUpdate extends Equatable {
  const RealtimeNotificationUpdate({
    required this.type,
    this.notification,
    this.notificationId,
    this.unreadCount,
  });

  /// The type of update (added, updated, deleted, read, countChanged)
  final RealtimeNotificationUpdateType type;
  
  /// The notification data (for added/updated types)
  final AppNotification? notification;
  
  /// The notification ID (for deleted/read types)
  final String? notificationId;
  
  /// Updated unread count (for countChanged type)
  final int? unreadCount;

  /// Create from JSON payload received from SignalR
  factory RealtimeNotificationUpdate.fromJson(Map<String, dynamic> json) {
    final typeStr = json['updateType'] as String;
    final type = RealtimeNotificationUpdateType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => RealtimeNotificationUpdateType.updated,
    );
    
    return RealtimeNotificationUpdate(
      type: type,
      notification: json['notification'] != null
          ? AppNotification.fromJson(json['notification'] as Map<String, dynamic>)
          : null,
      notificationId: json['notificationId'] as String?,
      unreadCount: json['unreadCount'] as int?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'updateType': type.name,
      if (notification != null) 'notification': notification!.toJson(),
      if (notificationId != null) 'notificationId': notificationId,
      if (unreadCount != null) 'unreadCount': unreadCount,
    };
  }

  @override
  List<Object?> get props => [type, notification, notificationId, unreadCount];
}
