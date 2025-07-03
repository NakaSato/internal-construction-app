import '../../domain/entities/notification_statistics.dart';

/// Data model for notification statistics
class NotificationStatisticsModel {
  final int unreadCount;
  final int readCount;
  final int totalCount;
  final Map<String, int> typeBreakdown;
  final RecentActivityModel recentActivity;

  const NotificationStatisticsModel({
    required this.unreadCount,
    required this.readCount,
    required this.totalCount,
    required this.typeBreakdown,
    required this.recentActivity,
  });

  /// Convert to domain entity
  NotificationStatistics toEntity() {
    return NotificationStatistics(
      unreadCount: unreadCount,
      readCount: readCount,
      totalCount: totalCount,
      typeBreakdown: typeBreakdown,
      recentActivity: recentActivity.toEntity(),
    );
  }

  /// Create from JSON
  factory NotificationStatisticsModel.fromJson(Map<String, dynamic> json) {
    return NotificationStatisticsModel(
      unreadCount: json['unreadCount'] ?? 0,
      readCount: json['readCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      typeBreakdown: Map<String, int>.from(json['typeBreakdown'] ?? {}),
      recentActivity: RecentActivityModel.fromJson(
        json['recentActivity'] ?? {},
      ),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'unreadCount': unreadCount,
      'readCount': readCount,
      'totalCount': totalCount,
      'typeBreakdown': typeBreakdown,
      'recentActivity': recentActivity.toJson(),
    };
  }
}

/// Data model for recent activity
class RecentActivityModel {
  final int last24Hours;
  final int lastWeek;
  final int lastMonth;

  const RecentActivityModel({
    required this.last24Hours,
    required this.lastWeek,
    required this.lastMonth,
  });

  /// Convert to domain entity
  RecentActivity toEntity() {
    return RecentActivity(
      last24Hours: last24Hours,
      lastWeek: lastWeek,
      lastMonth: lastMonth,
    );
  }

  /// Create from JSON
  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      last24Hours: json['last24Hours'] ?? 0,
      lastWeek: json['lastWeek'] ?? 0,
      lastMonth: json['lastMonth'] ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'last24Hours': last24Hours,
      'lastWeek': lastWeek,
      'lastMonth': lastMonth,
    };
  }
}

/// Data model for notification count
class NotificationCountModel {
  final int unreadCount;
  final int totalCount;

  const NotificationCountModel({
    required this.unreadCount,
    required this.totalCount,
  });

  /// Convert to domain entity
  NotificationCount toEntity() {
    return NotificationCount(unreadCount: unreadCount, totalCount: totalCount);
  }

  /// Create from JSON
  factory NotificationCountModel.fromJson(Map<String, dynamic> json) {
    return NotificationCountModel(
      unreadCount: json['unreadCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'unreadCount': unreadCount, 'totalCount': totalCount};
  }
}
