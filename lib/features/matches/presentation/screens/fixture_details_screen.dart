import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';

class FixtureDetailsScreen extends StatelessWidget {
  const FixtureDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) => PremiumFeatureScreen(
    title: 'Fixture details', eyebrow: 'Matchday', description: 'A premium matchday view for venue, teams, timing and live status.', icon: Icons.sports_soccer_rounded,
    actions: const [
      PremiumFeatureAction(title: 'Match centre', subtitle: 'Bring all fixture information into one focused view.', icon: Icons.stadium_rounded),
PremiumFeatureAction(title: 'Squad & lineup', subtitle: 'Prepare players and matchday roles.', icon: Icons.groups_rounded)
    ],
  );
}
