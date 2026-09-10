
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/coach.dart';
import '../providers/coach_provider.dart';

class CoachDetailsScreen extends StatelessWidget {
  const CoachDetailsScreen({super.key, required this.coachId});
  final String coachId;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CoachProvider>();
    return FutureBuilder<Coach?>(
      future: provider.getCoach(coachId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final coach = snapshot.data;
        if (coach == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Coach')),
            body: Center(
              child: FilledButton.icon(
                onPressed: () => context.go('/coaches'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Coaches'),
              ),
            ),
          );
        }

        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Coach Profile'),
            actions: [
              IconButton(
                tooltip: 'Edit coach',
                onPressed: () => context.push('/coaches/edit/$coachId'),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundImage: coach.photoUrl.isNotEmpty
                            ? NetworkImage(coach.photoUrl)
                            : null,
                        child: coach.photoUrl.isEmpty
                            ? const Icon(Icons.sports, size: 48)
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        coach.fullName.isEmpty ? 'Unnamed Coach' : coach.fullName,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(coach.specialty),
                      const SizedBox(height: 12),
                      Chip(
                        avatar: Icon(
                          coach.active
                              ? Icons.check_circle_outline
                              : Icons.pause_circle_outline,
                        ),
                        label: Text(
                          coach.active ? 'Active coach' : 'Inactive coach',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _Info(icon: Icons.email_outlined, title: 'Email', value: coach.email),
              _Info(icon: Icons.phone_outlined, title: 'Phone', value: coach.phone),
              _Info(
                icon: Icons.workspace_premium_outlined,
                title: 'Certification',
                value: coach.licenseNumber.isEmpty
                    ? 'Not provided'
                    : coach.licenseNumber,
              ),
              _Info(
                icon: Icons.timeline_outlined,
                title: 'Experience',
                value: coach.experience.isEmpty
                    ? 'Not provided'
                    : coach.experience,
              ),
              if (coach.bio.isNotEmpty)
                _Info(
                  icon: Icons.notes_outlined,
                  title: 'Professional bio',
                  value: coach.bio,
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
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(value),
          ),
        ),
      );
}
