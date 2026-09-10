import 'package:flutter/material.dart';

class LineupCard extends StatelessWidget {
  const LineupCard({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Lineup Card' : title),
    ),
  );
}
