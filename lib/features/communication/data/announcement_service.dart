import 'dart:async';
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

  Stream<List<Announcement>> watchForAudience(String audience) => _announcements
      .where('audienceKeys', arrayContainsAny: [audience, 'Everyone'])
      .snapshots()
      .map((snapshot) {
        final items = snapshot.docs.map((doc) => Announcement.fromMap(doc.id, doc.data())).toList();
        items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        return items.where((a) => a.active).toList();
      });

  Stream<List<Announcement>> watchForUser({
    required String audience,
    String? email,
    String? userId,
  }) {
    final normalizedEmail = email?.trim().toLowerCase() ?? '';
    final normalizedUserId = userId?.trim() ?? '';
    final keys = <String>[];
    if (normalizedEmail.isNotEmpty) keys.add('email:$normalizedEmail');
    if (normalizedUserId.isNotEmpty) keys.add('uid:$normalizedUserId');

    final general = _announcements.where('audienceKeys', arrayContains: 'Everyone').snapshots();
    final targetedStreams = keys.map((key) => _announcements.where('audienceKeys', arrayContains: key).snapshots()).toList();
    final controller = StreamController<List<Announcement>>();
    List<Announcement> generalItems = const [];
    final targetedItems = <String, List<Announcement>>{};

    void emit() {
      final byId = <String, Announcement>{
        for (final item in [...generalItems, ...targetedItems.values.expand((items) => items)]) item.id: item,
      };
      final items = byId.values.where((item) => item.active).toList()
        ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      if (!controller.isClosed) controller.add(items);
    }

    final subscriptions = <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];
    subscriptions.add(general.listen(
      (snapshot) {
        generalItems = snapshot.docs.map((doc) => Announcement.fromMap(doc.id, doc.data())).toList();
        emit();
      },
      onError: controller.addError,
    ));
    for (var index = 0; index < targetedStreams.length; index++) {
      subscriptions.add(targetedStreams[index].listen(
        (snapshot) {
          targetedItems[keys[index]] = snapshot.docs.map((doc) => Announcement.fromMap(doc.id, doc.data())).toList();
          emit();
        },
        onError: controller.addError,
      ));
    }
    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };
    return controller.stream;
  }

  Stream<List<Announcement>> watchSentBy(String uid) => _announcements.where('publishedBy', isEqualTo: uid).snapshots().map((snapshot) {
    final items = snapshot.docs.map((d) => Announcement.fromMap(d.id, d.data())).where((a) => a.active).toList()..sort((a,b)=>b.publishedAt.compareTo(a.publishedAt));
    return items;
  });

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
