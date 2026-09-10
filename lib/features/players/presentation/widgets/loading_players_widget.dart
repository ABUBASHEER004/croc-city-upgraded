import 'package:flutter/material.dart';

class LoadingPlayersWidget extends StatelessWidget {
  const LoadingPlayersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}