import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.publishedAt,
    required this.priority,
    required this.audience,
    this.audiences = const [],
    this.recipientEmails = const [],
    this.recipientUserIds = const [],
    this.audienceKeys = const [],
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
  final List<String> audiences;
  final List<String> recipientEmails;
  final List<String> recipientUserIds;
  final List<String> audienceKeys;
  final String publishedBy;
  final String publishedByName;
  final bool active;

  Map<String, dynamic> toMap() => {
        'title': title,
        'message': message,
        'publishedAt': Timestamp.fromDate(publishedAt),
        'priority': priority,
        'audience': audience,
        'audiences': audiences.isEmpty ? [audience] : audiences,
        'recipientEmails': recipientEmails,
        'recipientUserIds': recipientUserIds,
        'audienceKeys': audienceKeys.isEmpty ? [audience, ...recipientEmails.map((e) => 'email:${e.toLowerCase()}'), ...recipientUserIds.map((id) => 'uid:$id')] : audienceKeys,
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
      audiences: (map['audiences'] is Iterable) ? List<String>.from((map['audiences'] as Iterable).map((e) => e.toString())) : [map['audience']?.toString() ?? 'Everyone'],
      recipientEmails: (map['recipientEmails'] is Iterable) ? List<String>.from((map['recipientEmails'] as Iterable).map((e) => e.toString().toLowerCase())) : const [],
      recipientUserIds: (map['recipientUserIds'] is Iterable) ? List<String>.from((map['recipientUserIds'] as Iterable).map((e) => e.toString())) : const [],
      audienceKeys: (map['audienceKeys'] is Iterable) ? List<String>.from((map['audienceKeys'] as Iterable).map((e) => e.toString())) : [map['audience']?.toString() ?? 'Everyone'],
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
    List<String>? audiences,
    List<String>? recipientEmails,
    List<String>? recipientUserIds,
    List<String>? audienceKeys,
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
        audiences: audiences ?? this.audiences,
        recipientEmails: recipientEmails ?? this.recipientEmails,
        recipientUserIds: recipientUserIds ?? this.recipientUserIds,
        audienceKeys: audienceKeys ?? this.audienceKeys,
        publishedBy: publishedBy ?? this.publishedBy,
        publishedByName: publishedByName ?? this.publishedByName,
        active: active ?? this.active,
      );
}
