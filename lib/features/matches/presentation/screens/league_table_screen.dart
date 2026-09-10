import 'package:flutter/material.dart';

class LeagueTableScreen extends StatelessWidget {
  const LeagueTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('League Table Screen')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'League Table Screen is ready for academy data integration.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
