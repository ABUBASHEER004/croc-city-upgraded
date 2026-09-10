import 'package:flutter/material.dart';

import '../../data/models/player.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({super.key, required this.player, this.radius = 28});
  final Player player;
  final double radius;
  @override
  Widget build(BuildContext context) {
    final initials = '${player.firstName.isNotEmpty ? player.firstName[0] : ''}${player.lastName.isNotEmpty ? player.lastName[0] : ''}'.toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: player.photoUrl.trim().isNotEmpty ? NetworkImage(player.photoUrl) : null,
      onBackgroundImageError: player.photoUrl.trim().isNotEmpty ? (_, __) {} : null,
      child: player.photoUrl.trim().isEmpty ? Text(initials.isEmpty ? '?' : initials, style: TextStyle(fontSize: radius * .55, fontWeight: FontWeight.bold)) : null,
    );
  }
}
