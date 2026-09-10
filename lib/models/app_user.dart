import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final bool emailVerified;
  final String? photoUrl;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.emailVerified,
    this.photoUrl,
    required this.createdAt,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'Academy User' : name;
  }

  String get normalizedRole => role.trim().toLowerCase();

  bool get isAdmin => normalizedRole == 'admin' || normalizedRole == 'administrator';
  bool get isPlayer => normalizedRole == 'player';
  bool get isParent => normalizedRole == 'parent';
  bool get isCoach => normalizedRole == 'coach';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'emailVerified': emailVerified,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final rawCreatedAt = map['createdAt'];

    DateTime createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    } else {
      createdAt = DateTime.tryParse(rawCreatedAt?.toString() ?? '') ?? DateTime.now();
    }

    return AppUser(
      uid: map['uid']?.toString() ?? '',
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      role: map['role']?.toString() ?? 'Player',
      emailVerified: map['emailVerified'] == true,
      photoUrl: map['photoUrl']?.toString(),
      createdAt: createdAt,
    );
  }

  AppUser copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? role,
    bool? emailVerified,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
