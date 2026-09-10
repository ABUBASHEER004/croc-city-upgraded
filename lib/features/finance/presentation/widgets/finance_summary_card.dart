import 'package:flutter/material.dart';

class FinanceSummaryCard extends StatelessWidget {
  const FinanceSummaryCard({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Finance Summary Card' : title),
    ),
  );
}
