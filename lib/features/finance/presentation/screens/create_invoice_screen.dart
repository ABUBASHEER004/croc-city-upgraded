import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/app_user.dart';
import '../../../players/data/models/player.dart';
import '../../../students/data/models/student.dart';
import '../../data/finance_repository.dart';
import '../../models/fee_category.dart';
import '../../models/invoice.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = FinanceRepository();
  final _title = TextEditingController(text: 'Academy fee');
  final _amount = TextEditingController();
  final _notes = TextEditingController();

  String? _parentId;
  String? _playerId;
  String? _categoryId;
  bool _education = false;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_parentId == null || _playerId == null) {
      _message('Select the learner and parent/guardian.');
      return;
    }

    final amount = double.tryParse(_amount.text.trim().replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      _message('Enter a valid amount greater than zero.');
      return;
    }

    setState(() => _saving = true);
    try {
      final firestore = FirebaseFirestore.instance;
      final parentDoc = await firestore.collection('users').doc(_parentId).get();
      final learnerDoc = await firestore.collection(_education ? 'students' : 'players').doc(_playerId).get();

      if (!parentDoc.exists || parentDoc.data() == null) {
        throw Exception('The selected parent no longer exists.');
      }
      if (!learnerDoc.exists || learnerDoc.data() == null) {
        throw Exception('The selected learner no longer exists.');
      }

      final parent = AppUser.fromMap({...parentDoc.data()!, 'uid': parentDoc.id});
      final learnerName = _education
          ? Student.fromMap(learnerDoc.id, learnerDoc.data()!).fullName
          : Player.fromMap({...learnerDoc.data()!, 'id': learnerDoc.id}).fullName;

      String categoryTitle = 'Academy fee';
      final categoryId = _categoryId;
      if (categoryId != null && categoryId.isNotEmpty) {
        final categoryDoc = await firestore.collection('fee_categories').doc(categoryId).get();
        final categoryData = categoryDoc.data();
        if (categoryDoc.exists && categoryData != null) {
          categoryTitle = categoryData['title']?.toString() ?? categoryTitle;
        }
      }

      final now = DateTime.now();
      final invoiceNumber = 'CCA-${DateFormat('yyyyMMdd-HHmmss').format(now)}';

      await _repo.createInvoice(
        Invoice(
          id: '',
          invoiceNumber: invoiceNumber,
          playerId: _playerId!,
          playerName: learnerName,
          parentId: parent.uid,
          parentName: parent.fullName,
          title: _title.text.trim().isEmpty ? categoryTitle : _title.text.trim(),
          category: categoryTitle,
          amount: amount,
          paidAmount: 0,
          dueDate: _dueDate,
          status: 'Pending',
          notes: _notes.text.trim(),
          createdAt: now,
        ),
      );

      if (!mounted) return;
      _message('Invoice published. The parent can see it in real time.');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) _message('Could not create invoice: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String text, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Invoice')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Text('New academy charge', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('Link the charge to the correct learner and parent so the parent portal updates automatically.'),
            const SizedBox(height: 14),
            SwitchListTile.adaptive(
              value: _education,
              onChanged: _saving ? null : (value) => setState(() { _education = value; _playerId = null; }),
              title: const Text('Education billing'),
              subtitle: Text(_education ? 'This invoice is for a student / student parent.' : 'This invoice is for a football player / player parent.'),
              secondary: const Icon(Icons.school_outlined),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 22),
            _ParentPicker(
              selectedId: _parentId,
              enabled: !_saving,
              onChanged: (value) => setState(() => _parentId = value),
            ),
            const SizedBox(height: 14),
            _LearnerPicker(
              selectedId: _playerId,
              enabled: !_saving,
              education: _education,
              onChanged: (value) => setState(() => _playerId = value),
            ),
            const SizedBox(height: 14),
            StreamBuilder<List<FeeCategory>>(
              stream: _repo.watchFeeCategories(),
              builder: (context, snapshot) {
                final categories = snapshot.data ?? <FeeCategory>[];
                return DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Fee category (optional)', prefixIcon: Icon(Icons.category_outlined)),
                  items: categories
                      .where((category) => category.active)
                      .map((category) => DropdownMenuItem<String>(
                            value: category.id,
                            child: Text('${category.title}${category.amount > 0 ? ' · ${_money(category.amount)}' : ''}'),
                          ))
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (id) {
                          FeeCategory? selected;
                          for (final category in categories) {
                            if (category.id == id) {
                              selected = category;
                              break;
                            }
                          }
                          setState(() {
                            _categoryId = id;
                            if (selected != null) {
                              _title.text = selected.title;
                              if (selected.amount > 0) _amount.text = selected.amount.toStringAsFixed(2);
                            }
                          });
                        },
                );
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Invoice title', prefixIcon: Icon(Icons.receipt_long_outlined)),
              validator: (value) => value == null || value.trim().isEmpty ? 'Enter an invoice title' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount (₦)', prefixIcon: Icon(Icons.payments_outlined)),
              validator: (value) {
                final amount = double.tryParse((value ?? '').trim().replaceAll(',', ''));
                return amount == null || amount <= 0 ? 'Enter an amount greater than zero' : null;
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.event_outlined)),
              title: const Text('Due date', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(DateFormat('d MMMM yyyy').format(_dueDate)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _saving ? null : _pickDueDate,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes (optional)', alignLabelWithHint: true, prefixIcon: Icon(Icons.notes_outlined)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.publish_outlined),
                label: Text(_saving ? 'Publishing…' : 'Publish invoice'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 10, today.month, today.day),
      initialDate: _dueDate.isBefore(today) ? today : _dueDate,
    );
    if (picked != null && mounted) setState(() => _dueDate = picked);
  }
}

class _ParentPicker extends StatelessWidget {
  const _ParentPicker({required this.selectedId, required this.enabled, required this.onChanged});
  final String? selectedId;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').where('role', whereIn: ['Parent', 'Player Parent', 'Student Parent']).snapshots(),
        builder: (context, snapshot) {
          final parents = snapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
          return DropdownButtonFormField<String>(
            initialValue: selectedId,
            decoration: const InputDecoration(labelText: 'Parent / Guardian', prefixIcon: Icon(Icons.family_restroom_outlined)),
            items: parents.map((doc) {
              final parent = AppUser.fromMap({...doc.data(), 'uid': doc.id});
              return DropdownMenuItem<String>(value: parent.uid, child: Text(parent.fullName));
            }).toList(),
            onChanged: enabled ? onChanged : null,
            validator: (value) => value == null ? 'Select a parent' : null,
          );
        },
      );
}

class _LearnerPicker extends StatelessWidget {
  const _LearnerPicker({required this.selectedId, required this.enabled, required this.education, required this.onChanged});
  final String? selectedId;
  final bool enabled;
  final bool education;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(education ? 'students' : 'players').snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
          return DropdownButtonFormField<String>(
            initialValue: selectedId,
            decoration: InputDecoration(labelText: education ? 'Student' : 'Player', prefixIcon: Icon(education ? Icons.school_outlined : Icons.person_outline)),
            items: docs.map((doc) {
              final name = education
                  ? Student.fromMap(doc.id, doc.data()).fullName
                  : Player.fromMap({...doc.data(), 'id': doc.id}).fullName;
              return DropdownMenuItem<String>(value: doc.id, child: Text(name));
            }).toList(),
            onChanged: enabled ? onChanged : null,
            validator: (value) => value == null ? 'Select a learner' : null,
          );
        },
      );
}

String _money(double value) => NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2).format(value);
