import 'package:cloud_firestore/cloud_firestore.dart';

class FeeCategory {
  const FeeCategory({
    required this.id,
    required this.title,
    required this.amount,
    required this.description,
    required this.active,
  });

  final String id;
  final String title;
  final double amount;
  final String description;
  final bool active;

  Map<String, dynamic> toMap() => {
        'title': title,
        'amount': amount,
        'description': description,
        'active': active,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory FeeCategory.fromMap(String id, Map<String, dynamic> map) {
    final raw = map['amount'];
    final amount = raw is num ? raw.toDouble() : double.tryParse(raw?.toString() ?? '') ?? 0;
    return FeeCategory(
      id: id,
      title: map['title']?.toString() ?? '',
      amount: amount,
      description: map['description']?.toString() ?? '',
      active: map['active'] != false,
    );
  }
}
