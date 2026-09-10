import 'package:flutter/material.dart';

class EmptyPlayersWidget extends StatelessWidget {
  const EmptyPlayersWidget({
    super.key,
    this.searchQuery = '',
    this.onAdd,
  });

  final String searchQuery;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final searching = searchQuery.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              searching ? Icons.search_off : Icons.people_outline,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text(
              searching ? 'No Players Found' : 'No Players Yet',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              searching
                  ? 'Try a different search term.'
                  : 'Register your first player to get started.',
              textAlign: TextAlign.center,
            ),
            if (!searching && onAdd != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Add Player'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
