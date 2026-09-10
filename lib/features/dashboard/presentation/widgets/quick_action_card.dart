import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),

              const SizedBox(height: 12),

              Text(
                title,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}