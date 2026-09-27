import '../models/player.dart';
import '../services/player_firestore_service.dart';

class PlayerRepository {
  PlayerRepository(this._service);

  final PlayerFirestoreService _service;

  Stream<List<Player>> getPlayers() {
    return _service.getPlayers();
  }


  Stream<List<Player>> getPlayersByParent(String parentId) =>
      _service.getPlayersByParent(parentId);

  Stream<List<Player>> getPlayersByCoach(String coachId) =>
      _service.getPlayersByCoach(coachId);

  Stream<List<Player>> getPlayersByEmail(String email) =>
      _service.getPlayersByEmail(email);

  Future<void> assignCoach({required String playerId, required String coachId}) =>
      _service.assignCoach(playerId: playerId, coachId: coachId);

  Stream<List<Player>> getPlayersByTeam(
    String teamId,
  ) {
    return _service.getPlayersByTeam(teamId);
  }

  Stream<List<Player>> getPlayersByPosition(
    String position,
  ) {
    return _service.getPlayersByPosition(position);
  }

  Future<Player?> getPlayer(String id) {
    return _service.getPlayer(id);
  }

  Future<void> addPlayer(Player player) {
    return _service.addPlayer(player);
  }

  Future<void> updatePlayer(Player player) {
    return _service.updatePlayer(player);
  }

  Future<void> deletePlayer(String id) {
    return _service.deletePlayer(id);
  }

  Future<List<Player>> searchPlayers(
    String keyword,
  ) {
    return _service.searchPlayers(keyword);
  }

  Future<bool> jerseyNumberExists({
    required String teamId,
    required int jerseyNumber,
  }) {
    return _service.jerseyNumberExists(
      teamId: teamId,
      jerseyNumber: jerseyNumber,
    );
  }

  Future<bool> registrationExists(
    String registrationNo,
  ) {
    return _service.registrationExists(
      registrationNo,
    );
  }
}