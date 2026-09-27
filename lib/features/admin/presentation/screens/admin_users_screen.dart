import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../data/admin_service.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User & Role Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(context: context, builder: (_) => const _CreateUserDialog()),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Register user'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').orderBy('firstName').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Unable to load users: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs.where((doc) {
            final role = doc.data()['role']?.toString().toLowerCase() ?? '';
            return role != 'administrator' && role != 'admin';
          }).toList();
          if (docs.isEmpty) return const Center(child: Text('No managed users yet.'));
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
              final role = data['role']?.toString() ?? 'User';
              final username = data['username']?.toString() ?? '';
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(name.isEmpty ? '?' : name[0].toUpperCase())),
                  title: Text(name.isEmpty ? 'Unnamed user' : name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('$role${username.isEmpty ? '' : ' · @$username'}\n${data['email'] ?? ''}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'reset') await _reset(context, docs[index].id, name);
                    },
                    itemBuilder: (_) => const [PopupMenuItem(value: 'reset', child: Text('Reset password'))],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _reset(BuildContext context, String uid, String name) async {
    final controller = TextEditingController(text: 'Croc@${DateTime.now().year}');
    final password = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reset ${name.isEmpty ? 'user' : name} password'),
        content: TextField(controller: controller, obscureText: true, decoration: const InputDecoration(labelText: 'Temporary password')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Reset')),
        ],
      ),
    );
    controller.dispose();
    if (password == null || password.trim().length < 6 || !context.mounted) return;
    try {
      await AdminService().resetUserPassword(uid: uid, newPassword: password);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset successfully. Give the new password to the user securely.')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }
}

class _CreateUserDialog extends StatefulWidget {
  const _CreateUserDialog();
  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final first = TextEditingController();
  final last = TextEditingController();
  final username = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController(text: 'Croc@2026');
  String role = 'Player';
  bool loading = false;

  static const roles = ['Player', 'Coach', 'Player Parent', 'Student', 'Student Parent', 'Teacher', 'Staff', 'Administrator'];

  @override
  void dispose() { first.dispose(); last.dispose(); username.dispose(); email.dispose(); phone.dispose(); password.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Register a new user'),
        content: SizedBox(
          width: 520,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(child: Column(children: [
              _field(first, 'First name'), _field(last, 'Last name'), _field(username, 'Username'),
              _field(email, 'Email address', keyboard: TextInputType.emailAddress), _field(phone, 'Phone number'),
              DropdownButtonFormField<String>(value: role, decoration: const InputDecoration(labelText: 'Role'), items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(), onChanged: (v) => setState(() => role = v ?? role)),
              _field(password, 'Temporary password', obscure: true, validator: (v) => (v == null || v.length < 6) ? 'Use at least 6 characters' : null),
              const SizedBox(height: 8),
              const Text('The administrator gives the user this username and temporary password after registration.', style: TextStyle(fontSize: 12)),
            ])),
          ),
        ),
        actions: [
          TextButton(onPressed: loading ? null : () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton.icon(onPressed: loading ? null : _submit, icon: loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.person_add_alt_1), label: Text(loading ? 'Creating…' : 'Create user')),
        ],
      );

  Widget _field(TextEditingController c, String label, {bool obscure = false, TextInputType? keyboard, String? Function(String?)? validator}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(controller: c, obscureText: obscure, keyboardType: keyboard, validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null, decoration: InputDecoration(labelText: label)),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      await AdminService().createUser(firstName: first.text, lastName: last.text, username: username.text, email: email.text, phone: phone.text, password: password.text, role: role);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User registered successfully.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}
