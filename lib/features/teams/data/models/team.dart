import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id;
  final String name;
  final String ageGroup;
  final String category;
  final String coachId;
  final String assistantCoachId;
  final String logoUrl;
  final String homeKitColor;
  final String awayKitColor;
  final bool active;
  final DateTime createdAt;

  const Team({
    required this.id,
    required this.name,
    required this.ageGroup,
    required this.category,
    required this.coachId,
    required this.assistantCoachId,
    required this.logoUrl,
    required this.homeKitColor,
    required this.awayKitColor,
    required this.active,
    required this.createdAt,
  });

  factory Team.empty() {
    return Team(
      id: '',
      name: '',
      ageGroup: '',
      category: '',
      coachId: '',
      assistantCoachId: '',
      logoUrl: '',
      homeKitColor: '',
      awayKitColor: '',
      active: true,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ageGroup': ageGroup,
      'category': category,
      'coachId': coachId,
      'assistantCoachId': assistantCoachId,
      'logoUrl': logoUrl,
      'homeKitColor': homeKitColor,
      'awayKitColor': awayKitColor,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    final rawCreatedAt = map['createdAt'];
    DateTime createdAt;

    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    } else {
      createdAt = DateTime.tryParse(rawCreatedAt?.toString() ?? '') ?? DateTime.now();
    }

    return Team(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      ageGroup: map['ageGroup']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      coachId: map['coachId']?.toString() ?? '',
      assistantCoachId: map['assistantCoachId']?.toString() ?? '',
      logoUrl: map['logoUrl']?.toString() ?? '',
      homeKitColor: map['homeKitColor']?.toString() ?? '',
      awayKitColor: map['awayKitColor']?.toString() ?? '',
      active: map['active'] != false,
      createdAt: createdAt,
    );
  }

  Team copyWith({
    String? id,
    String? name,
    String? ageGroup,
    String? category,
    String? coachId,
    String? assistantCoachId,
    String? logoUrl,
    String? homeKitColor,
    String? awayKitColor,
    bool? active,
    DateTime? createdAt,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      ageGroup: ageGroup ?? this.ageGroup,
      category: category ?? this.category,
      coachId: coachId ?? this.coachId,
      assistantCoachId: assistantCoachId ?? this.assistantCoachId,
      logoUrl: logoUrl ?? this.logoUrl,
      homeKitColor: homeKitColor ?? this.homeKitColor,
      awayKitColor: awayKitColor ?? this.awayKitColor,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
