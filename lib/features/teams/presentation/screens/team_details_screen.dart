import 'package:flutter/material.dart';

class TeamDetailsScreen extends StatelessWidget {
  final String teamId;

  const TeamDetailsScreen({
    super.key,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Team Details"),
      ),
      body: Center(
        child: Text("Team ID: $teamId"),
      ),
    );
  }
}