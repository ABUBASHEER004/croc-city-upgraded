
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/coach.dart';
import '../../data/repository/coach_repository.dart';

class CoachProvider extends ChangeNotifier {
  CoachProvider(this._repository);

  final CoachRepository _repository;
  StreamSubscription<List<Coach>>? _subscription;

  List<Coach> _coaches = [];
  bool loading = false;
  String? error;

  List<Coach> get coaches => List.unmodifiable(_coaches);
  int get activeCount => _coaches.where((coach) => coach.active).length;

  void listenToCoaches() {
    loading = true;
    error = null;
    notifyListeners();
    _subscription?.cancel();

    _subscription = _repository.getCoaches().listen(
      (data) {
        _coaches = data;
        loading = false;
        error = null;
        notifyListeners();
      },
      onError: (Object e) {
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
        notifyListeners();
      },
    );
  }

  Future<void> addCoach(Coach coach) async {
    error = null;
    notifyListeners();
    try {
      await _repository.addCoach(coach);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCoach(Coach coach) async {
    error = null;
    notifyListeners();
    try {
      await _repository.updateCoach(coach);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCoach(String id) async {
    error = null;
    notifyListeners();
    try {
      await _repository.deleteCoach(id);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<Coach?> getCoach(String id) => _repository.getCoach(id);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
