import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/player.dart';
import '../../data/repository/player_repository.dart';

class PlayerProvider extends ChangeNotifier {
  PlayerProvider(this._repository);

  final PlayerRepository _repository;

  List<Player> _players = [];

  bool _loading = false;
  String? _error;

  StreamSubscription<List<Player>>? _subscription;

  List<Player> get players => List.unmodifiable(_players);

  bool get loading => _loading;

  String? get error => _error;

  /// Listen to all academy players.
  void startListening() {
    _loading = true;
    _error = null;
    notifyListeners();

    _subscription?.cancel();

    _subscription = _repository.getPlayers().listen(
      (data) {
        _players = data;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _loading = false;
        notifyListeners();
      },
    );
  }


  void listenToParent(String parentId) {
    _loading = true;
    _error = null;
    notifyListeners();
    _subscription?.cancel();
    _subscription = _repository.getPlayersByParent(parentId).listen(
      (data) {
        _players = data;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _loading = false;
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  void listenToCoach(String coachId) {
    _loading = true;
    _error = null;
    notifyListeners();
    _subscription?.cancel();
    _subscription = _repository.getPlayersByCoach(coachId).listen(
      (data) {
        _players = data;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _loading = false;
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  void listenToPlayerByEmail(String email) {
    _loading = true;
    _error = null;
    notifyListeners();
    _subscription?.cancel();
    _subscription = _repository.getPlayersByEmail(email).listen(
      (data) {
        _players = data;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _loading = false;
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> assignCoach({required String playerId, required String coachId}) =>
      _repository.assignCoach(playerId: playerId, coachId: coachId);

  /// Listen only to players belonging to a specific team.
  void listenToTeam(String teamId) {
    _loading = true;
    _error = null;
    notifyListeners();

    _subscription?.cancel();

    _subscription = _repository
        .getPlayersByTeam(teamId)
        .listen(
      (data) {
        _players = data;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addPlayer(Player player) async {
    try {
      _error = null;
      await _repository.addPlayer(player);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePlayer(Player player) async {
    try {
      _error = null;
      await _repository.updatePlayer(player);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePlayer(String id) async {
    try {
      _error = null;
      await _repository.deletePlayer(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Player>> search(String query) {
    return _repository.searchPlayers(query);
  }

  Future<Player?> getPlayer(String id) {
    return _repository.getPlayer(id);
  }

  Future<bool> jerseyNumberExists({
    required String teamId,
    required int jerseyNumber,
  }) {
    return _repository.jerseyNumberExists(
      teamId: teamId,
      jerseyNumber: jerseyNumber,
    );
  }

  Future<bool> registrationExists(
    String registrationNo,
  ) {
    return _repository.registrationExists(
      registrationNo,
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}