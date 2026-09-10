import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/team_provider.dart';
import '../widgets/team_card.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamProvider>().listenToTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeamProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'teams_fab',
        onPressed: () => context.push('/teams/add'),
        child: const Icon(Icons.add),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(TeamProvider provider) {
    if (provider.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null && provider.error!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            provider.error!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (provider.teams.isEmpty) {
      return const Center(
        child: Text(
          'No teams available.\nTap + to create your first team.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.listenToTeams();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.teams.length,
        itemBuilder: (context, index) {
          final team = provider.teams[index];

          return TeamCard(
            team: team,
            onTap: () {
              context.push('/teams/details/${team.id}');
            },
            onEdit: () {
              context.push('/teams/edit/${team.id}');
            },
            onDelete: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Team'),
                  content: Text(
                    'Are you sure you want to delete "${team.name}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await provider.deleteTeam(team.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${team.name} deleted successfully.',
                      ),
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}