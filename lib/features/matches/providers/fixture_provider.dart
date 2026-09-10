import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/fixture_firestore_service.dart';
import '../models/fixture.dart';

class FixtureProvider extends ChangeNotifier {
  FixtureProvider({FixtureFirestoreService? service})
      : _service = service ?? FixtureFirestoreService();

  final FixtureFirestoreService _service;
  StreamSubscription<List<Fixture>>? _subscription;

  List<Fixture> fixtures = [];
  bool loading = false;
  String? error;

  Future<void> loadFixtures() async {
    loading = true;
    error = null;
    notifyListeners();
    await _subscription?.cancel();
    _subscription = _service.watchFixtures().listen(
      (value) {
        fixtures = value;
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

  Future<void> saveFixture(Fixture fixture) => _service.save(fixture);
  Future<void> deleteFixture(String id) => _service.delete(id);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
