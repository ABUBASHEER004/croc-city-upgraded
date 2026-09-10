import 'package:flutter/material.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoices Screen')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Invoices Screen is ready for academy data integration.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
