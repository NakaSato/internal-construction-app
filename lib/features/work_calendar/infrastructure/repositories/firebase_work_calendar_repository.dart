import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/work_event.dart';
import '../../domain/repositories/work_calendar_repository.dart';
import '../models/work_event_model.dart';

/// Firebase implementation of WorkCalendarRepository
class FirebaseWorkCalendarRepository implements WorkCalendarRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseWorkCalendarRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  String get _userId => _auth.currentUser?.uid ?? '';
  CollectionReference get _eventsCollection =>
      _firestore.collection('users').doc(_userId).collection('work_events');

  @override
  Future<List<WorkEvent>> getEventsInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final query = await _eventsCollection
          .where('startTime', isGreaterThanOrEqualTo: startDate)
          .where('startTime', isLessThanOrEqualTo: endDate)
          .orderBy('startTime')
          .get();

      return query.docs
          .map(
            (doc) => WorkEventModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }).toEntity(),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch events for date range: $e');
    }
  }

  @override
  Future<List<WorkEvent>> getEventsForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final query = await _eventsCollection
          .where('startTime', isGreaterThanOrEqualTo: startOfDay)
          .where('startTime', isLessThan: endOfDay)
          .orderBy('startTime')
          .get();

      return query.docs
          .map(
            (doc) => WorkEventModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }).toEntity(),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch events for date: $e');
    }
  }

  @override
  Future<WorkEvent> createEvent(WorkEvent event) async {
    try {
      final model = event.toModel();
      final doc = await _eventsCollection.add({
        ...model.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return event.copyWith(id: doc.id);
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  @override
  Future<WorkEvent> updateEvent(WorkEvent event) async {
    try {
      if (event.id.isEmpty) {
        throw Exception('Event ID cannot be empty for update');
      }

      final model = event.toModel();
      await _eventsCollection.doc(event.id).update({
        ...model.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return event;
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      if (eventId.isEmpty) {
        throw Exception('Event ID cannot be empty');
      }

      await _eventsCollection.doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  @override
  Future<WorkEvent?> getEvent(String eventId) async {
    try {
      if (eventId.isEmpty) {
        return null;
      }

      final doc = await _eventsCollection.doc(eventId).get();
      if (!doc.exists) {
        return null;
      }

      return WorkEventModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toEntity();
    } catch (e) {
      throw Exception('Failed to fetch event by ID: $e');
    }
  }

  @override
  Future<List<WorkEvent>> getEventsByType(WorkEventType eventType) async {
    try {
      final query = await _eventsCollection
          .where('eventType', isEqualTo: eventType.name)
          .orderBy('startTime')
          .get();

      return query.docs
          .map(
            (doc) => WorkEventModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }).toEntity(),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch events by type: $e');
    }
  }

  @override
  Future<List<WorkEvent>> searchEvents(String query) async {
    try {
      // Firestore doesn't support full-text search, so we'll do client-side filtering
      final snapshot = await _eventsCollection.get();

      return snapshot.docs
          .map(
            (doc) => WorkEventModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }).toEntity(),
          )
          .where(
            (event) =>
                event.title.toLowerCase().contains(query.toLowerCase()) ||
                (event.description?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false) ||
                (event.location?.toLowerCase().contains(query.toLowerCase()) ??
                    false),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }

  @override
  Future<List<WorkEvent>> getUpcomingEvents() async {
    try {
      final now = DateTime.now();
      final oneWeekFromNow = now.add(const Duration(days: 7));

      final query = await _eventsCollection
          .where('startTime', isGreaterThan: now)
          .where('startTime', isLessThanOrEqualTo: oneWeekFromNow)
          .orderBy('startTime')
          .get();

      return query.docs
          .map(
            (doc) => WorkEventModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }).toEntity(),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming events: $e');
    }
  }

  @override
  Future<List<WorkEvent>> getTodaysEvents() async {
    try {
      final today = DateTime.now();
      return await getEventsForDate(today);
    } catch (e) {
      throw Exception('Failed to fetch today\'s events: $e');
    }
  }

  @override
  Future<List<WorkEvent>> getWeekEvents(DateTime weekStart) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 7));
      return await getEventsInRange(weekStart, weekEnd);
    } catch (e) {
      throw Exception('Failed to fetch week events: $e');
    }
  }

  @override
  Future<List<WorkEvent>> getMonthEvents(DateTime monthStart) async {
    try {
      final monthEnd = DateTime(
        monthStart.year,
        monthStart.month + 1,
        1,
      ).subtract(const Duration(days: 1));
      return await getEventsInRange(monthStart, monthEnd);
    } catch (e) {
      throw Exception('Failed to fetch month events: $e');
    }
  }

  @override
  Future<List<WorkEvent>> getConflictingEvents(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final query = await _eventsCollection
          .where('startTime', isLessThan: endTime)
          .where('endTime', isGreaterThan: startTime)
          .get();

      return query.docs
          .map(
            (doc) => WorkEventModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }).toEntity(),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to check for conflicting events: $e');
    }
  }

  @override
  Future<String> exportEvents(List<WorkEvent> events) async {
    try {
      // Simple iCal format export
      final buffer = StringBuffer();
      buffer.writeln('BEGIN:VCALENDAR');
      buffer.writeln('VERSION:2.0');
      buffer.writeln('PRODID:-//Flutter Calendar App//EN');
      buffer.writeln('CALSCALE:GREGORIAN');

      for (final event in events) {
        buffer.writeln('BEGIN:VEVENT');
        buffer.writeln('UID:${event.id}');
        buffer.writeln('DTSTART:${_formatDateTime(event.startTime)}');
        buffer.writeln('DTEND:${_formatDateTime(event.endTime)}');
        buffer.writeln('SUMMARY:${event.title}');
        if (event.description != null) {
          buffer.writeln('DESCRIPTION:${event.description}');
        }
        if (event.location != null) {
          buffer.writeln('LOCATION:${event.location}');
        }
        buffer.writeln('END:VEVENT');
      }

      buffer.writeln('END:VCALENDAR');
      return buffer.toString();
    } catch (e) {
      throw Exception('Failed to export events: $e');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return dateTime
        .toUtc()
        .toIso8601String()
        .replaceAll(RegExp(r'[-:]'), '')
        .replaceAll('.000Z', 'Z');
  }
}
