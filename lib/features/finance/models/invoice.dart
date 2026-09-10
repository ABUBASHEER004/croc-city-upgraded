import 'package:cloud_firestore/cloud_firestore.dart';

class Invoice {
  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.playerId,
    required this.playerName,
    required this.parentId,
    required this.parentName,
    required this.title,
    required this.category,
    required this.amount,
    required this.paidAmount,
    required this.dueDate,
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String invoiceNumber;
  final String playerId;
  final String playerName;
  final String parentId;
  final String parentName;
  final String title;
  final String category;
  final double amount;
  final double paidAmount;
  final DateTime dueDate;
  final String status;
  final String notes;
  final DateTime createdAt;

  double get balance => (amount - paidAmount).clamp(0, double.infinity).toDouble();
  bool get isPaid => balance <= 0.009;
  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());
  String get displayStatus => isPaid ? 'Paid' : (isOverdue ? 'Overdue' : status);

  Map<String, dynamic> toMap() => {
        'invoiceNumber': invoiceNumber,
        'playerId': playerId,
        'playerName': playerName,
        'parentId': parentId,
        'parentName': parentName,
        'title': title,
        'category': category,
        'amount': amount,
        'paidAmount': paidAmount,
        'dueDate': Timestamp.fromDate(dueDate),
        'status': status,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Invoice.fromMap(String id, Map<String, dynamic> map) {
    DateTime dateValue(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
    }
    double numberValue(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }
    return Invoice(
      id: id,
      invoiceNumber: map['invoiceNumber']?.toString() ?? id,
      playerId: map['playerId']?.toString() ?? '',
      playerName: map['playerName']?.toString() ?? '',
      parentId: map['parentId']?.toString() ?? '',
      parentName: map['parentName']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Academy fee',
      category: map['category']?.toString() ?? 'Academy fee',
      amount: numberValue(map['amount']),
      paidAmount: numberValue(map['paidAmount']),
      dueDate: dateValue(map['dueDate']),
      status: map['status']?.toString() ?? 'Pending',
      notes: map['notes']?.toString() ?? '',
      createdAt: dateValue(map['createdAt']),
    );
  }

  Invoice copyWith({
    double? paidAmount,
    String? status,
  }) => Invoice(
        id: id,
        invoiceNumber: invoiceNumber,
        playerId: playerId,
        playerName: playerName,
        parentId: parentId,
        parentName: parentName,
        title: title,
        category: category,
        amount: amount,
        paidAmount: paidAmount ?? this.paidAmount,
        dueDate: dueDate,
        status: status ?? this.status,
        notes: notes,
        createdAt: createdAt,
      );
}
