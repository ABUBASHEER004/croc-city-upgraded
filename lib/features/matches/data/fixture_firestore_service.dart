import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fixture.dart';

class FixtureFirestoreService {
  FixtureFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('fixtures');

  Stream<List<Fixture>> watchFixtures() => _collection
      .orderBy('date')
      .snapshots()
      .map((s) => s.docs.map((d) => Fixture.fromMap(d.id, d.data())).toList());

  Future<void> save(Fixture fixture) async {
    final doc = fixture.id.isEmpty ? _collection.doc() : _collection.doc(fixture.id);
    await doc.set(fixture.copyWith(id: doc.id).toMap(), SetOptions(merge: true));
  }

  Future<void> delete(String id) => _collection.doc(id).delete();
}
