import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/mixins/realtime_api_mixin.dart';
import '../../../../core/error/failures.dart';
import '../models/realtime_notification_update.dart';
import 'api_notification_repository.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/entities/notifications_response.dart';
import '../../domain/repositories/notification_repository.dart';

/// Enhanced API repository wrapper that adds real-time updates to existing repository
/// Decorator pattern to add real-time capabilities without modifying existing code
@LazySingleton(as: NotificationRepository, env: [Environment.dev, Environment.prod])
class RealtimeNotificationRepositoryWrapper with RealtimeApiMixin implements NotificationRepository {
  RealtimeNotificationRepositoryWrapper(this._baseRepository) {
    // Initialize real-time updates
    initializeRealtimeUpdates();
  }

  final ApiNotificationRepository _baseRepository;

  // Real-time update stream controllers
  final StreamController<AppNotification> _notificationStreamController = 
      StreamController<AppNotification>.broadcast();
  
  final StreamController<int> _unreadCountStreamController = 
      StreamController<int>.broadcast();
  
  int _cachedUnreadCount = 0;

  @override
  String get endpointName => 'notifications';

  /// Stream of real-time notification updates
  @override
  Stream<AppNotification> getNotificationStream() => _notificationStreamController.stream;
  
  /// Stream of unread notification counts
  @override
  Stream<int> getUnreadCountStream() => _unreadCountStreamController.stream;

  /// Initialize real-time updates for this repository
  Future<void> initializeRealtimeUpdates() async {
    startRealtimeUpdates<RealtimeNotificationUpdate>(
      onUpdate: _handleRealtimeUpdate,
      onError: (error) {
        if (kDebugMode) {
          debugPrint('❌ RealtimeNotificationRepositoryWrapper: Real-time error: $error');
        }
      },
    );
  }

  /// Handle incoming real-time updates
  void _handleRealtimeUpdate(RealtimeNotificationUpdate update) {
    if (kDebugMode) {
      debugPrint('📡 RealtimeNotificationRepositoryWrapper: Received real-time update: ${update.type}');
    }

    switch (update.type) {
      case RealtimeNotificationUpdateType.added:
      case RealtimeNotificationUpdateType.updated:
        if (update.notification != null) {
          _notificationStreamController.add(update.notification!);
        }
        break;
      case RealtimeNotificationUpdateType.countChanged:
        if (update.unreadCount != null) {
          _cachedUnreadCount = update.unreadCount!;
          _unreadCountStreamController.add(update.unreadCount!);
        }
        break;
      case RealtimeNotificationUpdateType.read:
      case RealtimeNotificationUpdateType.deleted:
        // These will typically be followed by a countChanged update
        break;
    }
  }

  // Delegate all methods to base repository while adding real-time markers

  @override
  Future<Either<Failure, NotificationsResponse>> getNotifications({
    NotificationsQuery query = const NotificationsQuery(),
  }) async {
    if (kDebugMode) {
      debugPrint('📬 RealtimeNotificationRepositoryWrapper.getNotifications called with real-time support');
    }
    return await _baseRepository.getNotifications(query: query);
  }

  @override
  Future<Either<Failure, AppNotification>> getNotificationById(String notificationId) async {
    if (kDebugMode) {
      debugPrint('🔍 RealtimeNotificationRepositoryWrapper.getNotificationById called with real-time support');
    }
    return await _baseRepository.getNotificationById(notificationId);
  }

  @override
  Future<Either<Failure, AppNotification>> markAsRead(String notificationId) async {
    if (kDebugMode) {
      debugPrint('✅ RealtimeNotificationRepositoryWrapper.markAsRead called with real-time notifications');
    }

    // Add real-time notification flags
    // This approach mimics how the project repository adds real-time flags
    final result = await _baseRepository.markAsRead(notificationId);
    
    return result;
  }

  @override
  Future<Either<Failure, BulkNotificationResult>> markMultipleAsRead(List<String> notificationIds) async {
    if (kDebugMode) {
      debugPrint('✅ RealtimeNotificationRepositoryWrapper.markMultipleAsRead called with real-time notifications');
    }
    return await _baseRepository.markMultipleAsRead(notificationIds);
  }

  @override
  Future<Either<Failure, BulkNotificationResult>> markAllAsRead() async {
    if (kDebugMode) {
      debugPrint('✅ RealtimeNotificationRepositoryWrapper.markAllAsRead called with real-time notifications');
    }
    return await _baseRepository.markAllAsRead();
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    if (kDebugMode) {
      debugPrint('🗑️ RealtimeNotificationRepositoryWrapper.deleteNotification called with real-time notifications');
    }
    return await _baseRepository.deleteNotification(notificationId);
  }

  @override
  Future<Either<Failure, BulkNotificationResult>> deleteMultipleNotifications(List<String> notificationIds) async {
    if (kDebugMode) {
      debugPrint('🗑️ RealtimeNotificationRepositoryWrapper.deleteMultipleNotifications called with real-time notifications');
    }
    return await _baseRepository.deleteMultipleNotifications(notificationIds);
  }

  @override
  Future<Either<Failure, NotificationCountStatistics>> getNotificationStatistics() async {
    if (kDebugMode) {
      debugPrint('📊 RealtimeNotificationRepositoryWrapper.getNotificationStatistics called with real-time support');
    }
    return await _baseRepository.getNotificationStatistics();
  }
  
  @override
  Future<Either<Failure, NotificationSettings>> getNotificationSettings() async {
    if (kDebugMode) {
      debugPrint('⚙️ RealtimeNotificationRepositoryWrapper.getNotificationSettings called with real-time support');
    }
    return await _baseRepository.getNotificationSettings();
  }
  
  @override
  Future<Either<Failure, NotificationSettings>> updateNotificationSettings(
    NotificationSettings settings,
  ) async {
    if (kDebugMode) {
      debugPrint('⚙️ RealtimeNotificationRepositoryWrapper.updateNotificationSettings called with real-time support');
    }
    return await _baseRepository.updateNotificationSettings(settings);
  }

  /// Dispose resources including real-time updates
  void dispose() {
    stopRealtimeUpdates();
    _notificationStreamController.close();
    _unreadCountStreamController.close();
  }
}
