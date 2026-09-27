import '../../../calendar/presentation/widgets/academy_calendar_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/app_user.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';
import 'parent_children_screen.dart';
import '../../../communication/presentation/widgets/notification_bell.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Portal'), actions: [
          const NotificationBell(),IconButton(onPressed: () => context.push('/profile'), icon: const Icon(Icons.person_outline_rounded))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(18, 10, 18, 32), children: [
        PremiumHero(eyebrow: 'Family & Player Care', title: 'Stay close to every milestone.', subtitle: 'Follow your children’s academic progress, player development, results, announcements and academy finances.', image: 'assets/images/football.jpg', icon: Icons.family_restroom_rounded),
        const SizedBox(height: 16),
        const AcademyCalendarCard(compact: true),
        const SizedBox(height: 18),
        Row(children: [Expanded(child: PremiumStat(value: 'LIVE', label: 'Academy updates', icon: Icons.notifications_active_rounded)), const SizedBox(width: 10), Expanded(child: PremiumStat(value: '24/7', label: 'Portal access', icon: Icons.lock_clock_rounded))]),
        const SizedBox(height: 22),
        PremiumSection(title: 'Your academy tools', child: Column(children: [
          _PortalCard(icon: Icons.groups_rounded, title: 'Your children', subtitle: 'Students, players and published results', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ParentChildrenScreen(user: user)))),
          _PortalCard(icon: Icons.sports_soccer_rounded, title: 'Fixtures & matchday', subtitle: 'Upcoming matches, venues and results', onTap: () => context.push('/fixtures')),
          _PortalCard(icon: Icons.campaign_rounded, title: 'Announcements', subtitle: 'Important academy communications', onTap: () => context.push('/announcements')),
          _PortalCard(icon: Icons.account_balance_wallet_rounded, title: 'Fees & payments', subtitle: 'Track invoices, payments and scholarships', onTap: () => context.push('/finance')),
        ])),
      ]),
    );
  }
}

class _PortalCard extends StatelessWidget {
  const _PortalCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8), leading: Container(width: 46, height: 46, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(.08), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: Theme.of(context).colorScheme.primary)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15), onTap: onTap));
}
