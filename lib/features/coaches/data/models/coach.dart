
import 'package:cloud_firestore/cloud_firestore.dart';

class Coach {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String specialty;
  final String licenseNumber;
  final String experience;
  final String photoUrl;
  final String bio;
  final bool active;
  final DateTime createdAt;

  const Coach({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.licenseNumber,
    required this.experience,
    required this.photoUrl,
    required this.bio,
    required this.active,
    required this.createdAt,
  });

  factory Coach.empty() => Coach(
        id: '',
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        specialty: 'Youth Development',
        licenseNumber: '',
        experience: '',
        photoUrl: '',
        bio: '',
        active: true,
        createdAt: DateTime.now(),
      );

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toMap() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'specialty': specialty,
        'licenseNumber': licenseNumber,
        'experience': experience,
        'photoUrl': photoUrl,
        'bio': bio,
        'active': active,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Coach.fromMap(Map<String, dynamic> map) {
    final raw = map['createdAt'];
    final createdAt = raw is Timestamp
        ? raw.toDate()
        : raw is DateTime
            ? raw
            : DateTime.tryParse(raw?.toString() ?? '') ?? DateTime.now();

    return Coach(
      id: map['id']?.toString() ?? '',
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      specialty: map['specialty']?.toString() ?? 'Youth Development',
      licenseNumber: map['licenseNumber']?.toString() ?? '',
      experience: map['experience']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString() ?? '',
      bio: map['bio']?.toString() ?? '',
      active: map['active'] != false,
      createdAt: createdAt,
    );
  }

  Coach copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? specialty,
    String? licenseNumber,
    String? experience,
    String? photoUrl,
    String? bio,
    bool? active,
    DateTime? createdAt,
  }) =>
      Coach(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        specialty: specialty ?? this.specialty,
        licenseNumber: licenseNumber ?? this.licenseNumber,
        experience: experience ?? this.experience,
        photoUrl: photoUrl ?? this.photoUrl,
        bio: bio ?? this.bio,
        active: active ?? this.active,
        createdAt: createdAt ?? this.createdAt,
      );
}
