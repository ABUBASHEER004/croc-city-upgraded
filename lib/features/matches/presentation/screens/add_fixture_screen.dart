import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';

class AddFixtureScreen extends StatelessWidget {
  const AddFixtureScreen({super.key});
  @override
  Widget build(BuildContext context) => PremiumFeatureScreen(
    title: 'Add fixture', eyebrow: 'Matchday', description: 'Build a polished fixture record for the academy calendar.', icon: Icons.add_circle_outline_rounded,
    actions: const [
      PremiumFeatureAction(title: 'Match setup', subtitle: 'Home and away teams, date, venue and competition.', icon: Icons.sports_soccer_rounded),
PremiumFeatureAction(title: 'Matchday checklist', subtitle: 'Line-up, officials, venue and squad preparation.', icon: Icons.fact_check_rounded)
    ],
  );
}
