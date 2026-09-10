import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/finance_repository.dart';
import '../../models/invoice.dart';
import '../../models/payment.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final _repo = FinanceRepository();
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _note = TextEditingController();

  String? _invoiceId;
  String _method = 'Bank transfer';
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _record() async {
    if (!_formKey.currentState!.validate()) return;
    final invoiceId = _invoiceId;
    if (invoiceId == null || invoiceId.isEmpty) return;

    final amount = double.tryParse(_amount.text.trim().replaceAll(',', ''));
    if (amount == null || amount <= 0) return;

    setState(() => _saving = true);
    try {
      final invoiceDoc = await FirebaseFirestore.instance.collection('invoices').doc(invoiceId).get();
      final invoiceData = invoiceDoc.data();
      if (!invoiceDoc.exists || invoiceData == null) {
        throw Exception('The selected invoice no longer exists.');
      }

      final invoice = Invoice.fromMap(invoiceDoc.id, invoiceData);
      if (amount > invoice.balance + 0.009) {
        throw Exception('Payment cannot be greater than the invoice balance of ${_money(invoice.balance)}.');
      }

      await _repo.recordPayment(
        Payment(
          id: '',
          invoiceId: invoice.id,
          invoiceNumber: invoice.invoiceNumber,
          playerId: invoice.playerId,
          playerName: invoice.playerName,
          parentId: invoice.parentId,
          amount: amount,
          method: _method,
          reference: _reference.text.trim(),
          note: _note.text.trim(),
          paidAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        invoice,
      );

      if (!mounted) return;
      _amount.clear();
      _reference.clear();
      _note.clear();
      setState(() => _invoiceId = null);
      _message('Payment recorded and the invoice balance updated in real time.');
    } catch (e) {
      if (mounted) _message('Could not record payment: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: StreamBuilder<List<Invoice>>(
        stream: _repo.watchInvoices(),
        builder: (context, invoiceSnapshot) {
          final invoices = invoiceSnapshot.data ?? <Invoice>[];
          return StreamBuilder<List<Payment>>(
            stream: _repo.watchPayments(),
            builder: (context, paymentSnapshot) {
              final payments = paymentSnapshot.data ?? <Payment>[];
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _PaymentForm(
                    formKey: _formKey,
                    invoices: invoices,
                    invoiceId: _invoiceId,
                    amountController: _amount,
                    referenceController: _reference,
                    noteController: _note,
                    method: _method,
                    saving: _saving,
                    onInvoiceChanged: (value) {
                      Invoice? selected;
                      for (final invoice in invoices) {
                        if (invoice.id == value) {
                          selected = invoice;
                          break;
                        }
                      }
                      setState(() {
                        _invoiceId = value;
                        _amount.text = selected?.balance.toStringAsFixed(2) ?? '';
                      });
                    },
                    onMethodChanged: (value) => setState(() => _method = value ?? 'Bank transfer'),
                    onSave: _record,
                  ),
                  const SizedBox(height: 24),
                  Text('Recorded payments', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  if (paymentSnapshot.hasError)
                    const _MessageCard(message: 'Unable to load payment history right now.')
                  else if (payments.isEmpty)
                    const _MessageCard(message: 'No payments recorded yet.')
                  else
                    ...payments.map(
                      (payment) => Card(
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
                          title: Text('${_money(payment.amount)} · ${payment.playerName}', style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text(
                            '${payment.invoiceNumber} · ${payment.method}\n'
                            '${DateFormat('d MMM yyyy · h:mm a').format(payment.paidAt)}'
                            '${payment.reference.isEmpty ? '' : '\nRef: ${payment.reference}'}',
                          ),
                          isThreeLine: true,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _PaymentForm extends StatelessWidget {
  const _PaymentForm({
    required this.formKey,
    required this.invoices,
    required this.invoiceId,
    required this.amountController,
    required this.referenceController,
    required this.noteController,
    required this.method,
    required this.saving,
    required this.onInvoiceChanged,
    required this.onMethodChanged,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final List<Invoice> invoices;
  final String? invoiceId;
  final TextEditingController amountController;
  final TextEditingController referenceController;
  final TextEditingController noteController;
  final String method;
  final bool saving;
  final ValueChanged<String?> onInvoiceChanged;
  final ValueChanged<String?> onMethodChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Record a payment', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: invoiceId,
                  decoration: const InputDecoration(labelText: 'Invoice', prefixIcon: Icon(Icons.receipt_long_outlined)),
                  items: invoices
                      .where((invoice) => invoice.balance > 0.009)
                      .map((invoice) => DropdownMenuItem<String>(
                            value: invoice.id,
                            child: Text('${invoice.invoiceNumber} · ${invoice.playerName} · ${_money(invoice.balance)} due'),
                          ))
                      .toList(),
                  onChanged: saving ? null : onInvoiceChanged,
                  validator: (value) => value == null ? 'Select an invoice' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount (₦)', prefixIcon: Icon(Icons.payments_outlined)),
                  validator: (value) {
                    final amount = double.tryParse((value ?? '').trim().replaceAll(',', ''));
                    return amount == null || amount <= 0 ? 'Enter a valid payment amount' : null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: method,
                  decoration: const InputDecoration(labelText: 'Payment method', prefixIcon: Icon(Icons.account_balance_outlined)),
                  items: const [
                    'Bank transfer',
                    'Cash',
                    'POS',
                    'Online',
                    'Other',
                  ].map((value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                  onChanged: saving ? null : onMethodChanged,
                ),
                const SizedBox(height: 12),
                TextFormField(controller: referenceController, decoration: const InputDecoration(labelText: 'Reference (optional)', prefixIcon: Icon(Icons.tag_outlined))),
                const SizedBox(height: 12),
                TextFormField(controller: noteController, maxLines: 2, decoration: const InputDecoration(labelText: 'Note (optional)', alignLabelWithHint: true, prefixIcon: Icon(Icons.notes_outlined))),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: saving ? null : onSave,
                    icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_circle_outline),
                    label: Text(saving ? 'Saving…' : 'Record payment'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(24), child: Text(message)));
}

String _money(double value) => NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2).format(value);
