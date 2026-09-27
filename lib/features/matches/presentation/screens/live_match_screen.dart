import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';

class LiveMatchScreen extends StatelessWidget {
  const LiveMatchScreen({super.key});
  @override
  Widget build(BuildContext context) => PremiumFeatureScreen(
    title: 'Live match centre', eyebrow: 'Live match', description: 'A focused matchday cockpit for score, events and momentum.', icon: Icons.live_tv_rounded,
    actions: const [
      PremiumFeatureAction(title: 'Scoreboard', subtitle: 'Keep score and match status prominent.', icon: Icons.scoreboard_rounded),
PremiumFeatureAction(title: 'Match events', subtitle: 'Goals, cards, substitutions and key moments.', icon: Icons.bolt_rounded)
    ],
  );
}
