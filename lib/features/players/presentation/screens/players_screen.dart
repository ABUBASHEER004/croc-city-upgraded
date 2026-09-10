import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/player.dart';
import '../providers/player_provider.dart';
import '../widgets/empty_players_widget.dart';
import '../widgets/loading_players_widget.dart';
import '../widgets/player_card.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PlayerProvider>().startListening();
    });
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final players = provider.players.where((player) {
      if (_query.isEmpty) return true;
      return player.fullName.toLowerCase().contains(_query) ||
          player.registrationNo.toLowerCase().contains(_query) ||
          player.position.toLowerCase().contains(_query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Players'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: provider.loading
                ? null
                : () => provider.startListening(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'players_fab',
        onPressed: () => context.push('/players/add'),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Player'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, registration or position',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _searchController.clear,
                        icon: const Icon(Icons.clear),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildBody(provider, players),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PlayerProvider provider, List<Player> players) {
    if (provider.loading && provider.players.isEmpty) {
      return const LoadingPlayersWidget();
    }

    if (provider.error != null && provider.players.isEmpty) {
      return _ErrorView(
        message: provider.error!,
        onRetry: provider.startListening,
      );
    }

    if (players.isEmpty) {
      return EmptyPlayersWidget(
        searchQuery: _query,
        onAdd: () => context.push('/players/add'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => provider.startListening(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100, top: 8),
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          return PlayerCard(
            player: player,
            onTap: () => context.push('/players/details/${player.id}'),
            onEdit: () => context.push('/players/edit/${player.id}'),
            onDelete: () => _deletePlayer(player.id, player.fullName),
          );
        },
      ),
    );
  }

  Future<void> _deletePlayer(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Delete $name permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<PlayerProvider>().deletePlayer(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete player: $e')),
      );
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 12),
            const Text(
              'Unable to load players',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
