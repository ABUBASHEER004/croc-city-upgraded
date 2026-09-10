import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor:
                  color.withOpacity(.15),
              child: Icon(icon, color: color),
            ),

            const SizedBox(height: 15),

            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),

            Text(title),
          ],
        ),
      ),
    );
  }
}