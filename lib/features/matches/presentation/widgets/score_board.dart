import 'package:flutter/material.dart';

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Score Board' : title),
    ),
  );
}
