import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  AttendanceService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAttendance({String? dateKey}) {
    Query<Map<String, dynamic>> query =
        _firestore.collection('attendance').orderBy('date', descending: true);
    if (dateKey != null && dateKey.isNotEmpty) {
      query = query.where('dateKey', isEqualTo: dateKey);
    }
    return query.snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchPlayerAttendance(String playerId) {
    return _firestore
        .collection('attendance')
        .where('playerId', isEqualTo: playerId)
        .snapshots();
  }

  Future<void> setAttendance({
    required String playerId,
    required String playerName,
    required DateTime date,
    required String status,
    String? coachId,
    String? note,
  }) async {
    final dateKey = _dateKey(date);
    await _firestore.collection('attendance').doc('${dateKey}_$playerId').set({
      'playerId': playerId,
      'playerName': playerName,
      'date': Timestamp.fromDate(date),
      'dateKey': dateKey,
      'status': status,
      'coachId': coachId ?? '',
      'note': note ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setBulkAttendance({
    required List<Map<String, String>> players,
    required DateTime date,
    required String coachId,
    required Map<String, String> statuses,
  }) async {
    final batch = _firestore.batch();
    final dateKey = _dateKey(date);
    final collection = _firestore.collection('attendance');

    for (final player in players) {
      final id = player['id'] ?? '';
      if (id.isEmpty) continue;
      final ref = collection.doc('${dateKey}_$id');
      batch.set(ref, {
        'playerId': id,
        'playerName': player['name'] ?? '',
        'date': Timestamp.fromDate(date),
        'dateKey': dateKey,
        'status': statuses[id] ?? 'Present',
        'coachId': coachId,
        'note': '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
