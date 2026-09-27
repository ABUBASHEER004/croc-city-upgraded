import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/app_user.dart';
import '../../../players/presentation/providers/player_provider.dart';

class PlayerCoachSelectionScreen extends StatefulWidget {
  const PlayerCoachSelectionScreen({super.key, required this.user});
  final AppUser user;

  @override
  State<PlayerCoachSelectionScreen> createState() => _PlayerCoachSelectionScreenState();
}

class _PlayerCoachSelectionScreenState extends State<PlayerCoachSelectionScreen> {
  bool saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PlayerProvider>().listenToPlayerByEmail(widget.user.email);
    });
  }

  Future<void> _select(String coachId) async {
    final players = context.read<PlayerProvider>().players;
    if (players.isEmpty || saving) return;
    setState(() => saving = true);
    try {
      await context.read<PlayerProvider>().assignCoach(
        playerId: players.first.id,
        coachId: coachId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coach selection saved.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not select coach: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final player = playerProvider.players.isEmpty ? null : playerProvider.players.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Coach')),
      body: player == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  playerProvider.loading
                      ? 'Finding your academy player profile…'
                      : 'We could not link an academy player profile to ${widget.user.email}. Ask the administrator to add this email to your player record.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'Coach')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final coaches = snapshot.data?.docs ?? const [];

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your academy profile',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(player.fullName),
                            Text(player.teamId.isEmpty ? 'Team not assigned yet' : 'Team assigned'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Select a coach',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    if (coaches.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No coach accounts are available right now.'),
                        ),
                      ),
                    ...coaches.map((doc) {
                      final data = doc.data();
                      final first = data['firstName']?.toString() ?? '';
                      final last = data['lastName']?.toString() ?? '';
                      final name = '$first $last'.trim();
                      final email = data['email']?.toString() ?? '';
                      final selected = player.coachId == doc.id;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            child: Text(first.isEmpty ? 'C' : first[0].toUpperCase()),
                          ),
                          title: Text(
                            name.isEmpty ? email : name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(email),
                          trailing: selected
                              ? const Icon(Icons.check_circle)
                              : const Icon(Icons.chevron_right),
                          onTap: saving ? null : () => _select(doc.id),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
    );
  }
}
