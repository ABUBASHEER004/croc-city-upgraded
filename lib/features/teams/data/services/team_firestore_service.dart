import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/team.dart';

class TeamFirestoreService {
  TeamFirestoreService._();

  static final TeamFirestoreService instance =
      TeamFirestoreService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _teams =>
      _firestore.collection("teams");

  Stream<List<Team>> getTeams() {
    return _teams
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((e) { final data = e.data(); data['id'] = e.id; return Team.fromMap(data); })
              .toList(),
        );
  }

  Future<void> createTeam(Team team) async {
    final doc = team.id.isEmpty ? _teams.doc() : _teams.doc(team.id);
    final data = team.copyWith(id: doc.id).toMap();
    await doc.set(data);
  }

  Future<void> updateTeam(Team team) async {
    await _teams.doc(team.id).update(team.toMap());
  }

  Future<void> deleteTeam(String id) async {
    await _teams.doc(id).delete();
  }

  Future<Team?> getTeam(String id) async {
    final doc = await _teams.doc(id).get();

    if (!doc.exists) return null;

    final data = doc.data()!; data['id'] = doc.id; return Team.fromMap(data);
  }
}