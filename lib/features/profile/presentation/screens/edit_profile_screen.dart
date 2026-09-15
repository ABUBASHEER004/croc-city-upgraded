import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController first;
  late final TextEditingController last;
  late final TextEditingController phone;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    first = TextEditingController(text: user?.firstName ?? '');
    last = TextEditingController(text: user?.lastName ?? '');
    phone = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your profile is not available. Please sign in again.')),
      );
      return;
    }

    setState(() => saving = true);
    try {
      await context.read<AuthProvider>().updateProfile(
        firstName: first.text.trim(),
        lastName: last.text.trim(),
        phone: phone.text.trim(),
      );

      if (!mounted) return;
      context.go('/profile');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: first,
              decoration: const InputDecoration(
                labelText: 'First name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: last,
              decoration: const InputDecoration(
                labelText: 'Last name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 14),
            Builder(
              builder: (context) {
                final email = context.read<AuthProvider>().currentUser?.email ?? '';
                return TextFormField(
                  initialValue: email,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    helperText: 'Email is your sign-in address and is not edited here.',
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: saving ? null : _save,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(saving ? 'Saving…' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
