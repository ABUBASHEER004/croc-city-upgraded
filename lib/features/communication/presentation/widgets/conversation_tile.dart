import 'package:flutter/material.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Conversation Tile' : title),
    ),
  );
}
