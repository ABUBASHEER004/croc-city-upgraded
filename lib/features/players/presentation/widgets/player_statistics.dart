import 'package:flutter/material.dart';

import '../../data/models/player.dart';

class PlayerStatistics extends StatelessWidget {
  const PlayerStatistics({
    super.key,
    required this.player,
    this.teamName,
  });

  final Player player;
  final String? teamName;

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '—';
    }

    return value.trim();
  }

  String _jerseyNumber() {
    if (player.jerseyNumber <= 0) {
      return '—';
    }

    return player.jerseyNumber.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final statistics = <_StatisticItem>[
      _StatisticItem(
        label: 'Jersey',
        value: _jerseyNumber(),
        icon: Icons.numbers,
      ),
      _StatisticItem(
        label: 'Position',
        value: _displayValue(player.position),
        icon: Icons.sports_soccer,
      ),
      _StatisticItem(
        label: 'Team',
        value: _displayValue(
          teamName?.trim().isNotEmpty == true
              ? teamName
              : player.teamId,
        ),
        icon: Icons.groups,
      ),
      _StatisticItem(
        label: 'Preferred Foot',
        value: _displayValue(player.preferredFoot),
        icon: Icons.directions_run,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Use one column on very narrow screens.
        final crossAxisCount = width < 360 ? 1 : 2;

        final aspectRatio = width < 360 ? 4.5 : 2.4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: statistics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) {
            final item = statistics[index];

            return _StatisticCard(
              item: item,
              theme: theme,
            );
          },
        );
      },
    );
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.item,
    required this.theme,
  });

  final _StatisticItem item;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                size: 21,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticItem {
  const _StatisticItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}