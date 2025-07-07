import 'package:equatable/equatable.dart';

/// Represents user notification settings and preferences
class NotificationSettings extends Equatable {
  const NotificationSettings({
    required this.userId,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.inAppNotifications = true,
    this.preferences = const {},
    this.quietHours,
    this.digestSettings,
    this.mobileSettings,
  });

  /// The user ID these settings belong to
  final String userId;
  
  /// Whether email notifications are enabled
  final bool emailNotifications;
  
  /// Whether push notifications are enabled
  final bool pushNotifications;
  
  /// Whether SMS notifications are enabled
  final bool smsNotifications;
  
  /// Whether in-app notifications are enabled
  final bool inAppNotifications;
  
  /// Detailed preferences for different notification types
  final Map<String, NotificationTypePreference> preferences;
  
  /// Settings for quiet hours (do not disturb)
  final QuietHoursSettings? quietHours;
  
  /// Settings for notification digests
  final DigestSettings? digestSettings;
  
  /// Settings specific to mobile devices
  final MobileNotificationSettings? mobileSettings;

  /// Creates a copy with specified fields replaced
  NotificationSettings copyWith({
    String? userId,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? inAppNotifications,
    Map<String, NotificationTypePreference>? preferences,
    QuietHoursSettings? quietHours,
    DigestSettings? digestSettings,
    MobileNotificationSettings? mobileSettings,
  }) {
    return NotificationSettings(
      userId: userId ?? this.userId,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      inAppNotifications: inAppNotifications ?? this.inAppNotifications,
      preferences: preferences ?? this.preferences,
      quietHours: quietHours ?? this.quietHours,
      digestSettings: digestSettings ?? this.digestSettings,
      mobileSettings: mobileSettings ?? this.mobileSettings,
    );
  }

  /// Creates notification settings from JSON data
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> preferencesJson = json['preferences'] as Map<String, dynamic>? ?? {};
    final Map<String, NotificationTypePreference> preferences = {};
    
    preferencesJson.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        preferences[key] = NotificationTypePreference.fromJson(value);
      }
    });
    
    return NotificationSettings(
      userId: json['userId'] as String,
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      smsNotifications: json['smsNotifications'] as bool? ?? false,
      inAppNotifications: json['inAppNotifications'] as bool? ?? true,
      preferences: preferences,
      quietHours: json['quietHours'] != null
          ? QuietHoursSettings.fromJson(json['quietHours'] as Map<String, dynamic>)
          : null,
      digestSettings: json['digestSettings'] != null
          ? DigestSettings.fromJson(json['digestSettings'] as Map<String, dynamic>)
          : null,
      mobileSettings: json['mobileSettings'] != null
          ? MobileNotificationSettings.fromJson(json['mobileSettings'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts the settings to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> preferencesJson = {};
    preferences.forEach((key, value) {
      preferencesJson[key] = value.toJson();
    });
    
    return {
      'userId': userId,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'smsNotifications': smsNotifications,
      'inAppNotifications': inAppNotifications,
      'preferences': preferencesJson,
      if (quietHours != null) 'quietHours': quietHours!.toJson(),
      if (digestSettings != null) 'digestSettings': digestSettings!.toJson(),
      if (mobileSettings != null) 'mobileSettings': mobileSettings!.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    userId,
    emailNotifications,
    pushNotifications,
    smsNotifications,
    inAppNotifications,
    preferences,
    quietHours,
    digestSettings,
    mobileSettings,
  ];
}

/// Preferences for a specific notification type
class NotificationTypePreference extends Equatable {
  const NotificationTypePreference({
    this.enabled = true,
    this.email = true,
    this.push = true,
    this.sms = false,
    this.priorityFilter,
    this.additionalSettings = const {},
  });

  /// Whether notifications of this type are enabled
  final bool enabled;
  
  /// Whether email notifications are enabled for this type
  final bool email;
  
  /// Whether push notifications are enabled for this type
  final bool push;
  
  /// Whether SMS notifications are enabled for this type
  final bool sms;
  
  /// Minimum priority to receive notifications of this type
  final String? priorityFilter;
  
  /// Additional settings specific to this notification type
  final Map<String, dynamic> additionalSettings;

  /// Creates a copy with specified fields replaced
  NotificationTypePreference copyWith({
    bool? enabled,
    bool? email,
    bool? push,
    bool? sms,
    String? priorityFilter,
    Map<String, dynamic>? additionalSettings,
  }) {
    return NotificationTypePreference(
      enabled: enabled ?? this.enabled,
      email: email ?? this.email,
      push: push ?? this.push,
      sms: sms ?? this.sms,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      additionalSettings: additionalSettings ?? this.additionalSettings,
    );
  }

  /// Creates a preference from JSON data
  factory NotificationTypePreference.fromJson(Map<String, dynamic> json) {
    final additionalSettings = Map<String, dynamic>.from(json);
    // Remove known fields
    additionalSettings.remove('enabled');
    additionalSettings.remove('email');
    additionalSettings.remove('push');
    additionalSettings.remove('sms');
    additionalSettings.remove('priorityFilter');
    
    return NotificationTypePreference(
      enabled: json['enabled'] as bool? ?? true,
      email: json['email'] as bool? ?? true,
      push: json['push'] as bool? ?? true,
      sms: json['sms'] as bool? ?? false,
      priorityFilter: json['priorityFilter'] as String?,
      additionalSettings: additionalSettings,
    );
  }

  /// Converts the preference to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'enabled': enabled,
      'email': email,
      'push': push,
      'sms': sms,
    };
    
    if (priorityFilter != null) {
      json['priorityFilter'] = priorityFilter;
    }
    
    // Add all additional settings
    json.addAll(additionalSettings);
    
    return json;
  }

  @override
  List<Object?> get props => [
    enabled,
    email,
    push,
    sms,
    priorityFilter,
    additionalSettings,
  ];
}

