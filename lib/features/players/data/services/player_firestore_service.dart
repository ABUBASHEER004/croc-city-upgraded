import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/player.dart';

class PlayerFirestoreService {
  PlayerFirestoreService._();

  static final PlayerFirestoreService instance =
      PlayerFirestoreService._();

  final CollectionReference<Map<String, dynamic>> _players =
      FirebaseFirestore.instance.collection('players');

  /// Create Player
  Future<void> addPlayer(Player player) async {
    await _players.doc(player.id).set(player.toMap());
  }

  /// Update Player
  Future<void> updatePlayer(Player player) async {
    await _players.doc(player.id).update(player.toMap());
  }

  /// Delete Player
  Future<void> deletePlayer(String id) async {
    await _players.doc(id).delete();
  }

  /// Get One Player
  Future<Player?> getPlayer(String id) async {
    final doc = await _players.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return Player.fromMap(doc.data()!);
  }

  /// Stream All Players
  Stream<List<Player>> getPlayers() {
    return _players
        .orderBy('firstName')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Player.fromMap(doc.data()),
              )
              .toList(),
        );
  }


  /// Live players linked to a parent account.
  Stream<List<Player>> getPlayersByParent(String parentId) {
    return _players
        .where('parentId', isEqualTo: parentId)
        .orderBy('firstName')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Player.fromMap(data);
            }).toList());
  }

  /// Live players assigned to a coach.
  Stream<List<Player>> getPlayersByCoach(String coachId) {
    return _players
        .where('coachId', isEqualTo: coachId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Player.fromMap(data);
            }).toList());
  }

  /// Live player profile linked to the signed-in player's email.
  Stream<List<Player>> getPlayersByEmail(String email) {
    return _players
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Player.fromMap(data);
            }).toList());
  }

  Future<void> assignCoach({required String playerId, required String coachId}) {
    return _players.doc(playerId).update({
      'coachId': coachId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Players by Team
  Stream<List<Player>> getPlayersByTeam(
    String teamId,
  ) {
    return _players
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Player.fromMap(doc.data()),
              )
              .toList(),
        );
  }

  /// Players by Position
  Stream<List<Player>> getPlayersByPosition(
    String position,
  ) {
    return _players
        .where('position', isEqualTo: position)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Player.fromMap(doc.data()),
              )
              .toList(),
        );
  }

  /// Search Player
  Future<List<Player>> searchPlayers(
    String keyword,
  ) async {
    final snapshot = await _players.get();

    final players = snapshot.docs
        .map(
          (doc) => Player.fromMap(doc.data()),
        )
        .where(
          (player) =>
              player.fullName
                  .toLowerCase()
                  .contains(
                    keyword.toLowerCase(),
                  ) ||
              player.registrationNo
                  .toLowerCase()
                  .contains(
                    keyword.toLowerCase(),
                  ),
        )
        .toList();

    return players;
  }

  /// Jersey Number Check
  Future<bool> jerseyNumberExists({
    required String teamId,
    required int jerseyNumber,
  }) async {
    final snapshot = await _players
        .where('teamId', isEqualTo: teamId)
        .where(
          'jerseyNumber',
          isEqualTo: jerseyNumber,
        )
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Registration Number Check
  Future<bool> registrationExists(
    String registrationNo,
  ) async {
    final snapshot = await _players
        .where(
          'registrationNo',
          isEqualTo: registrationNo,
        )
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}