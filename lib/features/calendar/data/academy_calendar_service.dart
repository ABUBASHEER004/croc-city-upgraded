import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/academy_calendar_event.dart';

class AcademyCalendarService {
  AcademyCalendarService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _events => _firestore.collection('academy_calendar');

  Stream<List<AcademyCalendarEvent>> watchPublished() => _events.where('published', isEqualTo: true).snapshots().map(_sort);
  Stream<List<AcademyCalendarEvent>> watchAllForAdmin() => _events.snapshots().map(_sort);
  List<AcademyCalendarEvent> _sort(QuerySnapshot<Map<String, dynamic>> s) {
    final list = s.docs.map(AcademyCalendarEvent.fromDoc).toList()..sort((a,b) => a.startAt.compareTo(b.startAt));
    return list;
  }

  Future<void> create({required String title, required String description, required String category, required DateTime startAt, required DateTime endAt, required String venue, required bool published, required String createdBy, required String createdByName}) => _events.add({
    'title': title.trim(), 'description': description.trim(), 'category': category,
    'startAt': Timestamp.fromDate(startAt), 'endAt': Timestamp.fromDate(endAt), 'venue': venue.trim(),
    'published': published, 'createdBy': createdBy, 'createdByName': createdByName, 'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> update({required String id, required String title, required String description, required String category, required DateTime startAt, required DateTime endAt, required String venue, required bool published}) => _events.doc(id).update({
    'title': title.trim(), 'description': description.trim(), 'category': category,
    'startAt': Timestamp.fromDate(startAt), 'endAt': Timestamp.fromDate(endAt), 'venue': venue.trim(),
    'published': published, 'updatedAt': FieldValue.serverTimestamp(),
  });
  Future<void> setPublished(String id, bool value) => _events.doc(id).update({'published': value, 'updatedAt': FieldValue.serverTimestamp()});
  Future<void> delete(String id) => _events.doc(id).delete();
}
