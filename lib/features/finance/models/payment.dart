import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  const Payment({
    required this.id,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.playerId,
    required this.playerName,
    required this.parentId,
    required this.amount,
    required this.method,
    required this.reference,
    required this.note,
    required this.paidAt,
    required this.createdAt,
  });

  final String id;
  final String invoiceId;
  final String invoiceNumber;
  final String playerId;
  final String playerName;
  final String parentId;
  final double amount;
  final String method;
  final String reference;
  final String note;
  final DateTime paidAt;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'invoiceId': invoiceId,
        'invoiceNumber': invoiceNumber,
        'playerId': playerId,
        'playerName': playerName,
        'parentId': parentId,
        'amount': amount,
        'method': method,
        'reference': reference,
        'note': note,
        'paidAt': Timestamp.fromDate(paidAt),
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Payment.fromMap(String id, Map<String, dynamic> map) {
    DateTime dateValue(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
    }
    double numberValue(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }
    return Payment(
      id: id,
      invoiceId: map['invoiceId']?.toString() ?? '',
      invoiceNumber: map['invoiceNumber']?.toString() ?? '',
      playerId: map['playerId']?.toString() ?? '',
      playerName: map['playerName']?.toString() ?? '',
      parentId: map['parentId']?.toString() ?? '',
      amount: numberValue(map['amount']),
      method: map['method']?.toString() ?? 'Bank transfer',
      reference: map['reference']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
      paidAt: dateValue(map['paidAt']),
      createdAt: dateValue(map['createdAt']),
    );
  }
}
