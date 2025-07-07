import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:solar_mana/core/di/injection.dart';
import 'package:solar_mana/core/services/realtime_api_streams.dart';
import 'package:solar_mana/features/notifications/application/cubits/notification_cubit.dart';
import 'package:solar_mana/features/notifications/domain/repositories/notification_repository.dart';
import 'package:solar_mana/features/notifications/domain/entities/notification.dart';
import 'package:solar_mana/features/notifications/domain/entities/notifications_response.dart';
import 'package:dartz/dartz.dart';

@GenerateMocks([NotificationRepository, RealtimeApiStreams])
void main() {
  late NotificationCubit notificationCubit;
  late MockNotificationRepository mockRepository;
  late MockRealtimeApiStreams mockRealtimeStreams;
  late StreamController<bool> appFocusController;
  late StreamController<AppNotification> notificationController;
  late StreamController<int> unreadCountController;

  setUp(() {
    mockRepository = MockNotificationRepository();
    mockRealtimeStreams = MockRealtimeApiStreams();
    appFocusController = StreamController<bool>.broadcast();
    notificationController = StreamController<AppNotification>.broadcast();
    unreadCountController = StreamController<int>.broadcast();
    
    // Setup the GetIt instance for testing
    GetIt.I.registerSingleton<RealtimeApiStreams>(mockRealtimeStreams);
    
    // Mock repository methods
    when(mockRepository.getNotifications()).thenAnswer((_) async => 
      Right(NotificationsResponse(
        notifications: const [],
        unreadCount: 0,
        hasMore: false,
        nextPageToken: null,
      ))
    );
    
    when(mockRepository.getNotificationStream()).thenAnswer((_) => notificationController.stream);
    when(mockRepository.getUnreadCountStream()).thenAnswer((_) => unreadCountController.stream);
    
    // Mock realtime streams
    when(mockRealtimeStreams.appFocusStream).thenAnswer((_) => appFocusController.stream);
    
    // Create the cubit
    notificationCubit = NotificationCubit(mockRepository);
  });

  tearDown(() {
    appFocusController.close();
    notificationController.close();
    unreadCountController.close();
    notificationCubit.close();
    GetIt.I.reset();
  });

  group('NotificationCubit', () {
    test('initial state is NotificationInitial', () {
      expect(notificationCubit.state, isA<NotificationInitial>());
    });

    blocTest<NotificationCubit, NotificationState>(
      'emits [NotificationLoading, NotificationLoaded] when loadAllNotifications is called',
      build: () => notificationCubit,
      act: (cubit) => cubit.loadAllNotifications(),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationLoaded>(),
      ],
    );

    test('refreshes notifications when app focus returns', () async {
      // Arrange - initialize cubit and clear verification
      await untilCalled(mockRepository.getNotifications());
      clearInteractions(mockRepository);
      
      // Act - trigger app focus event
      appFocusController.add(true);
      
      // Assert - verify repository was called again
      await untilCalled(mockRepository.getNotifications());
      verify(mockRepository.getNotifications()).called(1);
    });
  });
}
