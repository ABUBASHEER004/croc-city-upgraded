import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String id;
  final String registrationNo;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String gender;
  final DateTime dateOfBirth;
  final String teamId;
  final String coachId;
  final String position;
  final int jerseyNumber;
  final String preferredFoot;
  final String parentId;
  final String parentName;
  final String parentPhone;
  final String emergencyContact;
  final String medicalNotes;
  final String photoUrl;
  final bool active;
  final DateTime createdAt;

  const Player({
    required this.id,
    required this.registrationNo,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    required this.dateOfBirth,
    required this.teamId,
    this.coachId = '',
    required this.position,
    required this.jerseyNumber,
    required this.preferredFoot,
    this.parentId = '',
    required this.parentName,
    required this.parentPhone,
    required this.emergencyContact,
    required this.medicalNotes,
    required this.photoUrl,
    required this.active,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  static DateTime _dateValue(dynamic value, DateTime fallback) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();

    return Player(
      id: map['id']?.toString() ?? '',
      registrationNo: map['registrationNo']?.toString() ?? '',
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      gender: map['gender']?.toString() ?? '',
      dateOfBirth: _dateValue(map['dateOfBirth'], now),
      teamId: map['teamId']?.toString() ?? '',
      coachId: map['coachId']?.toString() ?? '',
      position: map['position']?.toString() ?? '',
      jerseyNumber: _intValue(map['jerseyNumber']),
      preferredFoot: map['preferredFoot']?.toString() ?? 'Right',
      parentId: map['parentId']?.toString() ?? '',
      parentName: map['parentName']?.toString() ?? '',
      parentPhone: map['parentPhone']?.toString() ?? '',
      emergencyContact: map['emergencyContact']?.toString() ?? '',
      medicalNotes: map['medicalNotes']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString() ?? '',
      active: map['active'] != false,
      createdAt: _dateValue(map['createdAt'], now),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'registrationNo': registrationNo,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'teamId': teamId,
      'coachId': coachId,
      'position': position,
      'jerseyNumber': jerseyNumber,
      'preferredFoot': preferredFoot,
      'parentId': parentId,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'emergencyContact': emergencyContact,
      'medicalNotes': medicalNotes,
      'photoUrl': photoUrl,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Player copyWith({
    String? id,
    String? registrationNo,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? gender,
    DateTime? dateOfBirth,
    String? teamId,
    String? coachId,
    String? position,
    int? jerseyNumber,
    String? preferredFoot,
    String? parentId,
    String? parentName,
    String? parentPhone,
    String? emergencyContact,
    String? medicalNotes,
    String? photoUrl,
    bool? active,
    DateTime? createdAt,
  }) {
    return Player(
      id: id ?? this.id,
      registrationNo: registrationNo ?? this.registrationNo,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      teamId: teamId ?? this.teamId,
      coachId: coachId ?? this.coachId,
      position: position ?? this.position,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      preferredFoot: preferredFoot ?? this.preferredFoot,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      photoUrl: photoUrl ?? this.photoUrl,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
