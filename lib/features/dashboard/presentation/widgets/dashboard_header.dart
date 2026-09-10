import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String name;
  final String role;

  const DashboardHeader({
    super.key,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          child: Icon(Icons.person),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome Back",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),

              Text(role),
            ],
          ),
        ),

        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {},
        ),
      ],
    );
  }
}