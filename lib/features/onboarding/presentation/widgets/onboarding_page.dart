import 'package:flutter/material.dart';

import '../../models/onboarding_item.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [

        Image.asset(
          item.image,
          fit: BoxFit.cover,
        ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(.15),
                Colors.black.withOpacity(.65),
              ],
            ),
          ),
        ),

        Positioned(
          left: 30,
          right: 30,
          bottom: 180,
          child: Column(
            children: [
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}