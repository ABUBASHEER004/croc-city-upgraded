import '../models/team.dart';
import '../services/team_firestore_service.dart';

class TeamRepository {
  TeamRepository(this._service);

  final TeamFirestoreService _service;

  Stream<List<Team>> getTeams() {
    return _service.getTeams();
  }

  Future<void> createTeam(Team team) {
    return _service.createTeam(team);
  }

  Future<void> updateTeam(Team team) {
    return _service.updateTeam(team);
  }

  Future<void> deleteTeam(String id) {
    return _service.deleteTeam(id);
  }

  Future<Team?> getTeam(String id) {
    return _service.getTeam(id);
  }
}