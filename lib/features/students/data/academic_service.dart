import 'package:cloud_firestore/cloud_firestore.dart';

class AcademicService {
  AcademicService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _assignments => _db.collection('assignments');
  CollectionReference<Map<String, dynamic>> get _attendance => _db.collection('student_attendance');

  Stream<List<Map<String, dynamic>>> watchAssignmentsForStudent(String studentId, {String? userId}) =>
      _assignments.where(userId != null && userId.isNotEmpty ? 'studentUserIds' : 'studentIds', arrayContains: userId != null && userId.isNotEmpty ? userId : studentId).snapshots().map((s) {
        final list = s.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        list.sort((a, b) => _date(b['createdAt']).compareTo(_date(a['createdAt'])));
        return list;
      });

  Stream<List<Map<String, dynamic>>> watchAttendanceForStudent(String studentId) =>
      _attendance.where('studentId', isEqualTo: studentId).snapshots().map((s) {
        final list = s.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        list.sort((a, b) => _date(b['date']).compareTo(_date(a['date'])));
        return list;
      });

  Future<void> publishAssignment({
    required String title,
    required String description,
    required String teacherId,
    required List<String> studentIds,
    List<String> studentUserIds = const [],
    DateTime? dueDate,
  }) async {
    if (studentIds.isEmpty) throw Exception('Select at least one student.');
    await _assignments.add({
      'title': title.trim(),
      'description': description.trim(),
      'teacherId': teacherId,
      'studentIds': studentIds,
      'studentUserIds': studentUserIds,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate),
      'createdAt': FieldValue.serverTimestamp(),
      'published': true,
    });
  }

  Future<void> markAttendance({
    required String studentId,
    required String studentName,
    required String teacherId,
    required DateTime date,
    required String status,
    String note = '',
  }) async {
    final key = '${_dateKey(date)}_$studentId';
    await _attendance.doc(key).set({
      'studentId': studentId,
      'studentName': studentName,
      'teacherId': teacherId,
      'date': Timestamp.fromDate(date),
      'dateKey': _dateKey(date),
      'status': status,
      'note': note.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  DateTime _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
