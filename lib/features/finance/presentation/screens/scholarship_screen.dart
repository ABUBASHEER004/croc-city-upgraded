import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/app_user.dart';
import '../../../players/data/models/player.dart';
import '../../data/finance_repository.dart';
import '../../models/scholarship.dart';

class ScholarshipScreen extends StatefulWidget {
  const ScholarshipScreen({super.key});

  @override
  State<ScholarshipScreen> createState() => _ScholarshipScreenState();
}

class _ScholarshipScreenState extends State<ScholarshipScreen> {
  final _repo = FinanceRepository();
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController(text: 'Scholarship');
  final _amount = TextEditingController();
  final _reason = TextEditingController();

  String? _playerId;
  String? _parentId;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final playerId = _playerId;
    final parentId = _parentId;
    final amount = double.tryParse(_amount.text.trim().replaceAll(',', ''));

    if (playerId == null || parentId == null || amount == null || amount <= 0) {
      _showMessage('Select a player, parent and valid scholarship amount.');
      return;
    }

    setState(() => _saving = true);
    try {
      final firestore = FirebaseFirestore.instance;
      final playerDoc = await firestore.collection('players').doc(playerId).get();
      final parentDoc = await firestore.collection('users').doc(parentId).get();

      if (!playerDoc.exists || playerDoc.data() == null) {
        throw Exception('The selected player no longer exists.');
      }
      if (!parentDoc.exists || parentDoc.data() == null) {
        throw Exception('The selected parent no longer exists.');
      }

      final player = Player.fromMap({...playerDoc.data()!, 'id': playerDoc.id});
      final parent = AppUser.fromMap({...parentDoc.data()!, 'uid': parentDoc.id});

      await _repo.createScholarship(
        Scholarship(
          id: '',
          playerId: player.id,
          playerName: player.fullName,
          parentId: parent.uid,
          title: _title.text.trim().isEmpty ? 'Scholarship' : _title.text.trim(),
          amount: amount,
          reason: _reason.text.trim(),
          active: true,
          createdAt: DateTime.now(),
        ),
      );

      if (!mounted) return;
      _amount.clear();
      _reason.clear();
      setState(() {
        _playerId = null;
        _parentId = null;
      });
      _showMessage('Scholarship recorded. The parent portal updates in real time.');
    } catch (e) {
      if (mounted) _showMessage('Could not save scholarship: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scholarships')),
      body: StreamBuilder<List<Player>>(
        stream: FirebaseFirestore.instance.collection('players').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Player.fromMap({...doc.data(), 'id': doc.id}))
              .toList(),
        ),
        builder: (context, playerSnapshot) {
          final players = playerSnapshot.data ?? <Player>[];

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'Parent')
                .snapshots(),
            builder: (context, parentSnapshot) {
              final parents = parentSnapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];

              return StreamBuilder<List<Scholarship>>(
                stream: _repo.watchScholarships(),
                builder: (context, scholarshipSnapshot) {
                  final scholarships = scholarshipSnapshot.data ?? <Scholarship>[];

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _FormCard(
                        formKey: _formKey,
                        players: players,
                        parents: parents,
                        playerId: _playerId,
                        parentId: _parentId,
                        titleController: _title,
                        amountController: _amount,
                        reasonController: _reason,
                        saving: _saving,
                        onPlayerChanged: (value) => setState(() => _playerId = value),
                        onParentChanged: (value) => setState(() => _parentId = value),
                        onSave: _save,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Current scholarships',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      if (scholarshipSnapshot.hasError)
                        _MessageCard(message: 'Unable to load scholarships right now.')
                      else if (scholarships.isEmpty)
                        const _MessageCard(message: 'No scholarships recorded yet.')
                      else
                        ...scholarships.map(
                          (scholarship) => Card(
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.school_outlined)),
                              title: Text(
                                '${scholarship.title} · ${scholarship.playerName}',
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              subtitle: Text(
                                '${_money(scholarship.amount)}${scholarship.reason.isEmpty ? '' : ' · ${scholarship.reason}'}\n'
                                '${DateFormat('d MMM yyyy').format(scholarship.createdAt)}',
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
          );
        },
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.players,
    required this.parents,
    required this.playerId,
    required this.parentId,
    required this.titleController,
    required this.amountController,
    required this.reasonController,
    required this.saving,
    required this.onPlayerChanged,
    required this.onParentChanged,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final List<Player> players;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> parents;
  final String? playerId;
  final String? parentId;
  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController reasonController;
  final bool saving;
  final ValueChanged<String?> onPlayerChanged;
  final ValueChanged<String?> onParentChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Record scholarship', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: playerId,
                decoration: const InputDecoration(labelText: 'Player', prefixIcon: Icon(Icons.person_outline)),
                items: players
                    .map((player) => DropdownMenuItem<String>(value: player.id, child: Text(player.fullName)))
                    .toList(),
                onChanged: saving ? null : onPlayerChanged,
                validator: (value) => value == null ? 'Select a player' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: parentId,
                decoration: const InputDecoration(labelText: 'Parent / Guardian', prefixIcon: Icon(Icons.family_restroom_outlined)),
                items: parents.map((doc) {
                  final parent = AppUser.fromMap({...doc.data(), 'uid': doc.id});
                  return DropdownMenuItem<String>(value: parent.uid, child: Text(parent.fullName));
                }).toList(),
                onChanged: saving ? null : onParentChanged,
                validator: (value) => value == null ? 'Select a parent' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Scholarship title', prefixIcon: Icon(Icons.title_outlined)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount (₦)', prefixIcon: Icon(Icons.payments_outlined)),
                validator: (value) {
                  final amount = double.tryParse((value ?? '').trim().replaceAll(',', ''));
                  return amount == null || amount <= 0 ? 'Enter an amount greater than zero' : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Reason / note', alignLabelWithHint: true, prefixIcon: Icon(Icons.notes_outlined)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.school_outlined),
                  label: Text(saving ? 'Saving…' : 'Record scholarship'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(24), child: Text(message)));
}

String _money(double value) => NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2).format(value);
