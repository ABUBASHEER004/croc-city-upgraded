import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});
  @override
  Widget build(BuildContext context) => PremiumFeatureScreen(
    title: 'Conversations', eyebrow: 'Communication', description: 'A premium inbox for academy conversations and unread messages.', icon: Icons.forum_rounded,
    actions: const [
      PremiumFeatureAction(title: 'Priority inbox', subtitle: 'Keep important conversations easy to find.', icon: Icons.mark_chat_unread_rounded),
PremiumFeatureAction(title: 'People', subtitle: 'Connect with coaches, players and families.', icon: Icons.people_alt_rounded)
    ],
  );
}
