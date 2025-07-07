import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/cubits/notification_settings_cubit.dart';
import '../../domain/entities/notification_settings.dart';

/// Screen for configuring notification settings
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  /// Converts a time string in format "HH:MM" to TimeOfDay
  TimeOfDay _timeStringToTimeOfDay(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: BlocConsumer<NotificationSettingsCubit, NotificationSettingsState>(
        listener: (context, state) {
          if (state is NotificationSettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is NotificationSettingsInitial) {
            // Trigger fetching settings when screen loads
            context.read<NotificationSettingsCubit>().fetchSettings();
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationSettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationSettingsUpdating) {
            return Stack(
              children: [
                _buildSettingsContent(context, state.settings),
                const Center(child: CircularProgressIndicator()),
              ],
            );
          } else if (state is NotificationSettingsLoaded) {
            return _buildSettingsContent(context, state.settings);
          } else if (state is NotificationSettingsError && state.currentSettings != null) {
            return _buildSettingsContent(context, state.currentSettings!);
          } else {
            return const Center(child: Text('Failed to load notification settings'));
          }
        },
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, NotificationSettings settings) {
    return ListView(
      children: [
        _buildGeneralSettingsSection(context, settings),
        const Divider(),
        _buildNotificationChannelsSection(context, settings),
        const Divider(),
        _buildQuietHoursSection(context, settings),
        const Divider(),
        _buildDigestSettingsSection(context, settings),
        const Divider(),
        _buildNotificationTypesSection(context, settings),
      ],
    );
  }

  Widget _buildGeneralSettingsSection(BuildContext context, NotificationSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('General Settings', style: Theme.of(context).textTheme.titleLarge),
        ),
        SwitchListTile(
          title: const Text('In-app Notifications'),
          subtitle: const Text('Show notifications within the app'),
          value: settings.inAppNotifications,
          onChanged: (value) {
            final updatedSettings = settings.copyWith(inAppNotifications: value);
            context.read<NotificationSettingsCubit>().updateSettings(updatedSettings);
          },
        ),
        ListTile(
          title: const Text('Notification Priority'),
          subtitle: const Text('Set minimum priority to receive'),
          trailing: DropdownButton<String>(
            value: 'all', // This would come from settings
            onChanged: (value) {
              // TODO: Implement priority filtering
            },
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Priorities')),
              DropdownMenuItem(value: 'high', child: Text('High & Critical')),
              DropdownMenuItem(value: 'critical', child: Text('Critical Only')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationChannelsSection(BuildContext context, NotificationSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Notification Channels', style: Theme.of(context).textTheme.titleLarge),
        ),
        SwitchListTile(
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive notifications on your device'),
          value: settings.pushNotifications,
          onChanged: (value) {
            context.read<NotificationSettingsCubit>().togglePushNotifications(value);
          },
        ),
        SwitchListTile(
          title: const Text('Email Notifications'),
          subtitle: const Text('Receive notifications via email'),
          value: settings.emailNotifications,
          onChanged: (value) {
            context.read<NotificationSettingsCubit>().toggleEmailNotifications(value);
          },
        ),
        SwitchListTile(
          title: const Text('SMS Notifications'),
          subtitle: const Text('Receive notifications via SMS'),
          value: settings.smsNotifications,
          onChanged: (value) {
            context.read<NotificationSettingsCubit>().toggleSmsNotifications(value);
          },
        ),
      ],
    );
  }

  Widget _buildQuietHoursSection(BuildContext context, NotificationSettings settings) {
    final quietHours = settings.quietHours;
    final isEnabled = quietHours?.enabled ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Quiet Hours', style: Theme.of(context).textTheme.titleLarge),
        ),
        SwitchListTile(
          title: const Text('Enable Quiet Hours'),
          subtitle: const Text('Mute non-critical notifications during specified hours'),
          value: isEnabled,
          onChanged: (value) {
            context.read<NotificationSettingsCubit>().toggleQuietHours(value);
          },
        ),
        if (isEnabled && quietHours != null) ...[
          ListTile(
            title: const Text('Start Time'),
            trailing: Text(quietHours.startTime),
            onTap: () async {
              // Show time picker dialog for start time
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _timeStringToTimeOfDay(quietHours.startTime),
              );

              if (picked != null) {
                final updatedTime =
                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                final updatedQuietHours = quietHours.copyWith(startTime: updatedTime);
                context.read<NotificationSettingsCubit>().updateQuietHours(updatedQuietHours);
              }
            },
          ),
          ListTile(
            title: const Text('End Time'),
            trailing: Text(quietHours.endTime),
            onTap: () async {
              // Show time picker dialog for end time
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _timeStringToTimeOfDay(quietHours.endTime),
              );

              if (picked != null) {
                final updatedTime =
                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                final updatedQuietHours = quietHours.copyWith(endTime: updatedTime);
                context.read<NotificationSettingsCubit>().updateQuietHours(updatedQuietHours);
              }
            },
          ),
          SwitchListTile(
            title: const Text('Allow Critical Notifications'),
            subtitle: const Text('Allow critical notifications during quiet hours'),
            value: quietHours.allowCritical,
            onChanged: (value) {
              final updatedQuietHours = quietHours.copyWith(allowCritical: value);
              context.read<NotificationSettingsCubit>().updateQuietHours(updatedQuietHours);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDigestSettingsSection(BuildContext context, NotificationSettings settings) {
    final digestSettings = settings.digestSettings;
    final isEnabled = digestSettings?.enabled ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Notification Digest', style: Theme.of(context).textTheme.titleLarge),
        ),
        SwitchListTile(
          title: const Text('Enable Digest Mode'),
          subtitle: const Text('Receive grouped notifications as a periodic summary'),
          value: isEnabled,
          onChanged: (value) {
            context.read<NotificationSettingsCubit>().toggleDigestMode(value);
          },
        ),
        if (isEnabled && digestSettings != null) ...[
          ListTile(
            title: const Text('Frequency'),
            trailing: DropdownButton<String>(
              value: digestSettings.frequency.isEmpty ? 'daily' : digestSettings.frequency,
              onChanged: (value) {
                if (value != null) {
                  final updatedDigest = digestSettings.copyWith(frequency: value);
                  context.read<NotificationSettingsCubit>().updateDigestSettings(updatedDigest);
                }
              },
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              ],
            ),
          ),
          ListTile(
            title: const Text('Time'),
            trailing: Text(digestSettings.time ?? '08:00'),
            onTap: () async {
              // Show time picker dialog
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _timeStringToTimeOfDay(digestSettings.time ?? '08:00'),
              );

              if (picked != null) {
                final updatedTime =
                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                final updatedDigest = digestSettings.copyWith(time: updatedTime);
                context.read<NotificationSettingsCubit>().updateDigestSettings(updatedDigest);
              }
            },
          ),
          SwitchListTile(
            title: const Text('Include Low Priority'),
            subtitle: const Text('Include low priority items in digest'),
            value: digestSettings.includeLowPriority,
            onChanged: (value) {
              final updatedDigest = digestSettings.copyWith(includeLowPriority: value);
              context.read<NotificationSettingsCubit>().updateDigestSettings(updatedDigest);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildNotificationTypesSection(BuildContext context, NotificationSettings settings) {
    final preferences = settings.preferences;

    // Default types to show if no preferences are set
    final notificationTypes = [
      'projectUpdates',
      'taskAssignments',
      'reportSubmissions',
      'systemAnnouncements',
      'calendarEvents',
      'workRequests',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Notification Types', style: Theme.of(context).textTheme.titleLarge),
        ),
        ...notificationTypes.map((type) {
          // Create a default preference if none exists
          final preference = preferences[type];
          final isEnabled = preference?.enabled ?? true;

          // Create a default preference for this type if not exists
          final safePreference =
              preference ??
              NotificationTypePreference(
                enabled: true,
                email: settings.emailNotifications,
                push: settings.pushNotifications,
                sms: settings.smsNotifications,
              );

          return ExpansionTile(
            title: Text(_getReadableTypeName(type)),
            leading: Icon(_getIconForType(type), color: isEnabled ? null : Colors.grey),
            children: [
              SwitchListTile(
                title: const Text('Enable'),
                value: isEnabled,
                onChanged: (value) {
                  final updatedPreference = safePreference.copyWith(enabled: value);
                  context.read<NotificationSettingsCubit>().updateTypePreference(type, updatedPreference);
                },
              ),
              if (isEnabled) ...[
                CheckboxListTile(
                  title: const Text('Email'),
                  value: safePreference.email,
                  onChanged: settings.emailNotifications
                      ? (value) {
                          if (value != null) {
                            final updatedPreference = safePreference.copyWith(email: value);
                            context.read<NotificationSettingsCubit>().updateTypePreference(type, updatedPreference);
                          }
                        }
                      : null,
                ),
                CheckboxListTile(
                  title: const Text('Push'),
                  value: safePreference.push,
                  onChanged: settings.pushNotifications
                      ? (value) {
                          if (value != null) {
                            final updatedPreference = safePreference.copyWith(push: value);
                            context.read<NotificationSettingsCubit>().updateTypePreference(type, updatedPreference);
                          }
                        }
                      : null,
                ),
                CheckboxListTile(
                  title: const Text('SMS'),
                  value: safePreference.sms,
                  onChanged: settings.smsNotifications
                      ? (value) {
                          if (value != null) {
                            final updatedPreference = safePreference.copyWith(sms: value);
                            context.read<NotificationSettingsCubit>().updateTypePreference(type, updatedPreference);
                          }
                        }
                      : null,
                ),
              ],
            ],
          );
        }).toList(),
      ],
    );
  }

  String _getReadableTypeName(String type) {
    switch (type) {
      case 'projectUpdates':
        return 'Project Updates';
      case 'taskAssignments':
        return 'Task Assignments';
      case 'reportSubmissions':
        return 'Report Submissions';
      case 'systemAnnouncements':
        return 'System Announcements';
      case 'calendarEvents':
        return 'Calendar Events';
      case 'workRequests':
        return 'Work Requests';
      default:
        return type;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'projectUpdates':
        return Icons.business;
      case 'taskAssignments':
        return Icons.task_alt;
      case 'reportSubmissions':
        return Icons.summarize;
      case 'systemAnnouncements':
        return Icons.announcement;
      case 'calendarEvents':
        return Icons.event;
      case 'workRequests':
        return Icons.work;
      default:
        return Icons.notifications;
    }
  }
}
