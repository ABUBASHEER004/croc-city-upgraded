import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../teams/presentation/providers/team_provider.dart';
import '../../data/models/player.dart';
import '../providers/player_provider.dart';
import '../widgets/player_avatar.dart';
import '../widgets/player_statistics.dart';

class PlayerDetailsScreen extends StatefulWidget {
  const PlayerDetailsScreen({
    super.key,
    required this.playerId,
  });

  final String playerId;

  @override
  State<PlayerDetailsScreen> createState() =>
      _PlayerDetailsScreenState();
}

class _PlayerDetailsScreenState
    extends State<PlayerDetailsScreen> {
  late Future<Player?> _playerFuture;

  @override
  void initState() {
    super.initState();

    _playerFuture =
        context.read<PlayerProvider>().getPlayer(widget.playerId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final teamProvider = context.read<TeamProvider>();

      if (teamProvider.teams.isEmpty &&
          !teamProvider.loading) {
        teamProvider.listenToTeams();
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _reload() async {
    setState(() {
      _playerFuture =
          context.read<PlayerProvider>().getPlayer(
                widget.playerId,
              );
    });

    await _playerFuture;
  }

  Future<void> _deletePlayer(Player player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Player'),
          content: Text(
            'Are you sure you want to permanently delete '
            '${player.fullName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await context
          .read<PlayerProvider>()
          .deletePlayer(player.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Player deleted successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.go('/players');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete player: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Details'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Player?>(
        future: _playerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final player = snapshot.data;

          if (player == null) {
            return _NotFoundState(
              onBack: () {
                context.go('/players');
              },
            );
          }

          return _PlayerDetailsBody(
            player: player,
            onEdit: () {
              context.push(
                '/players/edit/${player.id}',
              );
            },
            onDelete: () {
              _deletePlayer(player);
            },
            formatDate: _formatDate,
          );
        },
      ),
    );
  }
}

class _PlayerDetailsBody extends StatelessWidget {
  const _PlayerDetailsBody({
    required this.player,
    required this.onEdit,
    required this.onDelete,
    required this.formatDate,
  });

  final Player player;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    final teamProvider =
        context.watch<TeamProvider>();

    final team =
        teamProvider.getTeamById(player.teamId);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        32,
      ),
      children: [
        Center(
          child: PlayerAvatar(
            player: player,
            radius: 58,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          player.fullName,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 4),

        Text(
          player.registrationNo.isEmpty
              ? 'No registration number'
              : player.registrationNo,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
        ),

        const SizedBox(height: 12),

        Center(
          child: Chip(
            avatar: Icon(
              player.active
                  ? Icons.check_circle
                  : Icons.cancel,
              size: 18,
            ),
            label: Text(
              player.active
                  ? 'Active'
                  : 'Inactive',
            ),
          ),
        ),

        const SizedBox(height: 20),

        PlayerStatistics(
          player: player,
          teamName: team?.name,
        ),

        const SizedBox(height: 20),

        _Section(
          title: 'Personal Information',
          icon: Icons.person_outline,
          rows: [
            (
              'Email',
              player.email,
            ),
            (
              'Phone',
              player.phone,
            ),
            (
              'Address',
              player.address,
            ),
            (
              'Gender',
              player.gender,
            ),
            (
              'Date of Birth',
              formatDate(
                player.dateOfBirth,
              ),
            ),
          ],
        ),

        _Section(
          title: 'Parent / Guardian',
          icon: Icons.family_restroom_outlined,
          rows: [
            (
              'Name',
              player.parentName,
            ),
            (
              'Phone',
              player.parentPhone,
            ),
            (
              'Emergency',
              player.emergencyContact,
            ),
          ],
        ),

        _Section(
          title: 'Medical Information',
          icon: Icons.medical_information_outlined,
          rows: [
            (
              'Notes',
              player.medicalNotes.isEmpty
                  ? 'No medical notes provided.'
                  : player.medicalNotes,
            ),
          ],
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
            ),
            label: const Text(
              'Edit Player',
            ),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
            ),
            label: const Text(
              'Delete Player',
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 21,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    title,
                    style: theme
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            ...rows.map(
              (row) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 6,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          row.$1,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: SelectableText(
                          row.$2.trim().isEmpty
                              ? 'Not provided'
                              : row.$2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

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
            const Icon(
              Icons.error_outline,
              size: 56,
            ),

            const SizedBox(height: 12),

            const Text(
              'Unable to load player',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 18),

            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 64,
            ),

            const SizedBox(height: 12),

            const Text(
              'Player not found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'This player may have been deleted '
              'or the ID is invalid.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 18),

            FilledButton.icon(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back,
              ),
              label: const Text(
                'Back to Players',
              ),
            ),
          ],
        ),
      ),
    );
  }
}