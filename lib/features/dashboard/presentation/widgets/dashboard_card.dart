import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Dashboard Card' : title),
    ),
  );
}
