import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/student.dart';

class StudentService {
  StudentService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Stream<List<Student>> watchStudents({String? parentId, String? teacherId, String? userId}) {
    Query<Map<String, dynamic>> query = _firestore.collection('students');
    if (parentId != null) query = query.where('parentId', isEqualTo: parentId);
    if (teacherId != null) query = query.where('teacherId', isEqualTo: teacherId);
    if (userId != null) query = query.where('userId', isEqualTo: userId);
    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => Student.fromMap(doc.id, doc.data())).toList();
      list.sort((a, b) => a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase()));
      return list;
    });
  }

  Future<void> createStudent(Student student) => _firestore.collection('students').doc(student.id).set(student.toMap());
  Future<void> deleteStudent(String id) => _firestore.collection('students').doc(id).delete();

  Stream<List<Map<String, dynamic>>> watchResults(String studentId, {String? parentId}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('student_results')
        .where('studentId', isEqualTo: studentId)
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
    required String studentId,
    required String parentId,
    required String studentName,
    required String term,
    required String session,
    required List<Map<String, dynamic>> subjects,
  }) async {
    final ref = await _firestore.collection('student_results').add({
      'studentId': studentId,
      'parentId': parentId,
      'studentName': studentName,
      'term': term,
      'session': session,
      'subjects': subjects,
      'published': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updateResultPdf(String resultId, String pdfUrl) =>
      _firestore.collection('student_results').doc(resultId).update({
        'pdfUrl': pdfUrl,
        'published': true,
        'publishedAt': FieldValue.serverTimestamp(),
      });

  DateTime _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}
