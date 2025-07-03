import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/get_notification_count.dart';
import '../../domain/usecases/get_notification_statistics.dart';
import '../../domain/usecases/mark_notification_read.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../../../core/usecases/usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC for managing notification state and operations
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase _getNotifications;
  final GetNotificationCountUseCase _getNotificationCount;
  final GetNotificationStatisticsUseCase _getNotificationStatistics;
  final MarkNotificationAsReadUseCase _markNotificationAsRead;
  final MarkAllNotificationsAsReadUseCase _markAllNotificationsAsRead;
  final NotificationRepository _repository;

  // Current filters
  NotificationType? _currentTypeFilter;
  bool? _currentUnreadFilter;
  int _currentPage = 1;
  static const int _pageSize = 20;

  NotificationBloc({
    required GetNotificationsUseCase getNotifications,
    required GetNotificationCountUseCase getNotificationCount,
    required GetNotificationStatisticsUseCase getNotificationStatistics,
    required MarkNotificationAsReadUseCase markNotificationAsRead,
    required MarkAllNotificationsAsReadUseCase markAllNotificationsAsRead,
    required NotificationRepository repository,
  }) : _getNotifications = getNotifications,
       _getNotificationCount = getNotificationCount,
       _getNotificationStatistics = getNotificationStatistics,
       _markNotificationAsRead = markNotificationAsRead,
       _markAllNotificationsAsRead = markAllNotificationsAsRead,
       _repository = repository,
       super(const NotificationInitial()) {
    // Register event handlers
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
    on<LoadNotificationCount>(_onLoadNotificationCount);
    on<LoadNotificationStatistics>(_onLoadNotificationStatistics);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<SendTestNotification>(_onSendTestNotification);
    on<SendAnnouncement>(_onSendAnnouncement);
    on<TestSignalR>(_onTestSignalR);
    on<DeleteNotification>(_onDeleteNotification);
    on<FilterNotificationsByType>(_onFilterNotificationsByType);
    on<FilterNotificationsByReadStatus>(_onFilterNotificationsByReadStatus);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<ClearNotificationFilters>(_onClearNotificationFilters);
    on<NotificationReceived>(_onNotificationReceived);
  }

  /// Load notifications with optional filters
  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (event.refresh || state is! NotificationLoaded) {
      emit(const NotificationLoading());
    }

    _currentPage = event.page;
    _currentTypeFilter = event.type;
    _currentUnreadFilter = event.unreadOnly;

    final params = GetNotificationsParams(
      page: event.page,
      pageSize: event.pageSize,
      unreadOnly: event.unreadOnly,
      type: event.type,
    );

    final result = await _getNotifications(params);

    result.fold((failure) => emit(NotificationError(failure.message)), (
      notificationResult,
    ) async {
      // Also load count and statistics
      final countResult = await _getNotificationCount(NoParams());
      final statisticsResult = await _getNotificationStatistics(NoParams());

      emit(
        NotificationLoaded(
          notifications: notificationResult.notifications,
          pagination: notificationResult.pagination,
          count: countResult.fold((failure) => null, (count) => count),
          statistics: statisticsResult.fold(
            (failure) => null,
            (statistics) => statistics,
          ),
          currentTypeFilter: _currentTypeFilter,
          currentUnreadFilter: _currentUnreadFilter,
        ),
      );
    });
  }

  /// Load more notifications for pagination
  Future<void> _onLoadMoreNotifications(
    LoadMoreNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationLoaded ||
        !currentState.hasMorePages ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = _currentPage + 1;
    final params = GetNotificationsParams(
      page: nextPage,
      pageSize: _pageSize,
      unreadOnly: _currentUnreadFilter,
      type: _currentTypeFilter,
    );

    final result = await _getNotifications(params);

    result.fold((failure) => emit(NotificationError(failure.message)), (
      notificationResult,
    ) {
      _currentPage = nextPage;
      final updatedNotifications = [
        ...currentState.notifications,
        ...notificationResult.notifications,
      ];

      emit(
        currentState.copyWith(
          notifications: updatedNotifications,
          pagination: notificationResult.pagination,
          isLoadingMore: false,
        ),
      );
    });
  }

  /// Load notification count
  Future<void> _onLoadNotificationCount(
    LoadNotificationCount event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _getNotificationCount(NoParams());

    result.fold((failure) => emit(NotificationError(failure.message)), (count) {
      if (state is NotificationLoaded) {
        emit((state as NotificationLoaded).copyWith(count: count));
      } else {
        emit(NotificationCountLoaded(count));
      }
    });
  }

  /// Load notification statistics
  Future<void> _onLoadNotificationStatistics(
    LoadNotificationStatistics event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _getNotificationStatistics(NoParams());

    result.fold((failure) => emit(NotificationError(failure.message)), (
      statistics,
    ) {
      if (state is NotificationLoaded) {
        emit((state as NotificationLoaded).copyWith(statistics: statistics));
      } else {
        emit(NotificationStatisticsLoaded(statistics));
      }
    });
  }

  /// Mark a notification as read
  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationMarkingAsRead(event.notificationId));

    final result = await _markNotificationAsRead(event.notificationId);

    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      // Update the notification in the current list
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications = currentState.notifications
            .map(
              (notification) => notification.id == event.notificationId
                  ? notification.markAsRead()
                  : notification,
            )
            .toList();

        emit(currentState.copyWith(notifications: updatedNotifications));
      }

      // Reload count and statistics
      add(const LoadNotificationCount());
      add(const LoadNotificationStatistics());

      emit(const NotificationOperationSuccess('Notification marked as read'));
    });
  }

  /// Mark all notifications as read
  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationMarkingAllAsRead());

    final result = await _markAllNotificationsAsRead(NoParams());

    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      // Update all notifications in the current list
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications = currentState.notifications
            .map((notification) => notification.markAsRead())
            .toList();

        emit(currentState.copyWith(notifications: updatedNotifications));
      }

      // Reload count and statistics
      add(const LoadNotificationCount());
      add(const LoadNotificationStatistics());

      emit(
        const NotificationOperationSuccess('All notifications marked as read'),
      );
    });
  }

  /// Send test notification
  Future<void> _onSendTestNotification(
    SendTestNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationSendingTest());

    final result = await _repository.sendTestNotification(
      message: event.message,
      type: event.type,
    );

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(const NotificationOperationSuccess('Test notification sent')),
    );
  }

  /// Send announcement
  Future<void> _onSendAnnouncement(
    SendAnnouncement event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationSendingAnnouncement());

    final result = await _repository.sendAnnouncement(
      message: event.message,
      priority: event.priority,
      targetAudience: event.targetAudience,
    );

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(const NotificationOperationSuccess('Announcement sent')),
    );
  }

  /// Test SignalR functionality
  Future<void> _onTestSignalR(
    TestSignalR event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationTestingSignalR());

    final result = await _repository.testSignalR(
      message: event.message,
      targetUserId: event.targetUserId,
    );

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(const NotificationOperationSuccess('SignalR test sent')),
    );
  }

  /// Delete notification
  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationDeleting(event.notificationId));

    final result = await _repository.deleteNotification(event.notificationId);

    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      // Remove notification from current list
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications = currentState.notifications
            .where((notification) => notification.id != event.notificationId)
            .toList();

        emit(currentState.copyWith(notifications: updatedNotifications));
      }

      // Reload count and statistics
      add(const LoadNotificationCount());
      add(const LoadNotificationStatistics());

      emit(const NotificationOperationSuccess('Notification deleted'));
    });
  }

  /// Filter notifications by type
  void _onFilterNotificationsByType(
    FilterNotificationsByType event,
    Emitter<NotificationState> emit,
  ) {
    _currentTypeFilter = event.type;
    _currentPage = 1;

    add(
      LoadNotifications(
        type: event.type,
        unreadOnly: _currentUnreadFilter,
        refresh: true,
      ),
    );
  }

  /// Filter notifications by read status
  void _onFilterNotificationsByReadStatus(
    FilterNotificationsByReadStatus event,
    Emitter<NotificationState> emit,
  ) {
    _currentUnreadFilter = event.unreadOnly;
    _currentPage = 1;

    add(
      LoadNotifications(
        unreadOnly: event.unreadOnly,
        type: _currentTypeFilter,
        refresh: true,
      ),
    );
  }

  /// Refresh all notification data
  void _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) {
    _currentPage = 1;
    add(
      LoadNotifications(
        type: _currentTypeFilter,
        unreadOnly: _currentUnreadFilter,
        refresh: true,
      ),
    );
    add(const LoadNotificationCount());
    add(const LoadNotificationStatistics());
  }

  /// Clear notification filters
  void _onClearNotificationFilters(
    ClearNotificationFilters event,
    Emitter<NotificationState> emit,
  ) {
    _currentTypeFilter = null;
    _currentUnreadFilter = null;
    _currentPage = 1;

    add(const LoadNotifications(refresh: true));
  }

  /// Handle notification received from SignalR
  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final updatedNotifications = [
        event.notification,
        ...currentState.notifications,
      ];

      emit(currentState.copyWith(notifications: updatedNotifications));

      // Reload count and statistics
      add(const LoadNotificationCount());
      add(const LoadNotificationStatistics());
    }

    emit(NotificationReceivedState(event.notification));
  }
}
