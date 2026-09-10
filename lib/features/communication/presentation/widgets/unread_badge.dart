import 'package:flutter/material.dart';

class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Unread Badge' : title),
    ),
  );
}
