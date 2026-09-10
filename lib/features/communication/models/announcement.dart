import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.publishedAt,
    required this.priority,
    required this.audience,
    required this.publishedBy,
    required this.publishedByName,
    required this.active,
  });

  final String id;
  final String title;
  final String message;
  final DateTime publishedAt;
  final String priority;
  final String audience;
  final String publishedBy;
  final String publishedByName;
  final bool active;

  Map<String, dynamic> toMap() => {
        'title': title,
        'message': message,
        'publishedAt': Timestamp.fromDate(publishedAt),
        'priority': priority,
        'audience': audience,
        'publishedBy': publishedBy,
        'publishedByName': publishedByName,
        'active': active,
      };

  factory Announcement.fromMap(String id, Map<String, dynamic> map) {
    final raw = map['publishedAt'];
    final date = raw is Timestamp
        ? raw.toDate()
        : raw is DateTime
            ? raw
            : DateTime.tryParse(raw?.toString() ?? '') ?? DateTime.now();

    return Announcement(
      id: id,
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? map['description']?.toString() ?? '',
      publishedAt: date,
      priority: map['priority']?.toString() ?? 'Normal',
      audience: map['audience']?.toString() ?? 'Everyone',
      publishedBy: map['publishedBy']?.toString() ?? '',
      publishedByName: map['publishedByName']?.toString() ?? 'Academy',
      active: map['active'] != false,
    );
  }

  Announcement copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? publishedAt,
    String? priority,
    String? audience,
    String? publishedBy,
    String? publishedByName,
    bool? active,
  }) =>
      Announcement(
        id: id ?? this.id,
        title: title ?? this.title,
        message: message ?? this.message,
        publishedAt: publishedAt ?? this.publishedAt,
        priority: priority ?? this.priority,
        audience: audience ?? this.audience,
        publishedBy: publishedBy ?? this.publishedBy,
        publishedByName: publishedByName ?? this.publishedByName,
        active: active ?? this.active,
      );
}
