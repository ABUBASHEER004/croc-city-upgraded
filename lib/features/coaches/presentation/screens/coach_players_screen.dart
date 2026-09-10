import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/app_user.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../players/data/models/player.dart';
import '../../../players/presentation/providers/player_provider.dart';

class CoachPlayersScreen extends StatefulWidget {
  const CoachPlayersScreen({super.key, required this.user});
  final AppUser user;

  @override
  State<CoachPlayersScreen> createState() => _CoachPlayersScreenState();
}

class _CoachPlayersScreenState extends State<CoachPlayersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PlayerProvider>().listenToCoach(widget.user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final players = provider.players;
    return Scaffold(
      appBar: AppBar(title: const Text('My Players')),
      body: provider.loading && players.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : players.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.groups_outlined, size: 64), SizedBox(height: 16), Text('No players assigned yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), SizedBox(height: 8), Text('Players who select you as their coach, or players assigned to you by the academy, will appear here in real time.', textAlign: TextAlign.center)])))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: players.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _PlayerTile(player: players[index]),
                ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({required this.player});
  final Player player;
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(14),
          leading: CircleAvatar(
            radius: 27,
            backgroundImage: player.photoUrl.isNotEmpty ? NetworkImage(player.photoUrl) : null,
            child: player.photoUrl.isNotEmpty ? null : Text(player.firstName.isEmpty ? '?' : player.firstName[0].toUpperCase()),
          ),
          title: Text(player.fullName, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('#${player.jerseyNumber} · ${player.position} · ${player.email}'),
          trailing: const Icon(Icons.verified_user_outlined),
        ),
      );
}
