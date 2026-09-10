import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fee_category.dart';
import '../models/invoice.dart';
import '../models/payment.dart';
import '../models/scholarship.dart';

class FinanceRepository {
  FinanceRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _invoices => _db.collection('invoices');
  CollectionReference<Map<String, dynamic>> get _payments => _db.collection('payments');
  CollectionReference<Map<String, dynamic>> get _fees => _db.collection('fee_categories');
  CollectionReference<Map<String, dynamic>> get _scholarships => _db.collection('scholarships');

  Stream<List<Invoice>> watchInvoices({String? parentId}) {
    Query<Map<String, dynamic>> query = _invoices;
    if (parentId != null && parentId.isNotEmpty) query = query.where('parentId', isEqualTo: parentId);
    return query.snapshots().map((s) {
      final list = s.docs.map((d) => Invoice.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return list;
    });
  }

  Stream<List<Payment>> watchPayments({String? parentId}) {
    Query<Map<String, dynamic>> query = _payments;
    if (parentId != null && parentId.isNotEmpty) query = query.where('parentId', isEqualTo: parentId);
    return query.snapshots().map((s) {
      final list = s.docs.map((d) => Payment.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.paidAt.compareTo(a.paidAt));
      return list;
    });
  }

  Stream<List<FeeCategory>> watchFeeCategories() => _fees.snapshots().map((s) {
        final list = s.docs.map((d) => FeeCategory.fromMap(d.id, d.data())).toList();
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        return list;
      });

  Stream<List<Scholarship>> watchScholarships({String? parentId}) {
    Query<Map<String, dynamic>> query = _scholarships;
    if (parentId != null && parentId.isNotEmpty) query = query.where('parentId', isEqualTo: parentId);
    return query.snapshots().map((s) => s.docs.map((d) => Scholarship.fromMap(d.id, d.data())).toList());
  }

  Future<String> createInvoice(Invoice invoice) async {
    final ref = await _invoices.add(invoice.toMap());
    await ref.update({'id': ref.id});
    return ref.id;
  }

  Future<void> deleteInvoice(String id) => _invoices.doc(id).delete();

  Future<String> recordPayment(Payment payment, Invoice invoice) async {
    final paymentRef = _payments.doc();
    final newPaid = (invoice.paidAmount + payment.amount).clamp(0, invoice.amount).toDouble();
    final status = newPaid >= invoice.amount ? 'Paid' : 'Partially paid';
    final batch = _db.batch();
    batch.set(paymentRef, payment.toMap());
    batch.update(_invoices.doc(invoice.id), {'paidAmount': newPaid, 'status': status, 'updatedAt': FieldValue.serverTimestamp()});
    await batch.commit();
    return paymentRef.id;
  }

  Future<void> saveFeeCategory(FeeCategory category) async {
    final ref = category.id.isEmpty ? _fees.doc() : _fees.doc(category.id);
    await ref.set(category.toMap());
  }
  Future<void> deleteFeeCategory(String id) => _fees.doc(id).delete();

  Future<String> createScholarship(Scholarship scholarship) async {
    final ref = await _scholarships.add(scholarship.toMap());
    await ref.update({'id': ref.id});
    return ref.id;
  }
}
