import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Notification Tile' : title),
    ),
  );
}