/// Settings for quiet hours (do not disturb periods)
class QuietHoursSettings extends Equatable {
  const QuietHoursSettings({
    this.enabled = false,
    required this.startTime,
    required this.endTime,
    this.timezone,
    this.allowCritical = true,
    this.weekendsOnly = false,
  });

  /// Whether quiet hours are enabled
  final bool enabled;
  
  /// Start time of quiet hours (format: HH:MM)
  final String startTime;
  
  /// End time of quiet hours (format: HH:MM)
  final String endTime;
  
  /// Timezone for quiet hours
  final String? timezone;
  
  /// Whether critical notifications are allowed during quiet hours
  final bool allowCritical;
  
  /// Whether quiet hours only apply on weekends
  final bool weekendsOnly;

  /// Creates a copy with specified fields replaced
  QuietHoursSettings copyWith({
    bool? enabled,
    String? startTime,
    String? endTime,
    String? timezone,
    bool? allowCritical,
    bool? weekendsOnly,
  }) {
    return QuietHoursSettings(
      enabled: enabled ?? this.enabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timezone: timezone ?? this.timezone,
      allowCritical: allowCritical ?? this.allowCritical,
      weekendsOnly: weekendsOnly ?? this.weekendsOnly,
    );
  }

  /// Creates quiet hours settings from JSON data
  factory QuietHoursSettings.fromJson(Map<String, dynamic> json) {
    return QuietHoursSettings(
      enabled: json['enabled'] as bool? ?? false,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      timezone: json['timezone'] as String?,
      allowCritical: json['allowCritical'] as bool? ?? true,
      weekendsOnly: json['weekendsOnly'] as bool? ?? false,
    );
  }

  /// Converts the settings to JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'startTime': startTime,
      'endTime': endTime,
      if (timezone != null) 'timezone': timezone,
      'allowCritical': allowCritical,
      'weekendsOnly': weekendsOnly,
    };
  }

  @override
  List<Object?> get props => [
    enabled,
    startTime,
    endTime,
    timezone,
    allowCritical,
    weekendsOnly,
  ];
}

/// Settings for notification digests
class DigestSettings extends Equatable {
  const DigestSettings({
    this.enabled = false,
    required this.frequency,
    this.time,
    this.day,
    this.timezone,
    this.includeLowPriority = false,
    this.maxItems,
  });

  /// Whether digest mode is enabled
  final bool enabled;
  
  /// Frequency of digests (daily, weekly)
  final String frequency;
  
  /// Time of day for the digest (format: HH:MM)
  final String? time;
  
  /// Day of week for weekly digests
  final String? day;
  
