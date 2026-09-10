import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parent_provider.dart';

class ParentDetailsScreen extends StatelessWidget {
  const ParentDetailsScreen({super.key, required this.parentId});
  final String parentId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<ParentProvider>().getParent(parentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final parent = snapshot.data;
        if (parent == null) {
          return const Scaffold(
            body: Center(child: Text('Parent profile not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Parent Profile')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CircleAvatar(
                radius: 58,
                backgroundImage: parent.photoUrl?.isNotEmpty == true
                    ? NetworkImage(parent.photoUrl!)
                    : null,
                child: parent.photoUrl?.isNotEmpty == true
                    ? null
                    : const Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 16),
              Text(
                parent.fullName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                parent.role,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _Info(icon: Icons.email_outlined, title: 'Email', value: parent.email),
              _Info(icon: Icons.phone_outlined, title: 'Phone', value: parent.phone),
              _Info(
                icon: Icons.verified_outlined,
                title: 'Email verification',
                value: parent.emailVerified ? 'Verified' : 'Not verified',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(value.isEmpty ? 'Not provided' : value),
        ),
      );
}
