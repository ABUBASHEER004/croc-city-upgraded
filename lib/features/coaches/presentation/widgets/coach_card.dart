
import 'package:flutter/material.dart';

import '../../data/models/coach.dart';

class CoachCard extends StatelessWidget {
  const CoachCard({
    super.key,
    required this.coach,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Coach coach;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    coach.photoUrl.isNotEmpty ? NetworkImage(coach.photoUrl) : null,
                child: coach.photoUrl.isEmpty
                    ? const Icon(Icons.sports, size: 30)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(coach.fullName.isEmpty ? 'Unnamed Coach' : coach.fullName,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(coach.specialty),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(Icons.verified_outlined,
                            size: 15,
                            color: coach.active
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline),
                        const SizedBox(width: 4),
                        Text(coach.active ? 'Active' : 'Inactive'),
                        if (coach.experience.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.schedule_outlined,
                              size: 15, color: theme.colorScheme.outline),
                          const SizedBox(width: 4),
                          Text(coach.experience),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
