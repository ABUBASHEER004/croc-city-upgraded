import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  const Student({
    required this.id,
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.parentId,
    required this.parentName,
    this.coachId = '',
    this.teacherId = '',
    this.userId = '',
    this.photoUrl = '',
    required this.className,
    required this.gradeLevel,
    required this.phone,
    required this.createdAt,
  });

  final String id;
  final String studentId;
  final String firstName;
  final String lastName;
  final String parentId;
  final String parentName;
  final String coachId;
  final String teacherId;
  final String userId;
  final String photoUrl;
  final String className;
  final String gradeLevel;
  final String phone;
  final DateTime createdAt;

  String get fullName => '$firstName $lastName'.trim();

  factory Student.fromMap(String id, Map<String, dynamic> map) {
    final raw = map['createdAt'];
    final createdAt = raw is Timestamp
        ? raw.toDate()
        : DateTime.tryParse(raw?.toString() ?? '') ?? DateTime.now();
    return Student(
      id: id,
      studentId: map['studentId']?.toString() ?? id,
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      parentId: map['parentId']?.toString() ?? '',
      parentName: map['parentName']?.toString() ?? '',
      coachId: map['coachId']?.toString() ?? '',
      teacherId: map['teacherId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString() ?? '',
      className: map['className']?.toString() ?? '',
      gradeLevel: map['gradeLevel']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'firstName': firstName,
        'lastName': lastName,
        'parentId': parentId,
        'parentName': parentName,
        'coachId': coachId,
        'teacherId': teacherId,
        'userId': userId,
        'photoUrl': photoUrl,
        'className': className,
        'gradeLevel': gradeLevel,
        'phone': phone,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
