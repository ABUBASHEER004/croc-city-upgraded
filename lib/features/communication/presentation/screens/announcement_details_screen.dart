import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';

class AnnouncementDetailsScreen extends StatelessWidget {
  const AnnouncementDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) => PremiumFeatureScreen(
    title: 'Announcement details', eyebrow: 'Academy news', description: 'A distraction-free reading view for important academy communications.', icon: Icons.article_rounded,
    actions: const [
      PremiumFeatureAction(title: 'Rich updates', subtitle: 'Keep the message, timing and audience clear.', icon: Icons.article_outlined),
PremiumFeatureAction(title: 'Action points', subtitle: 'Turn important announcements into next steps.', icon: Icons.task_alt_rounded)
    ],
  );
}
