import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';

class LeagueTableScreen extends StatelessWidget {
  const LeagueTableScreen({super.key});
  @override
  Widget build(BuildContext context) => PremiumFeatureScreen(
    title: 'League table', eyebrow: 'Competition', description: 'Track position, form and points across the season.', icon: Icons.leaderboard_rounded,
    actions: const [
      PremiumFeatureAction(title: 'Standings', subtitle: 'Wins, draws, losses, points and goal difference.', icon: Icons.table_chart_rounded),
PremiumFeatureAction(title: 'Season form', subtitle: 'Keep the academy performance story visible.', icon: Icons.trending_up_rounded)
    ],
  );
}
