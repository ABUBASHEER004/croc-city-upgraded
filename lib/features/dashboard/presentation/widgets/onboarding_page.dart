import 'package:flutter/material.dart';

import '../../../onboarding/models/onboarding_item.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Expanded(
            child: Image.asset(
              item.image,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 40),

          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.black54,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}