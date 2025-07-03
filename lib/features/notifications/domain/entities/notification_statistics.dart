import 'package:equatable/equatable.dart';

/// Represents notification count information
class NotificationCount extends Equatable {
  /// Number of unread notifications
  final int unreadCount;

  /// Total number of notifications
  final int totalCount;

  const NotificationCount({
    required this.unreadCount,
    required this.totalCount,
  });

  /// Number of read notifications
  int get readCount => totalCount - unreadCount;

  /// Whether there are any unread notifications
  bool get hasUnread => unreadCount > 0;

  /// Percentage of read notifications
  double get readPercentage => totalCount > 0 ? readCount / totalCount : 0.0;

  @override
  List<Object?> get props => [unreadCount, totalCount];
}

/// Represents detailed notification statistics
class NotificationStatistics extends Equatable {
  /// Number of unread notifications
  final int unreadCount;

  /// Number of read notifications
  final int readCount;

  /// Total number of notifications
  final int totalCount;

  /// Breakdown of notifications by type
  final Map<String, int> typeBreakdown;

  /// Recent activity statistics
  final RecentActivity recentActivity;

  const NotificationStatistics({
    required this.unreadCount,
    required this.readCount,
    required this.totalCount,
    required this.typeBreakdown,
    required this.recentActivity,
  });

  /// Whether there are any unread notifications
  bool get hasUnread => unreadCount > 0;

  /// Percentage of read notifications
  double get readPercentage => totalCount > 0 ? readCount / totalCount : 0.0;

  /// Most common notification type
  String? get mostCommonType {
    if (typeBreakdown.isEmpty) return null;

    return typeBreakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  @override
  List<Object?> get props => [
    unreadCount,
    readCount,
    totalCount,
    typeBreakdown,
    recentActivity,
  ];
}

/// Represents recent notification activity
class RecentActivity extends Equatable {
  /// Notifications received in the last 24 hours
  final int last24Hours;

  /// Notifications received in the last week
  final int lastWeek;

  /// Notifications received in the last month
  final int lastMonth;

  const RecentActivity({
    required this.last24Hours,
    required this.lastWeek,
    required this.lastMonth,
  });

  /// Average notifications per day in the last week
  double get averagePerDayLastWeek => lastWeek / 7.0;

  /// Average notifications per day in the last month
  double get averagePerDayLastMonth => lastMonth / 30.0;

  /// Whether there's been recent activity (last 24 hours)
  bool get hasRecentActivity => last24Hours > 0;

  @override
  List<Object?> get props => [last24Hours, lastWeek, lastMonth];
}
