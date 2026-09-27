import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';

class MatchSummaryScreen extends StatelessWidget {
  const MatchSummaryScreen({super.key});
  @override
  Widget build(BuildContext context) => PremiumFeatureScreen(
    title: 'Match summary', eyebrow: 'Post-match', description: 'Present the final score and performance story beautifully.', icon: Icons.summarize_rounded,
    actions: const [
      PremiumFeatureAction(title: 'Performance', subtitle: 'Capture the result and major match statistics.', icon: Icons.analytics_rounded),
PremiumFeatureAction(title: 'Player impact', subtitle: 'Highlight standout contributions from the squad.', icon: Icons.emoji_events_rounded)
    ],
  );
}
