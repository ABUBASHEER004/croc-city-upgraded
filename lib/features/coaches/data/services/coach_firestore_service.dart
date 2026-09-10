
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/coach.dart';

class CoachFirestoreService {
  CoachFirestoreService._();

  static final CoachFirestoreService instance = CoachFirestoreService._();

  final CollectionReference<Map<String, dynamic>> _coaches =
      FirebaseFirestore.instance.collection('coaches');

  Stream<List<Coach>> getCoaches() {
    return _coaches
        .orderBy('firstName')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Coach.fromMap(data);
            }).toList());
  }

  Future<Coach?> getCoach(String id) async {
    final doc = await _coaches.doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    data['id'] = doc.id;
    return Coach.fromMap(data);
  }

  Future<void> addCoach(Coach coach) async {
    final doc = coach.id.isEmpty ? _coaches.doc() : _coaches.doc(coach.id);
    await doc.set(coach.copyWith(id: doc.id).toMap());
  }

  Future<void> updateCoach(Coach coach) async {
    await _coaches.doc(coach.id).update(coach.toMap());
  }

  Future<void> deleteCoach(String id) async {
    await _coaches.doc(id).delete();
  }

  Future<List<Coach>> searchCoaches(String keyword) async {
    final q = keyword.trim().toLowerCase();
    final snapshot = await _coaches.get();
    return snapshot.docs.map((doc) {
      final data = doc.data()..['id'] = doc.id;
      return Coach.fromMap(data);
    }).where((coach) {
      return q.isEmpty ||
          coach.fullName.toLowerCase().contains(q) ||
          coach.email.toLowerCase().contains(q) ||
          coach.specialty.toLowerCase().contains(q);
    }).toList();
  }
}
