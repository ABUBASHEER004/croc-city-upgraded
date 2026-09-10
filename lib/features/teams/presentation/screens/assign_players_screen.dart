import 'package:flutter/material.dart';

class AssignPlayersScreen extends StatelessWidget {
  final String teamId;

  const AssignPlayersScreen({
    super.key,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Players"),
      ),
      body: Center(
        child: Text("Assign Players to Team: $teamId"),
      ),
    );
  }
}