import 'package:flutter/material.dart';

import '../../data/models/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const PlayerCard({
    super.key,
    required this.player,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,

        leading: CircleAvatar(
          radius: 28,
          backgroundImage: player.photoUrl.isNotEmpty
              ? NetworkImage(player.photoUrl)
              : null,
          child: player.photoUrl.isEmpty ? const Icon(Icons.person) : null,
        ),

        title: Text(
          player.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(player.position),
            Text("Jersey #${player.jerseyNumber}"),
          ],
        ),

        trailing: showActions
            ? PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case "edit":
                onEdit?.call();
                break;
              case "delete":
                onDelete?.call();
                break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: "edit", child: Text("Edit")),
            PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
        )
            : null,
      ),
    );
  }
}
