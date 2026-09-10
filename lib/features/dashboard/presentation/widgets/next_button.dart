import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  const NextButton({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Next Button' : title),
    ),
  );
}
