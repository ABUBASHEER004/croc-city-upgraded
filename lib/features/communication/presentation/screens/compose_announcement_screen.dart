import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';

class ComposeAnnouncementScreen extends StatelessWidget {
  const ComposeAnnouncementScreen({super.key});
  @override
  Widget build(BuildContext context) => PremiumFeatureScreen(
    title: 'Create announcement', eyebrow: 'Communication', description: 'Publish polished academy-wide updates with clarity and impact.', icon: Icons.campaign_rounded,
    actions: const [
      PremiumFeatureAction(title: 'Audience', subtitle: 'Target players, parents, coaches or the whole academy.', icon: Icons.groups_rounded),
PremiumFeatureAction(title: 'Publishing', subtitle: 'Schedule, publish and manage important notices.', icon: Icons.publish_rounded)
    ],
  );
}
