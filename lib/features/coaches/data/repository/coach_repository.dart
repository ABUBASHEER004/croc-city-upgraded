
import '../models/coach.dart';
import '../services/coach_firestore_service.dart';

class CoachRepository {
  CoachRepository(this._service);

  final CoachFirestoreService _service;

  Stream<List<Coach>> getCoaches() => _service.getCoaches();
  Future<Coach?> getCoach(String id) => _service.getCoach(id);
  Future<void> addCoach(Coach coach) => _service.addCoach(coach);
  Future<void> updateCoach(Coach coach) => _service.updateCoach(coach);
  Future<void> deleteCoach(String id) => _service.deleteCoach(id);
  Future<List<Coach>> searchCoaches(String keyword) =>
      _service.searchCoaches(keyword);
}
