import '../../../calendar/presentation/widgets/academy_calendar_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../presentation/providers/auth_provider.dart';
import '../../../communication/data/announcement_service.dart';
import '../../../communication/models/announcement.dart';
import '../../../matches/data/fixture_firestore_service.dart';
import '../../../matches/models/fixture.dart';
import '../../../players/presentation/providers/player_provider.dart';
import '../../../teams/presentation/providers/team_provider.dart';
import '../../../coaches/presentation/providers/coach_provider.dart';
import '../../../training/data/models/training_session.dart';
import '../../../training/data/training_service.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/premium_ui.dart';
import '../../../../constants/app_colors.dart';
import '../../../communication/presentation/widgets/notification_bell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TrainingService _training = TrainingService();
  final AnnouncementService _announcements = AnnouncementService();
  final FixtureFirestoreService _fixtures = FixtureFirestoreService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PlayerProvider>().startListening();
      context.read<TeamProvider>().listenToTeams();
      context.read<CoachProvider>().listenToCoaches();
    });
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    context.read<PlayerProvider>().startListening();
    context.read<TeamProvider>().listenToTeams();
    context.read<CoachProvider>().listenToCoaches();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final players = context.watch<PlayerProvider>().players;
    final teams = context.watch<TeamProvider>().teams;
    final coaches = context.watch<CoachProvider>().coaches;

    final displayName =
        user?.fullName.trim().isNotEmpty == true ? user!.fullName : 'Administrator';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academy Command Centre'),
        actions: [
          const NotificationBell(),
          IconButton(
            tooltip: 'Announcements',
            onPressed: () => context.push('/announcements'),
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      drawer: _AdminDrawer(userName: displayName),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            PremiumHero(eyebrow: 'Croc City Football Academy', title: 'Run the academy. Build the future.', subtitle: 'Your premium command centre for players, teams, coaches, matchday, training and finance.', image: 'assets/images/stadium.jpg', icon: Icons.shield_rounded),
            const SizedBox(height: 18),
            const AcademyCalendarCard(),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;
                final children = <Widget>[
                  PremiumStat(value: players.length.toString(), label: 'Registered players', icon: Icons.people_alt_rounded),
                  PremiumStat(value: teams.length.toString(), label: 'Active teams', icon: Icons.groups_rounded),
                  PremiumStat(value: coaches.length.toString(), label: 'Coaching staff', icon: Icons.sports_soccer_rounded),
                ];

                if (compact) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: children[0]),
                          const SizedBox(width: 10),
                          Expanded(child: children[1]),
                        ],
                      ),
                      const SizedBox(height: 10),
                      children[2],
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: children[0]),
                    const SizedBox(width: 10),
                    Expanded(child: children[1]),
                    const SizedBox(width: 10),
                    Expanded(child: children[2]),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Management shortcuts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Shortcut(
                  icon: Icons.person_add_alt_1,
                  label: 'Add player',
                  onTap: () => context.push('/players/add'),
                ),
                _Shortcut(
                  icon: Icons.calendar_month_outlined,
                  label: 'Add fixture',
                  onTap: () => context.push('/fixtures'),
                ),
                _Shortcut(
                  icon: Icons.fitness_center_outlined,
                  label: 'Training',
                  onTap: () => context.push('/training'),
                ),
                _Shortcut(
                  icon: Icons.campaign_outlined,
                  label: 'Announcement',
                  onTap: () => context.push('/announcements'),
                ),
                _Shortcut(
                  icon: Icons.fact_check_outlined,
                  label: 'Attendance',
                  onTap: () => context.push('/attendance'),
                ),
                _Shortcut(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Finance',
                  onTap: () => context.push('/finance'),
                ),
              ],
            ),
            ])),
            const SizedBox(height: 20),
            _LivePanel<TrainingSession>(
              title: 'Training schedule',
              icon: Icons.fitness_center_outlined,
              stream: _training.watchSessions(),
              empty: 'No training sessions published yet.',
              builder: (items) => items
                  .take(3)
                  .map(
                    (session) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.sports_soccer_outlined),
                      ),
                      title: Text(
                        session.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${DateFormat('EEE, d MMM · h:mm a').format(session.scheduledAt)}'
                        ' · ${session.teamName}',
                      ),
                    ),
                  )
                  .toList(),
            ),
            _LivePanel<Fixture>(
              title: 'Upcoming fixtures',
              icon: Icons.sports_soccer_outlined,
              stream: _fixtures.watchFixtures(),
              empty: 'No fixtures published yet.',
              builder: (items) => items
                  .take(3)
                  .map(
                    (fixture) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Icon(
                          fixture.isLive
                              ? Icons.play_arrow
                              : Icons.calendar_today_outlined,
                        ),
                      ),
                      title: Text(
                        '${fixture.homeTeam} vs ${fixture.awayTeam}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${DateFormat('EEE, d MMM · h:mm a').format(fixture.date)}'
                        ' · ${fixture.venue.isEmpty ? 'Venue TBA' : fixture.venue}',
                      ),
                    ),
                  )
                  .toList(),
            ),
            _LivePanel<Announcement>(
              title: 'Latest announcements',
              icon: Icons.campaign_outlined,
              stream: _announcements.watchAnnouncements(),
              empty: 'No announcements published yet.',
              builder: (items) => items
                  .where((announcement) => announcement.active)
                  .take(3)
                  .map(
                    (announcement) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.campaign_outlined),
                      ),
                      title: Text(
                        announcement.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        announcement.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer({required this.userName});

  final String userName;

  void _go(BuildContext context, String route) {
    Navigator.of(context).pop();
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: const Text('Academy Administrator'),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.shield_outlined, size: 32),
            ),
          ),
          _Item(
            icon: Icons.dashboard_outlined,
            label: 'Command centre',
            onTap: () => Navigator.of(context).pop(),
          ),
          _Item(
            icon: Icons.people_outline,
            label: 'Players',
            onTap: () => _go(context, '/players'),
          ),
          _Item(
            icon: Icons.groups_outlined,
            label: 'Teams',
            onTap: () => _go(context, '/teams'),
          ),
          _Item(
            icon: Icons.sports_outlined,
            label: 'Coaches',
            onTap: () => _go(context, '/coaches'),
          ),
          _Item(
            icon: Icons.calendar_month_outlined,
            label: 'Fixtures',
            onTap: () => _go(context, '/fixtures'),
          ),
          _Item(
            icon: Icons.fitness_center_outlined,
            label: 'Training',
            onTap: () => _go(context, '/training'),
          ),
          _Item(
            icon: Icons.fact_check_outlined,
            label: 'Attendance',
            onTap: () => _go(context, '/attendance'),
          ),
          _Item(
            icon: Icons.campaign_outlined,
            label: 'Announcements',
            onTap: () => _go(context, '/announcements'),
          ),
          _Item(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Finance',
            onTap: () => _go(context, '/finance'),
          ),
          _Item(
            icon: Icons.family_restroom_outlined,
            label: 'Parents & guardians',
            onTap: () => _go(context, '/parents'),
          ),
          const Divider(),
          _Item(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => _go(context, '/settings'),
          ),
          _Item(
            icon: Icons.logout,
            label: 'Sign out',
            onTap: () async {
              Navigator.of(context).pop();
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _LivePanel<T> extends StatelessWidget {
  const _LivePanel({
    required this.title,
    required this.icon,
    required this.stream,
    required this.builder,
    required this.empty,
  });

  final String title;
  final String empty;
  final IconData icon;
  final Stream<List<T>> stream;
  final List<Widget> Function(List<T>) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) {
        final items = snapshot.data ?? <T>[];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(child: Icon(icon)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (snapshot.hasError)
                  const Text('Unable to load live data right now.')
                else if (snapshot.connectionState == ConnectionState.waiting &&
                    items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  )
                else if (items.isEmpty)
                  Text(empty)
                else
                  ...builder(items),
              ],
            ),
          ),
        );
      },
    );
  }
}
