import 'package:flutter/material.dart';

class MatchTimer extends StatelessWidget {
  const MatchTimer({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Match Timer' : title),
    ),
  );
}
