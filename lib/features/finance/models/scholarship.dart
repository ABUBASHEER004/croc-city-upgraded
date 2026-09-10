import 'package:cloud_firestore/cloud_firestore.dart';

class Scholarship {
  const Scholarship({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.parentId,
    required this.title,
    required this.amount,
    required this.reason,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String playerId;
  final String playerName;
  final String parentId;
  final String title;
  final double amount;
  final String reason;
  final bool active;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'playerId': playerId,
        'playerName': playerName,
        'parentId': parentId,
        'title': title,
        'amount': amount,
        'reason': reason,
        'active': active,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Scholarship.fromMap(String id, Map<String, dynamic> map) {
    final raw = map['amount'];
    final amount = raw is num ? raw.toDouble() : double.tryParse(raw?.toString() ?? '') ?? 0;
    final rawDate = map['createdAt'];
    final createdAt = rawDate is Timestamp
        ? rawDate.toDate()
        : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now();
    return Scholarship(
      id: id,
      playerId: map['playerId']?.toString() ?? '',
      playerName: map['playerName']?.toString() ?? '',
      parentId: map['parentId']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Scholarship',
      amount: amount,
      reason: map['reason']?.toString() ?? '',
      active: map['active'] != false,
      createdAt: createdAt,
    );
  }
}
