import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification.dart';

/// Helper for notification-related operations
class NotificationHelper {
  /// Map failure to user-friendly message
  static String mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection.';
    } else {
      return 'Unexpected error occurred. Please try again.';
    }
  }

  /// Update notifications list with a new notification
  static List<AppNotification> updateNotificationsList(
    List<AppNotification> currentNotifications,
    AppNotification newNotification,
  ) {
    final updatedNotifications = List<AppNotification>.from(currentNotifications);

    // Check if this notification is already in the list
    final index = updatedNotifications.indexWhere((n) => n.id == newNotification.id);

    if (index >= 0) {
      // Update existing notification
      updatedNotifications[index] = newNotification;
    } else {
      // Add new notification at the beginning (most recent first)
      updatedNotifications.insert(0, newNotification);
    }

    return updatedNotifications;
  }
}
