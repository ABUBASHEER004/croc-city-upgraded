import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/training_session.dart';

class TrainingService {
  TrainingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _firestore.collection('training_sessions');

  Stream<List<TrainingSession>> watchSessions() => _sessions
      .orderBy('scheduledAt')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TrainingSession.fromMap(doc.id, doc.data()))
          .toList());

  Future<void> save(TrainingSession session) async {
    final doc = session.id.isEmpty ? _sessions.doc() : _sessions.doc(session.id);
    await doc.set(session.copyWith(id: doc.id).toMap(), SetOptions(merge: true));
  }

  Future<void> delete(String id) => _sessions.doc(id).delete();
}
