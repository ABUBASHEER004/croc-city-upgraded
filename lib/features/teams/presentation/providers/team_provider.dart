import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/team.dart';
import '../../data/repository/team_repository.dart';

class TeamProvider extends ChangeNotifier {
  TeamProvider(this._repository);

  final TeamRepository _repository;

  StreamSubscription<List<Team>>? _teamsSubscription;

  bool _loading = false;
  String? _error;
  List<Team> _teams = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Team> get teams => List.unmodifiable(_teams);

  Future<void> listenToTeams() async {
    _loading = true;
    _error = null;
    notifyListeners();

    await _teamsSubscription?.cancel();

    _teamsSubscription = _repository.getTeams().listen(
      (teams) {
        _teams = teams;
        _loading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addTeam(Team team) async {
    try {
      await _repository.createTeam(team);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTeam(Team team) async {
    try {
      await _repository.updateTeam(team);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTeam(String id) async {
    try {
      await _repository.deleteTeam(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Team? getTeamById(String id) {
    try {
      return _teams.firstWhere((team) => team.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _teamsSubscription?.cancel();
    super.dispose();
  }
}