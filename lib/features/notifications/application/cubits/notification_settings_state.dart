part of 'notification_settings_cubit.dart';

/// Base state for notification settings
abstract class NotificationSettingsState extends Equatable {
  const NotificationSettingsState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state when the settings system starts
class NotificationSettingsInitial extends NotificationSettingsState {}

/// Loading state when fetching settings
class NotificationSettingsLoading extends NotificationSettingsState {}

/// Updating state when changing settings
class NotificationSettingsUpdating extends NotificationSettingsState {
  final NotificationSettings settings;
  
  const NotificationSettingsUpdating(this.settings);
  
  @override
  List<Object?> get props => [settings];
}

/// Loaded state with settings data
class NotificationSettingsLoaded extends NotificationSettingsState {
  final NotificationSettings settings;
  
  const NotificationSettingsLoaded(this.settings);
  
  @override
  List<Object?> get props => [settings];
}

/// Error state when settings operations fail
class NotificationSettingsError extends NotificationSettingsState {
  final String message;
  final NotificationSettings? currentSettings;
  
  const NotificationSettingsError(this.message, {this.currentSettings});
  
  @override
  List<Object?> get props => [message, currentSettings];
}
