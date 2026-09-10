import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/player.dart';

class PlayerFirestoreService {
  PlayerFirestoreService._();

  static final PlayerFirestoreService instance =
      PlayerFirestoreService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      get _players => _firestore.collection('players');

  // ============================================================
  // CREATE
  // ============================================================

  Future<void> addPlayer(Player player) async {
    final doc = player.id.isEmpty
        ? _players.doc()
        : _players.doc(player.id);

    final playerWithId = player.copyWith(
      id: doc.id,
      createdAt: player.createdAt,
    );

    await doc.set(playerWithId.toMap());
  }

  // ============================================================
  // READ ALL
  // ============================================================

  Stream<List<Player>> getPlayers() {
    return _players
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) {
                  final data = doc.data();

                  // Make sure the Firestore document ID
                  // is available as the Player ID.
                  data['id'] = doc.id;

                  return Player.fromMap(data);
                },
              )
              .toList(),
        );
  }

  // ============================================================
  // READ PLAYERS BY TEAM
  // ============================================================

  Stream<List<Player>> getPlayersByTeam(
    String teamId,
  ) {
    return _players
        .where('teamId', isEqualTo: teamId)
        .orderBy('jerseyNumber')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) {
                  final data = doc.data();
                  data['id'] = doc.id;

                  return Player.fromMap(data);
                },
              )
              .toList(),
        );
  }

  // ============================================================
  // READ PLAYERS BY POSITION
  // ============================================================

  Stream<List<Player>> getPlayersByPosition(
    String position,
  ) {
    return _players
        .where('position', isEqualTo: position)
        .orderBy('jerseyNumber')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) {
                  final data = doc.data();
                  data['id'] = doc.id;

                  return Player.fromMap(data);
                },
              )
              .toList(),
        );
  }

  // ============================================================
  // READ ONE
  // ============================================================

  Future<Player?> getPlayer(String id) async {
    final doc = await _players.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;
    data['id'] = doc.id;

    return Player.fromMap(data);
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<void> updatePlayer(Player player) async {
    if (player.id.isEmpty) {
      throw Exception(
        'Cannot update player without an ID.',
      );
    }

    await _players
        .doc(player.id)
        .update(player.toMap());
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deletePlayer(String id) async {
    if (id.isEmpty) {
      throw Exception(
        'Cannot delete player without an ID.',
      );
    }

    await _players.doc(id).delete();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<List<Player>> searchPlayers(
    String query,
  ) async {
    final snapshot = await _players.get();

    final searchQuery = query.trim().toLowerCase();

    if (searchQuery.isEmpty) {
      return snapshot.docs
          .map(
            (doc) {
              final data = doc.data();
              data['id'] = doc.id;

              return Player.fromMap(data);
            },
          )
          .toList();
    }

    return snapshot.docs
        .map(
          (doc) {
            final data = doc.data();
            data['id'] = doc.id;

            return Player.fromMap(data);
          },
        )
        .where(
          (player) {
            return player.fullName
                    .toLowerCase()
                    .contains(searchQuery) ||
                player.registrationNo
                    .toLowerCase()
                    .contains(searchQuery) ||
                player.position
                    .toLowerCase()
                    .contains(searchQuery);
          },
        )
        .toList();
  }

  // ============================================================
  // CHECK JERSEY NUMBER
  // ============================================================

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

  // ============================================================
  // CHECK REGISTRATION NUMBER
  // ============================================================

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