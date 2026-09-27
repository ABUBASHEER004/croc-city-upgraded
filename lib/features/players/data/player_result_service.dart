import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerResultService {
  PlayerResultService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Map<String, dynamic>>> watchResults(String playerId, {String? parentId}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('player_results')
        .where('playerId', isEqualTo: playerId)
        .where('published', isEqualTo: true);
    if (parentId != null && parentId.trim().isNotEmpty) {
      query = query.where('parentId', isEqualTo: parentId);
    }
    return query
        .snapshots()
        .map((snapshot) {
      final results = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
      results.sort((a, b) => _date(b['createdAt']).compareTo(_date(a['createdAt'])));
      return results;
    });
  }

  Future<String> saveResult({
    required String playerId,
    required String parentId,
    required String playerName,
    required String term,
    required String session,
    required List<Map<String, dynamic>> assessments,
    String coachComment = '',
  }) async {
    final ref = await _firestore.collection('player_results').add({
      'playerId': playerId,
      'parentId': parentId,
      'playerName': playerName,
      'term': term,
      'session': session,
      'assessments': assessments,
      'coachComment': coachComment,
      'published': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> publishResult({
    required String resultId,
    required String pdfUrl,
  }) {
    return _firestore.collection('player_results').doc(resultId).update({
      'pdfUrl': pdfUrl,
      'published': true,
      'publishedAt': FieldValue.serverTimestamp(),
    });
  }

  DateTime _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}
