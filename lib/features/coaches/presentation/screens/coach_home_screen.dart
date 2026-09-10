import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../models/app_user.dart';
import '../../../players/presentation/providers/player_provider.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key, required this.user});
  final AppUser user;

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PlayerProvider>().listenToCoach(widget.user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final players = context.watch<PlayerProvider>().players;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Hub'),
        actions: [
          IconButton(onPressed: () => context.push('/profile'), icon: const Icon(Icons.person_outline)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => context.read<PlayerProvider>().listenToCoach(widget.user.uid),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer]),
              ),
              child: Row(children: [
                CircleAvatar(radius: 30, child: Text(widget.user.firstName.isEmpty ? 'C' : widget.user.firstName[0].toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('COACH WORKSPACE', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(widget.user.fullName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('Your squad, schedule and attendance — one place.'),
                ])),
              ]),
            ),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: _Metric(icon: Icons.groups_outlined, value: players.length.toString(), label: 'My players')),
              const SizedBox(width: 10),
              const Expanded(child: _Metric(icon: Icons.event_note_outlined, value: 'Live', label: 'Schedules')),
              const SizedBox(width: 10),
              const Expanded(child: _Metric(icon: Icons.campaign_outlined, value: 'Live', label: 'Updates')),
            ]),
            const SizedBox(height: 24),
            Text('Coaching tools', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            _Action(icon: Icons.groups_outlined, title: 'My players', subtitle: 'Identify and manage your assigned squad', onTap: () => context.push('/coach/players')),
            _Action(icon: Icons.fact_check_outlined, title: 'Attendance', subtitle: 'Mark Present, Absent, Late or Excused', onTap: () => context.push('/attendance')),
            _Action(icon: Icons.calendar_month_outlined, title: 'Training schedule', subtitle: 'Create and publish sessions for your players', onTap: () => context.push('/training')),
            _Action(icon: Icons.sports_soccer_outlined, title: 'Fixtures', subtitle: 'Create and track matchday fixtures', onTap: () => context.push('/fixtures')),
            _Action(icon: Icons.campaign_outlined, title: 'Academy announcements', subtitle: 'Stay aligned with academy-wide updates', onTap: () => context.push('/announcements')),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8), child: Column(children: [Icon(icon), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall)])));
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6), leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right), onTap: onTap));
}
