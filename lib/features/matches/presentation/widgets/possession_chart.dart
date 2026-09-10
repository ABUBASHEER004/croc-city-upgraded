import 'package:flutter/material.dart';

class PossessionChart extends StatelessWidget {
  const PossessionChart({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Possession Chart' : title),
    ),
  );
}
