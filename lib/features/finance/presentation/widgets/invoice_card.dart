import 'package:flutter/material.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Invoice Card' : title),
    ),
  );
}
