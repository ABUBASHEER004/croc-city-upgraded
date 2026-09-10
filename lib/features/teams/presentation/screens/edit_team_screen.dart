import 'package:flutter/material.dart';

class EditTeamScreen extends StatelessWidget {
  final String teamId;

  const EditTeamScreen({
    super.key,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Team"),
      ),
      body: Center(
        child: Text("Editing Team: $teamId"),
      ),
    );
  }
}