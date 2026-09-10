import 'package:flutter/material.dart';

class LiveMatchScreen extends StatelessWidget {
  const LiveMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Match Screen')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Live Match Screen is ready for academy data integration.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
