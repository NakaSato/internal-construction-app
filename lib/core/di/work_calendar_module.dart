import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../features/work_calendar/domain/repositories/work_calendar_repository.dart';
import '../../features/work_calendar/infrastructure/repositories/firebase_work_calendar_repository.dart';

@module
abstract class WorkCalendarModule {
  @LazySingleton(as: WorkCalendarRepository)
  FirebaseWorkCalendarRepository workCalendarRepository(
    FirebaseFirestore firestore,
    FirebaseAuth firebaseAuth,
  ) => FirebaseWorkCalendarRepository(firestore: firestore, auth: firebaseAuth);
}
