import 'package:flutter/material.dart';

import '../../data/models/team.dart';

class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.team,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Team team;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.green.shade100,
                child: const Icon(
                  Icons.sports_soccer,
                  color: Colors.green,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      team.ageGroup,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      team.category,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == "edit") {
                    onEdit();
                  } else if (value == "delete") {
                    onDelete();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: "edit",
                    child: Text("Edit"),
                  ),
                  PopupMenuItem(
                    value: "delete",
                    child: Text("Delete"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}