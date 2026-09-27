import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';

class PlayerStatsScreen extends StatelessWidget {
  const PlayerStatsScreen({super.key});
  @override
  Widget build(BuildContext context) => PremiumFeatureScreen(
    title: 'Player statistics', eyebrow: 'Performance', description: 'A modern performance profile for player development.', icon: Icons.insights_rounded,
    actions: const [
      PremiumFeatureAction(title: 'Development', subtitle: 'Goals, assists, appearances and progression.', icon: Icons.trending_up_rounded),
PremiumFeatureAction(title: 'Performance history', subtitle: 'Make improvement visible across the season.', icon: Icons.show_chart_rounded)
    ],
  );
}
