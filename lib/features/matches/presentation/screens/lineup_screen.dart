import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';

class LineupScreen extends StatelessWidget {
  const LineupScreen({super.key});
  @override
  Widget build(BuildContext context) => PremiumFeatureScreen(
    title: 'Lineup builder', eyebrow: 'Matchday', description: 'Create a clear, tactical starting XI and bench experience.', icon: Icons.view_quilt_rounded,
    actions: const [
      PremiumFeatureAction(title: 'Starting XI', subtitle: 'Assign players to the matchday formation.', icon: Icons.groups_rounded),
PremiumFeatureAction(title: 'Bench & roles', subtitle: 'Manage substitutes and player responsibilities.', icon: Icons.swap_vertical_circle_rounded)
    ],
  );
}
