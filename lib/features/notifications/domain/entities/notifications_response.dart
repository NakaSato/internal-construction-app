import 'package:equatable/equatable.dart';
import 'notification.dart';

/// Response model for paginated notification lists with summary information
class NotificationsResponse extends Equatable {
  const NotificationsResponse({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
    this.summary,
  });

  /// List of notification items in this page
  final List<AppNotification> items;
  
  /// Current page number
  final int pageNumber;
  
  /// Number of items per page
  final int pageSize;
  
  /// Total count of all notifications matching the query
  final int totalCount;
  
  /// Total number of pages available
  final int totalPages;
  
  /// Whether there is a previous page available
  final bool hasPreviousPage;
  
  /// Whether there is a next page available
  final bool hasNextPage;
  
  /// Summary statistics for notifications
  final NotificationSummary? summary;

  /// Creates a NotificationsResponse from JSON data
  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'] as List<dynamic>;
    final items = itemsJson
        .map((itemJson) => AppNotification.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    return NotificationsResponse(
      items: items,
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
      totalCount: json['totalCount'] as int,
      totalPages: json['totalPages'] as int,
      hasPreviousPage: json['hasPreviousPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
      summary: json['summary'] != null
          ? NotificationSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts the response to JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalCount': totalCount,
      'totalPages': totalPages,
      'hasPreviousPage': hasPreviousPage,
      'hasNextPage': hasNextPage,
      if (summary != null) 'summary': summary!.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    items,
    pageNumber,
    pageSize,
    totalCount,
    totalPages,
    hasPreviousPage,
    hasNextPage,
    summary,
  ];
}

/// Summary statistics for notifications
class NotificationSummary extends Equatable {
  const NotificationSummary({
    required this.unreadCount,
    this.criticalCount = 0,
    this.highPriorityCount = 0,
    this.expiringSoonCount = 0,
    this.todayCount = 0,
  });

  /// Count of unread notifications
  final int unreadCount;
  
  /// Count of critical notifications
  final int criticalCount;
  
  /// Count of high priority notifications
  final int highPriorityCount;
  
  /// Count of notifications expiring soon
  final int expiringSoonCount;
  
  /// Count of notifications received today
  final int todayCount;

  /// Creates a NotificationSummary from JSON data
  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    return NotificationSummary(
      unreadCount: json['unreadCount'] as int,
      criticalCount: json['criticalCount'] as int? ?? 0,
      highPriorityCount: json['highPriorityCount'] as int? ?? 0,
      expiringSoonCount: json['expiringSoonCount'] as int? ?? 0,
      todayCount: json['todayCount'] as int? ?? 0,
    );
  }

  /// Converts the summary to JSON
  Map<String, dynamic> toJson() {
    return {
      'unreadCount': unreadCount,
      'criticalCount': criticalCount,
      'highPriorityCount': highPriorityCount,
      'expiringSoonCount': expiringSoonCount,
      'todayCount': todayCount,
    };
  }

  @override
  List<Object> get props => [
    unreadCount,
    criticalCount,
    highPriorityCount,
    expiringSoonCount,
    todayCount,
  ];
}

/// Detailed notification count statistics
class NotificationCountStatistics extends Equatable {
  const NotificationCountStatistics({
    required this.totalCount,
    required this.unreadCount,
    required this.readCount,
    required this.priorityCounts,
    required this.typeCounts,
    required this.categoryCounts,
    required this.timeBasedCounts,
    required this.unreadByPriority,
  });

  /// Total notification count
  final int totalCount;
  
  /// Count of unread notifications
  final int unreadCount;
  
  /// Count of read notifications
  final int readCount;
  
  /// Counts by priority level
  final Map<String, int> priorityCounts;
  
  /// Counts by notification type
  final Map<String, int> typeCounts;
  
  /// Counts by notification category
  final Map<String, int> categoryCounts;
  
  /// Counts by time periods
  final Map<String, int> timeBasedCounts;
  
  /// Unread counts by priority
  final Map<String, int> unreadByPriority;

  /// Creates a NotificationCountStatistics from JSON data
  factory NotificationCountStatistics.fromJson(Map<String, dynamic> json) {
    return NotificationCountStatistics(
      totalCount: json['totalCount'] as int,
      unreadCount: json['unreadCount'] as int,
      readCount: json['readCount'] as int,
      priorityCounts: Map<String, int>.from(json['priorityCounts'] as Map),
      typeCounts: Map<String, int>.from(json['typeCounts'] as Map),
      categoryCounts: Map<String, int>.from(json['categoryCounts'] as Map),
      timeBasedCounts: Map<String, int>.from(json['timeBasedCounts'] as Map),
      unreadByPriority: Map<String, int>.from(json['unreadByPriority'] as Map),
    );
  }

  /// Converts the statistics to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'unreadCount': unreadCount,
      'readCount': readCount,
      'priorityCounts': priorityCounts,
      'typeCounts': typeCounts,
      'categoryCounts': categoryCounts,
      'timeBasedCounts': timeBasedCounts,
      'unreadByPriority': unreadByPriority,
    };
  }

  @override
  List<Object> get props => [
    totalCount,
    unreadCount,
    readCount,
    priorityCounts,
    typeCounts,
    categoryCounts,
    timeBasedCounts,
    unreadByPriority,
  ];
}

/// Result of a bulk operation on notifications
class BulkNotificationResult extends Equatable {
  const BulkNotificationResult({
    required this.totalRequested,
    required this.successfullyProcessed,
    this.errors = const [],
  });

  /// Total number of notifications requested for processing
  final int totalRequested;
  
  /// Number of notifications successfully processed
  final int successfullyProcessed;
  
  /// List of errors encountered during processing
  final List<String> errors;

  /// Creates a BulkNotificationResult from JSON data
  factory BulkNotificationResult.fromJson(Map<String, dynamic> json) {
    List<dynamic> errorsJson = json['errors'] as List<dynamic>? ?? [];
    List<String> errors = errorsJson.map((e) => e.toString()).toList();

    return BulkNotificationResult(
      totalRequested: json['totalRequested'] as int,
      successfullyProcessed: json['successfullyProcessed'] as int,
      errors: errors,
    );
  }

  /// Converts the result to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalRequested': totalRequested,
      'successfullyProcessed': successfullyProcessed,
      'errors': errors,
    };
  }

  @override
  List<Object> get props => [
    totalRequested,
    successfullyProcessed,
    errors,
  ];
}
