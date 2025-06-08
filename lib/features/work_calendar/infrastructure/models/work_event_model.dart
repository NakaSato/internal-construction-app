import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/work_event.dart';

part 'work_event_model.freezed.dart';
part 'work_event_model.g.dart';

/// Data model for WorkEvent entity
@freezed
class WorkEventModel with _$WorkEventModel {
  const factory WorkEventModel({
    required String id,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    String? location,
    String? color,
    @Default(false) bool isAllDay,
    @Default(WorkEventType.meeting) WorkEventType eventType,
    @Default([]) List<String> attendees,
  }) = _WorkEventModel;

  factory WorkEventModel.fromJson(Map<String, dynamic> json) =>
      _$WorkEventModelFromJson(json);
}

/// Extension to convert between model and entity
extension WorkEventModelX on WorkEventModel {
  /// Convert model to domain entity
  WorkEvent toEntity() {
    return WorkEvent(
      id: id,
      title: title,
      startTime: startTime,
      endTime: endTime,
      description: description,
      location: location,
      color: color,
      isAllDay: isAllDay,
      eventType: eventType,
      attendees: attendees,
    );
  }
}

/// Extension to convert from entity to model
extension WorkEventX on WorkEvent {
  /// Convert domain entity to model
  WorkEventModel toModel() {
    return WorkEventModel(
      id: id,
      title: title,
      startTime: startTime,
      endTime: endTime,
      description: description,
      location: location,
      color: color,
      isAllDay: isAllDay,
      eventType: eventType,
      attendees: attendees,
    );
  }
}
