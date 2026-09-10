import 'package:flutter/material.dart';

class PlayerPicker extends StatelessWidget {
  const PlayerPicker({super.key, this.title = ''});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.isEmpty ? 'Player Picker' : title),
    ),
  );
}
