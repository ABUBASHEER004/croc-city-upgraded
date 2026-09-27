import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) => PremiumFeatureScreen(
    title: 'Team chat', eyebrow: 'Communication', description: 'Keep coaches, players and families connected in one calm workspace.', icon: Icons.chat_bubble_rounded,
    actions: const [
      PremiumFeatureAction(title: 'Direct conversations', subtitle: 'Simple, focused communication between academy members.', icon: Icons.forum_rounded),
PremiumFeatureAction(title: 'Media & updates', subtitle: 'Share important matchday and training information.', icon: Icons.perm_media_rounded)
    ],
  );
}
