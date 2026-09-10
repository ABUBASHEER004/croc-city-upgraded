import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/announcement.dart';

class AnnouncementService {
  AnnouncementService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _announcements =>
      _firestore.collection('announcements');

  Stream<List<Announcement>> watchAnnouncements() => _announcements
      .orderBy('publishedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Announcement.fromMap(doc.id, doc.data()))
          .toList());

  Future<void> save(Announcement announcement) async {
    final doc = announcement.id.isEmpty
        ? _announcements.doc()
        : _announcements.doc(announcement.id);
    await doc.set(
      announcement.copyWith(id: doc.id).toMap(),
      SetOptions(merge: true),
    );
  }

  Future<void> delete(String id) => _announcements.doc(id).delete();
}
