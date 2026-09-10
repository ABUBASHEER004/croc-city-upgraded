import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../players/data/models/player.dart';
import '../../../players/presentation/providers/player_provider.dart';

class SquadScreen extends StatefulWidget {
  final String teamId;
  final String teamName;

  const SquadScreen({
    super.key,
    required this.teamId,
    required this.teamName,
  });

  @override
  State<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends State<SquadScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<PlayerProvider>();

      if (!provider.loading) {
        provider.startListening();
      }
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Player> _getSquadPlayers(PlayerProvider provider) {
    return provider.players.where((player) {
      // Only players belonging to this team
      if (player.teamId != widget.teamId) {
        return false;
      }

      // Search
      if (_searchQuery.isEmpty) {
        return true;
      }

      final name = player.fullName.toLowerCase();
      final registration =
          player.registrationNo.toLowerCase();
      final position =
          player.position.toLowerCase();

      return name.contains(_searchQuery) ||
          registration.contains(_searchQuery) ||
          position.contains(_searchQuery);
    }).toList();
  }

  void _showPlayerDetails(Player player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildPlayerAvatar(
                      player,
                      radius: 35,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.fullName,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            player.registrationNo,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                _detailRow(
                  Icons.numbers,
                  'Jersey Number',
                  player.jerseyNumber.toString(),
                ),

                _detailRow(
                  Icons.sports_soccer,
                  'Position',
                  player.position,
                ),

                _detailRow(
                  Icons.directions_run,
                  'Preferred Foot',
                  player.preferredFoot,
                ),

                _detailRow(
                  Icons.person,
                  'Gender',
                  player.gender,
                ),

                _detailRow(
                  Icons.cake,
                  'Date of Birth',
                  _formatDate(player.dateOfBirth),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Chip(
                      label: Text(
                        player.active
                            ? 'Active'
                            : 'Inactive',
                      ),
                      avatar: Icon(
                        player.active
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 18,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(
            icon,
            size: 21,
          ),
          const SizedBox(width: 12),
          Text(
            '$title:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value.isEmpty ? 'Not provided' : value),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerAvatar(
    Player player, {
    double radius = 28,
  }) {
    if (player.photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage:
            NetworkImage(player.photoUrl),
      );
    }

    return CircleAvatar(
      radius: radius,
      child: Text(
        player.firstName.isNotEmpty
            ? player.firstName[0].toUpperCase()
            : '?',
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamName),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              context.read<PlayerProvider>().startListening();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: Consumer<PlayerProvider>(
        builder: (context, provider, child) {
          if (provider.loading &&
              provider.players.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final squad =
              _getSquadPlayers(provider);

          return Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Squad',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${squad.length} player${squad.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Search
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            'Search players...',
                        prefixIcon:
                            const Icon(Icons.search),
                        suffixIcon:
                            _searchQuery.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController
                                          .clear();
                                    },
                                    icon: const Icon(
                                      Icons.clear,
                                    ),
                                  )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Squad
              Expanded(
                child: squad.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          provider.startListening();
                        },
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            20,
                          ),
                          itemCount: squad.length,
                          itemBuilder:
                              (context, index) {
                            final player =
                                squad[index];

                            return _buildPlayerCard(
                              player,
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: () {
          _showPlayerDetails(player);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Jersey number
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                ),
                child: Text(
                  player.jerseyNumber
                      .toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Photo
              _buildPlayerAvatar(player),

              const SizedBox(width: 12),

              // Player information
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      player.position.isEmpty
                          ? 'Position not set'
                          : player.position,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      player.registrationNo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // Active indicator
              Column(
                children: [
                  Icon(
                    player.active
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 20,
                  ),
                  const SizedBox(height: 5),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch =
        _searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch
                  ? Icons.search_off
                  : Icons.groups_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 15),

            Text(
              hasSearch
                  ? 'No players found'
                  : 'No players in this squad',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              hasSearch
                  ? 'Try a different player name, registration number or position.'
                  : 'Players assigned to this team will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}