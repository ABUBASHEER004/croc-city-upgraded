import 'package:flutter/material.dart';

class StatisticsCard extends StatelessWidget {
  const StatisticsCard({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Statistics Card' : title),
    ),
  );
}
