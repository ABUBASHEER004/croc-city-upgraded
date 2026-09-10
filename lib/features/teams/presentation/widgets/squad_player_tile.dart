
import 'package:flutter/material.dart';

import '../../../players/data/models/player.dart';
import '../../../players/presentation/widgets/player_avatar.dart';

class SquadPlayerTile extends StatelessWidget {
  const SquadPlayerTile({
    super.key,
    required this.player,
    this.onTap,
  });

  final Player player;
  final VoidCallback? onTap;

  String _valueOrDash(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? '—' : trimmed;
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

    final position = _valueOrDash(player.position);
    final registration = _valueOrDash(player.registrationNo);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        leading: _PlayerAvatarWithNumber(
          player: player,
          jerseyNumber: _jerseyNumber(),
        ),
        title: Text(
          player.fullName.trim().isEmpty
              ? 'Unnamed Player'
              : player.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            '$position • $registration',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing: _StatusIndicator(
          active: player.active,
        ),
      ),
    );
  }
}

class _PlayerAvatarWithNumber extends StatelessWidget {
  const _PlayerAvatarWithNumber({
    required this.player,
    required this.jerseyNumber,
  });

  final Player player;
  final String jerseyNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 3,
            child: PlayerAvatar(
              player: player,
              radius: 24,
            ),
          ),
          Positioned(
            right: -2,
            bottom: -1,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 25,
                minHeight: 25,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                jerseyNumber,
                maxLines: 1,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({
    required this.active,
  });

  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: active ? 'Active player' : 'Inactive player',
      child: Icon(
        active ? Icons.check_circle : Icons.cancel,
        size: 22,
        color: active
            ? theme.colorScheme.primary
            : theme.colorScheme.error,
      ),
    );
  }
}

