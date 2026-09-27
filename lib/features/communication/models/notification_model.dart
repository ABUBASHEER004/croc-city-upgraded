import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.read,
    this.announcementId,
    this.entityId,
    this.priority = 'Normal',
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool read;
  final String? announcementId;
  final String? entityId;
  final String priority;

  factory NotificationModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final rawDate = map['createdAt'];

    final createdAt = rawDate is Timestamp
        ? rawDate.toDate()
        : rawDate is DateTime
            ? rawDate
            : DateTime.tryParse(
                  rawDate?.toString() ?? '',
                ) ??
                DateTime.now();

    return NotificationModel(
      id: id,
      title: map['title']?.toString() ?? 'Croc-City Football Academy',
      message: map['message']?.toString() ?? '',
      type: map['type']?.toString() ?? 'academy',
      createdAt: createdAt,
      read: map['read'] == true,
      announcementId: map['announcementId']?.toString(),
      entityId: map['entityId']?.toString(),
      priority: map['priority']?.toString() ?? 'Normal',
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'title': title,
        'message': message,
        'type': type,
        'createdAt': Timestamp.fromDate(createdAt),
        'read': read,
        if (announcementId != null) 'announcementId': announcementId,
        if (entityId != null) 'entityId': entityId,
        'priority': priority,
      };

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? createdAt,
    bool? read,
    String? announcementId,
    String? entityId,
    String? priority,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
      announcementId: announcementId ?? this.announcementId,
      entityId: entityId ?? this.entityId,
      priority: priority ?? this.priority,
    );
  }
}
