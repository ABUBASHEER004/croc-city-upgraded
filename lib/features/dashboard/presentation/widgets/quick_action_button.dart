import 'package:flutter/material.dart';

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Quick Action Button' : title),
    ),
  );
}
