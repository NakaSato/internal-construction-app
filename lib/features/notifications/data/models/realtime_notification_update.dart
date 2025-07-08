import 'package:equatable/equatable.dart';

import '../../domain/entities/notification.dart';
import '../../../../core/services/realtime_api_streams.dart';

/// Types of real-time notification updates
enum RealtimeNotificationUpdateType { added, updated, deleted, read, countChanged }

/// Real-time notification update model
class RealtimeNotificationUpdate extends RealtimeUpdate with EquatableMixin {
  RealtimeNotificationUpdate({
    required this.updateType,
    this.notification,
    this.notificationId,
    this.unreadCount,
    DateTime? timestamp,
  }) : super(type: updateType.name, endpoint: 'notifications', timestamp: timestamp ?? DateTime.now());

  /// The type of update (added, updated, deleted, read, countChanged)
  final RealtimeNotificationUpdateType updateType;

  /// The notification data (for added/updated types)
  final AppNotification? notification;

  /// The notification ID (for deleted/read types)
  final String? notificationId;

  /// Updated unread count (for countChanged type)
  final int? unreadCount;

  /// Create from JSON payload received from SignalR
  factory RealtimeNotificationUpdate.fromJson(Map<String, dynamic> json) {
    final typeStr = json['updateType'] as String;
    final updateType = RealtimeNotificationUpdateType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => RealtimeNotificationUpdateType.updated,
    );

    return RealtimeNotificationUpdate(
      updateType: updateType,
      notification: json['notification'] != null
          ? AppNotification.fromJson(json['notification'] as Map<String, dynamic>)
          : null,
      notificationId: json['notificationId'] as String?,
      unreadCount: json['unreadCount'] as int?,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp'] as String) : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'updateType': updateType.name,
      if (notification != null) 'notification': notification!.toJson(),
      if (notificationId != null) 'notificationId': notificationId,
      if (unreadCount != null) 'unreadCount': unreadCount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [updateType, notification, notificationId, unreadCount, timestamp];
}
