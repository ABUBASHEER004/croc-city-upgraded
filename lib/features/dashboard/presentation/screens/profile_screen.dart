import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../presentation/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No profile available')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundImage: user.photoUrl?.isNotEmpty == true
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl?.isNotEmpty == true
                        ? null
                        : const Icon(Icons.person, size: 48),
                  ),
                  const SizedBox(height: 14),
                  Text(user.fullName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user.email),
                  const SizedBox(height: 10),
                  Chip(label: Text(user.role)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _InfoTile(icon: Icons.email_outlined, label: 'Email', value: user.email),
          _InfoTile(icon: Icons.phone_outlined, label: 'Phone', value: user.phone.isEmpty ? 'Not provided' : user.phone),
          _InfoTile(icon: Icons.verified_user_outlined, label: 'Email status', value: user.emailVerified ? 'Verified' : 'Not verified'),
          _InfoTile(icon: Icons.badge_outlined, label: 'Account role', value: user.role),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
            onPressed: auth.loading
                ? null
                : () async {
                    try {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) context.go('/login');
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString().replaceFirst('Exception: ', ''),
                          ),
                        ),
                      );
                    }
                  },
            icon: auth.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: Text(auth.loading ? 'Logging out...' : 'Logout'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