  /// Timezone for digest delivery
  final String? timezone;
  
  /// Whether to include low priority notifications in digests
  final bool includeLowPriority;
  
  /// Maximum number of notifications in a digest
  final int? maxItems;

  /// Creates a copy with specified fields replaced
  DigestSettings copyWith({
    bool? enabled,
    String? frequency,
    String? time,
    String? day,
    String? timezone,
    bool? includeLowPriority,
    int? maxItems,
  }) {
    return DigestSettings(
      enabled: enabled ?? this.enabled,
      frequency: frequency ?? this.frequency,
      time: time ?? this.time,
      day: day ?? this.day,
      timezone: timezone ?? this.timezone,
      includeLowPriority: includeLowPriority ?? this.includeLowPriority,
      maxItems: maxItems ?? this.maxItems,
    );
  }

  /// Creates digest settings from JSON data
  factory DigestSettings.fromJson(Map<String, dynamic> json) {
    return DigestSettings(
      enabled: json['enabled'] as bool? ?? false,
      frequency: json['frequency'] as String,
      time: json['time'] as String?,
      day: json['day'] as String?,
      timezone: json['timezone'] as String?,
      includeLowPriority: json['includeLowPriority'] as bool? ?? false,
      maxItems: json['maxItems'] as int?,
    );
  }

  /// Converts the settings to JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'frequency': frequency,
      if (time != null) 'time': time,
      if (day != null) 'day': day,
      if (timezone != null) 'timezone': timezone,
      'includeLowPriority': includeLowPriority,
      if (maxItems != null) 'maxItems': maxItems,
    };
  }

  @override
  List<Object?> get props => [
    enabled,
    frequency,
    time,
    day,
    timezone,
    includeLowPriority,
    maxItems,
  ];
}

/// Settings specific to mobile notifications
class MobileNotificationSettings extends Equatable {
  const MobileNotificationSettings({
    this.badgeCount = true,
    this.sounds = true,
    this.vibration = true,
    this.ledIndicator = true,
    this.lockScreen = true,
    this.bannerStyle = 'persistent',
  });

  /// Whether to show badge counts on app icon
  final bool badgeCount;
  
  /// Whether to play sounds for notifications
  final bool sounds;
  
  /// Whether to vibrate for notifications
  final bool vibration;
  
  /// Whether to use LED indicator for notifications (Android)
  final bool ledIndicator;
  
  /// Whether to show notifications on lock screen
  final bool lockScreen;
  
  /// Banner style for notifications (persistent, temporary)
  final String bannerStyle;

  /// Creates a copy with specified fields replaced
  MobileNotificationSettings copyWith({
    bool? badgeCount,
    bool? sounds,
    bool? vibration,
    bool? ledIndicator,
    bool? lockScreen,
    String? bannerStyle,
  }) {
    return MobileNotificationSettings(
      badgeCount: badgeCount ?? this.badgeCount,
      sounds: sounds ?? this.sounds,
      vibration: vibration ?? this.vibration,
      ledIndicator: ledIndicator ?? this.ledIndicator,
      lockScreen: lockScreen ?? this.lockScreen,
      bannerStyle: bannerStyle ?? this.bannerStyle,
    );
  }

  /// Creates mobile settings from JSON data
  factory MobileNotificationSettings.fromJson(Map<String, dynamic> json) {
    return MobileNotificationSettings(
      badgeCount: json['badgeCount'] as bool? ?? true,
      sounds: json['sounds'] as bool? ?? true,
      vibration: json['vibration'] as bool? ?? true,
      ledIndicator: json['ledIndicator'] as bool? ?? true,
      lockScreen: json['lockScreen'] as bool? ?? true,
      bannerStyle: json['bannerStyle'] as String? ?? 'persistent',
    );
  }

  /// Converts the settings to JSON
  Map<String, dynamic> toJson() {
    return {
      'badgeCount': badgeCount,
      'sounds': sounds,
      'vibration': vibration,
      'ledIndicator': ledIndicator,
      'lockScreen': lockScreen,
      'bannerStyle': bannerStyle,
    };
  }

  @override
  List<Object> get props => [
    badgeCount,
    sounds,
    vibration,
    ledIndicator,
    lockScreen,
    bannerStyle,
  ];
}
