import '../models/fixture.dart';
import 'fixture_firestore_service.dart';

class MatchRepository {
  MatchRepository(this.service);
  final FixtureFirestoreService service;

  Stream<List<Fixture>> watchFixtures() => service.watchFixtures();
  Future<void> saveFixture(Fixture fixture) => service.save(fixture);
  Future<void> deleteFixture(String id) => service.delete(id);
}
