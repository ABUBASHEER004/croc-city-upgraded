import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary,
          backgroundImage: const AssetImage(
            "assets/images/logo.jpg",
          ),
        ),

        const SizedBox(height: 20),

        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}