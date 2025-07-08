import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/realtime_api_streams.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notifications_response.dart';
import '../../domain/repositories/notification_repository.dart';

part 'notification_state.dart';

/// Cubit to manage notification state
@injectable
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;
  StreamSubscription? _notificationStreamSubscription;
  StreamSubscription? _unreadCountStreamSubscription;
  StreamSubscription? _appFocusSubscription;

  NotificationCubit(this._repository) : super(NotificationInitial()) {
    _initialize();
    _setupAppFocusListener();
  }

  Future<void> _initialize() async {
    // Listen to real-time notification updates
    _notificationStreamSubscription = _repository.getNotificationStream().listen(
      (notification) {
        _handleNewNotification(notification);
      },
      onError: (error) {
        emit(NotificationError('Failed to receive real-time notifications: $error'));
      },
    );

    // Listen to unread count updates
    _unreadCountStreamSubscription = _repository.getUnreadCountStream().listen(
      (count) {
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          emit(currentState.copyWith(unreadCount: count));
        }
      },
      onError: (error) {
        // We don't want to show an error for unread count failures
        // Just log it for debugging
        print('❌ Unread count stream error: $error');
      },
    );

    // Fetch notification statistics
    await _fetchStatistics();

    // Refresh notifications when app regains focus
    if (!kIsWeb) {
      _addFocusListener();
    }
  }

  void _handleNewNotification(AppNotification notification) {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final updatedNotifications = List<AppNotification>.from(currentState.notifications);

      // Check if this notification is already in the list
      final index = updatedNotifications.indexWhere((n) => n.id == notification.id);

      if (index >= 0) {
        // Update existing notification
        updatedNotifications[index] = notification;
      } else {
        // Add new notification at the beginning (most recent first)
        updatedNotifications.insert(0, notification);
      }

      emit(currentState.copyWith(notifications: updatedNotifications, hasNewNotifications: true));
    }
  }

  /// Fetch notifications with optional filtering and pagination
  Future<void> fetchNotifications({bool refresh = false, NotificationsQuery? query}) async {
    if (refresh) {
      emit(NotificationLoading());
    } else if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      emit(currentState.copyWith(isLoadingMore: true));
    } else {
      emit(NotificationLoading());
    }

    // Use default query if none provided
    final notificationsQuery = query ?? const NotificationsQuery(includeSummary: true);

    final result = await _repository.getNotifications(query: notificationsQuery);

    result.fold(
      (failure) {
        if (state is NotificationLoaded && !refresh) {
          final currentState = state as NotificationLoaded;
          emit(currentState.copyWith(isLoadingMore: false, error: _mapFailureToMessage(failure)));
        } else {
          emit(NotificationError(_mapFailureToMessage(failure)));
        }
      },
      (response) {
        if (state is NotificationLoaded && !refresh) {
          final currentState = state as NotificationLoaded;
          emit(
            NotificationLoaded(
              notifications: currentState.notifications + response.items,
              unreadCount: currentState.unreadCount,
              hasMoreToLoad: response.hasNextPage,
              currentPage: response.pageNumber,
              totalItems: response.totalCount,
              summary: response.summary,
              isLoadingMore: false,
            ),
          );
        } else {
          emit(
            NotificationLoaded(
              notifications: response.items,
              unreadCount: response.summary?.unreadCount ?? 0,
              hasMoreToLoad: response.hasNextPage,
              currentPage: response.pageNumber,
              totalItems: response.totalCount,
              summary: response.summary,
            ),
          );
        }
      },
    );
  }

  /// Load more notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      if (!currentState.hasMoreToLoad || currentState.isLoadingMore) {
        return;
      }

      // Create query for next page
      final query = NotificationsQuery(pageNumber: currentState.currentPage + 1, includeSummary: false);

      await fetchNotifications(query: query);
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final result = await _repository.markAsRead(notificationId);

    result.fold(
      (failure) {
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          emit(currentState.copyWith(error: 'Failed to mark notification as read: ${_mapFailureToMessage(failure)}'));
        }
      },
      (updatedNotification) {
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          final updatedNotifications = currentState.notifications.map((notification) {
            if (notification.id == notificationId) {
              return updatedNotification;
            }
            return notification;
          }).toList();

          emit(
            currentState.copyWith(
              notifications: updatedNotifications,
              unreadCount: currentState.unreadCount > 0 ? currentState.unreadCount - 1 : 0,
            ),
          );
        }
      },
    );
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      emit(currentState.copyWith(isUpdating: true));

      final result = await _repository.markAllAsRead();

      result.fold(
        (failure) {
          emit(
            currentState.copyWith(
              isUpdating: false,
              error: 'Failed to mark all notifications as read: ${_mapFailureToMessage(failure)}',
            ),
          );
        },
        (bulkResult) {
          final updatedNotifications = currentState.notifications.map((notification) {
            return notification.copyWith(isRead: true, readAt: DateTime.now());
          }).toList();

          emit(currentState.copyWith(notifications: updatedNotifications, unreadCount: 0, isUpdating: false));
        },
      );
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      emit(currentState.copyWith(isUpdating: true));

      final result = await _repository.deleteNotification(notificationId);

      result.fold(
        (failure) {
          emit(
            currentState.copyWith(
              isUpdating: false,
              error: 'Failed to delete notification: ${_mapFailureToMessage(failure)}',
            ),
          );
        },
        (_) {
          final updatedNotifications = currentState.notifications
              .where((notification) => notification.id != notificationId)
              .toList();

          // Update unread count if the deleted notification was unread
          final wasUnread =
              currentState.notifications
                  .firstWhere(
                    (n) => n.id == notificationId,
                    orElse: () => AppNotification(
                      id: '',
                      title: '',
                      message: '',
                      type: NotificationType.info,
                      createdAt: DateTime.now(),
                      isRead: true,
                    ),
                  )
                  .isRead ==
              false;

          final newUnreadCount = wasUnread && currentState.unreadCount > 0
              ? currentState.unreadCount - 1
              : currentState.unreadCount;

          emit(
            currentState.copyWith(notifications: updatedNotifications, unreadCount: newUnreadCount, isUpdating: false),
          );
        },
      );
    }
  }

  /// Fetch notification statistics
  Future<void> _fetchStatistics() async {
    final result = await _repository.getNotificationStatistics();

    result.fold(
      (failure) {
        // We don't show error for statistics failure, just log it
        print('❌ Failed to fetch notification statistics: ${_mapFailureToMessage(failure)}');
      },
      (statistics) {
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          emit(currentState.copyWith(unreadCount: statistics.unreadCount));
        } else {
          emit(NotificationInitial(unreadCount: statistics.unreadCount));
        }
      },
    );
  }

  /// Mark notifications as seen (client-side only)
  void markNotificationsAsSeen() {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      if (currentState.hasNewNotifications) {
        emit(currentState.copyWith(hasNewNotifications: false));
      }
    }
  }

  /// Map failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection.';
    } else {
      return 'Unexpected error occurred. Please try again.';
    }
  }

  /// Set up app focus listener to refresh data when app comes back to foreground
  void _setupAppFocusListener() {
    _appFocusSubscription?.cancel();

    try {
      final realtimeStreams = getIt<RealtimeApiStreams>();

      _appFocusSubscription = realtimeStreams.appFocusStream.listen((hasFocus) {
        if (kDebugMode) {
          debugPrint('NotificationCubit: App focus returned, refreshing notifications');
        }

        // Refresh notifications when app focus returns
        fetchNotifications(refresh: true);
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationCubit: Failed to setup app focus listener: $e');
      }
    }
  }

  void _addFocusListener() {
    // This method will be called when the app regains focus
    // We can use it to refresh notifications if needed
    final focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        // App has regained focus
        // Refresh notifications
        fetchNotifications(refresh: true);
      }
    });

    // Add the focus node to the widget tree
    // so that it can receive focus events
    // This is a workaround to listen to app focus changes
    // In a real app, you might want to use a more robust solution
    // like a dedicated service or manager for app lifecycle events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  Future<void> close() {
    _notificationStreamSubscription?.cancel();
    _unreadCountStreamSubscription?.cancel();
    _appFocusSubscription?.cancel();
    return super.close();
  }
}
