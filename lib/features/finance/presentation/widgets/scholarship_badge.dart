import 'package:flutter/material.dart';

class ScholarshipBadge extends StatelessWidget {
  const ScholarshipBadge({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Scholarship Badge' : title),
    ),
  );
}
