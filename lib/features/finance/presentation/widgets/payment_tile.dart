import 'package:flutter/material.dart';

class PaymentTile extends StatelessWidget {
  const PaymentTile({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Payment Tile' : title),
    ),
  );
}
