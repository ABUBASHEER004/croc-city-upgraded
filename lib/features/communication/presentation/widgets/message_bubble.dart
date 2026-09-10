import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Message Bubble' : title),
    ),
  );
}
