import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingSession {
  const TrainingSession({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.location,
    required this.coachId,
    required this.coachName,
    required this.teamId,
    required this.teamName,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String location;
  final String coachId;
  final String coachName;
  final String teamId;
  final String teamName;
  final String status;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'durationMinutes': durationMinutes,
        'location': location,
        'coachId': coachId,
        'coachName': coachName,
        'teamId': teamId,
        'teamName': teamName,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory TrainingSession.fromMap(String id, Map<String, dynamic> map) {
    DateTime dateValue(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
    }

    final rawDuration = map['durationMinutes'];
    final duration = rawDuration is num
        ? rawDuration.toInt()
        : int.tryParse(rawDuration?.toString() ?? '') ?? 90;

    return TrainingSession(
      id: id,
      title: map['title']?.toString() ?? 'Training session',
      description: map['description']?.toString() ?? '',
      scheduledAt: dateValue(map['scheduledAt']),
      durationMinutes: duration,
      location: map['location']?.toString() ?? '',
      coachId: map['coachId']?.toString() ?? '',
      coachName: map['coachName']?.toString() ?? '',
      teamId: map['teamId']?.toString() ?? '',
      teamName: map['teamName']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Scheduled',
      createdAt: dateValue(map['createdAt']),
    );
  }

  TrainingSession copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledAt,
    int? durationMinutes,
    String? location,
    String? coachId,
    String? coachName,
    String? teamId,
    String? teamName,
    String? status,
    DateTime? createdAt,
  }) =>
      TrainingSession(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        location: location ?? this.location,
        coachId: coachId ?? this.coachId,
        coachName: coachName ?? this.coachName,
        teamId: teamId ?? this.teamId,
        teamName: teamName ?? this.teamName,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
}
