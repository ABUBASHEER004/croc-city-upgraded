import 'package:flutter/material.dart';

class FixtureDetailsScreen extends StatelessWidget {
  const FixtureDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fixture Details Screen')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Fixture Details Screen is ready for academy data integration.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
