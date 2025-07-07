import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/notification_repository.dart';

part 'notification_settings_state.dart';

/// Cubit to manage notification settings
@injectable
class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  final NotificationRepository _repository;

  NotificationSettingsCubit(this._repository) : super(NotificationSettingsInitial());

  /// Fetch user notification settings
  Future<void> fetchSettings() async {
    emit(NotificationSettingsLoading());

    final result = await _repository.getNotificationSettings();

    result.fold(
      (failure) => emit(NotificationSettingsError(_mapFailureToMessage(failure))),
      (settings) => emit(NotificationSettingsLoaded(settings)),
    );
  }

  /// Update notification settings
  Future<void> updateSettings(NotificationSettings updatedSettings) async {
    if (state is NotificationSettingsLoaded) {
      final currentState = state as NotificationSettingsLoaded;
      emit(NotificationSettingsUpdating(currentState.settings));

      final result = await _repository.updateNotificationSettings(updatedSettings);

      result.fold(
        (failure) =>
            emit(NotificationSettingsError(_mapFailureToMessage(failure), currentSettings: currentState.settings)),
        (settings) => emit(NotificationSettingsLoaded(settings)),
      );
    }
  }

  /// Toggle email notifications
  Future<void> toggleEmailNotifications(bool enabled) async {
    if (state is NotificationSettingsLoaded) {
      final currentState = state as NotificationSettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(emailNotifications: enabled);
      await updateSettings(updatedSettings);
    }
  }

  /// Toggle push notifications
  Future<void> togglePushNotifications(bool enabled) async {
    if (state is NotificationSettingsLoaded) {
      final currentState = state as NotificationSettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(pushNotifications: enabled);
      await updateSettings(updatedSettings);
    }
  }

  /// Toggle SMS notifications
  Future<void> toggleSmsNotifications(bool enabled) async {
    if (state is NotificationSettingsLoaded) {
      final currentState = state as NotificationSettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(smsNotifications: enabled);
      await updateSettings(updatedSettings);
    }
  }

  /// Toggle quiet hours
  Future<void> toggleQuietHours(bool enabled) async {
    if (state is NotificationSettingsLoaded) {
      final currentState = state as NotificationSettingsLoaded;
      final currentQuietHours = currentState.settings.quietHours;

      QuietHoursSettings? updatedQuietHours;

      if (enabled) {
        // Enable with default settings if not configured before
        updatedQuietHours =
            currentQuietHours?.copyWith(enabled: true) ??
            QuietHoursSettings(
              enabled: true,
              startTime: '22:00',
              endTime: '07:00',
              timezone: 'Asia/Bangkok',
              allowCritical: true,
            );
      } else if (currentQuietHours != null) {
        // Disable existing settings
        updatedQuietHours = currentQuietHours.copyWith(enabled: false);
      }

      final updatedSettings = currentState.settings.copyWith(quietHours: updatedQuietHours);

      await updateSettings(updatedSettings);
    }
  }

  /// Update quiet hours settings
  Future<void> updateQuietHours(QuietHoursSettings quietHours) async {
    if (state is NotificationSettingsLoaded) {
      final currentState = state as NotificationSettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(quietHours: quietHours);
      await updateSettings(updatedSettings);
    }
  }

  /// Toggle digest mode
  Future<void> toggleDigestMode(bool enabled) async {
    if (state is NotificationSettingsLoaded) {
      final currentState = state as NotificationSettingsLoaded;
      final currentDigest = currentState.settings.digestSettings;

      DigestSettings? updatedDigest;

      if (enabled) {
        // Enable with default settings if not configured before
        if (currentDigest != null) {
          // Ensure all required fields have values
          updatedDigest = currentDigest.copyWith(
            enabled: true,
            frequency: currentDigest.frequency.isEmpty ? 'daily' : currentDigest.frequency,
            time: currentDigest.time ?? '08:00',
          );
        } else {
          // Create new settings with defaults
          updatedDigest = DigestSettings(
            enabled: true,
            frequency: 'daily',
            time: '08:00',
            timezone: 'Asia/Bangkok',
            includeLowPriority: false,
          );
        }
      } else if (currentDigest != null) {
        // Disable existing settings
        updatedDigest = currentDigest.copyWith(enabled: false);
      }

      final updatedSettings = currentState.settings.copyWith(digestSettings: updatedDigest);

      await updateSettings(updatedSettings);
    }
  }

  /// Update digest settings
  Future<void> updateDigestSettings(DigestSettings digestSettings) async {
    if (state is NotificationSettingsLoaded) {
      final currentState = state as NotificationSettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(digestSettings: digestSettings);
      await updateSettings(updatedSettings);
    }
  }

  /// Update notification type preference
  Future<void> updateTypePreference(String notificationType, NotificationTypePreference preference) async {
    if (state is NotificationSettingsLoaded) {
      final currentState = state as NotificationSettingsLoaded;
      final currentPreferences = Map<String, NotificationTypePreference>.from(currentState.settings.preferences);

      currentPreferences[notificationType] = preference;

      final updatedSettings = currentState.settings.copyWith(preferences: currentPreferences);

      await updateSettings(updatedSettings);
    }
  }

  /// Map failure to user-friendly message
  String _mapFailureToMessage(Object? failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection.';
    } else if (failure is Failure) {
      return failure.message;
    } else {
      return 'Unexpected error occurred. Please try again.';
    }
  }
}
