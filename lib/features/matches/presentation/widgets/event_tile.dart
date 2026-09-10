import 'package:flutter/material.dart';

class EventTile extends StatelessWidget {
  const EventTile({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Event Tile' : title),
    ),
  );
}
