
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../models/app_user.dart';
import '../../../calendar/presentation/widgets/academy_calendar_card.dart';
import '../../../players/presentation/providers/player_provider.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';
import '../../../communication/presentation/widgets/notification_bell.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  @override
  State<CoachHomeScreen> createState() =>
      _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<PlayerProvider>()
          .listenToCoach(widget.user.uid);
    });
  }

  Future<void> _refreshPlayers() async {
    if (!mounted) return;

    context
        .read<PlayerProvider>()
        .listenToCoach(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final players =
        context.watch<PlayerProvider>().players;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Hub'),
        actions: <Widget>[
          const NotificationBell(),
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              context.push('/profile');
            },
            icon: const Icon(
              Icons.person_outline_rounded,
            ),
          ),
        ],
      ),
      body: PremiumDashboardBackground(
        child: RefreshIndicator(
          onRefresh: _refreshPlayers,
          child: ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              18,
              10,
              18,
              32,
            ),
            children: <Widget>[
              PremiumHero(
                eyebrow: 'Coach Workspace',
                title:
                    'Lead the squad. Shape champions.',
                subtitle:
                    'Everything you need to coach, communicate and measure player development.',
                image:
                    'assets/images/coach_placeholder.jpg',
                icon: Icons.sports_rounded,
              ),

              const SizedBox(height: 16),

              // Academy calendar
              const AcademyCalendarCard(
                compact: true,
              ),

              const SizedBox(height: 18),

              // Squad statistics
              Row(
                children: <Widget>[
                  Expanded(
                    child: PremiumStat(
                      value: '${players.length}',
                      label: 'Squad players',
                      icon: Icons.groups_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: PremiumStat(
                      value: 'LIVE',
                      label: 'Training feed',
                      icon:
                          Icons.fitness_center_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Coaching tools
              PremiumSection(
                title: 'Coaching tools',
                child: Column(
                  children: <Widget>[
                    _Action(
                      icon: Icons.groups_rounded,
                      title: 'My players',
                      subtitle:
                          'Review your assigned squad and player profiles',
                      onTap: () {
                        context.push(
                          '/coach/players',
                        );
                      },
                    ),

                    _Action(
                      icon: Icons.fact_check_rounded,
                      title: 'Attendance',
                      subtitle:
                          'Mark attendance and monitor consistency',
                      onTap: () {
                        context.push(
                          '/attendance',
                        );
                      },
                    ),

                    _Action(
                      icon:
                          Icons.fitness_center_rounded,
                      title: 'Training centre',
                      subtitle:
                          'Plan sessions and publish schedules',
                      onTap: () {
                        context.push(
                          '/training',
                        );
                      },
                    ),

                    _Action(
                      icon:
                          Icons.sports_soccer_rounded,
                      title: 'Fixtures',
                      subtitle:
                          'Prepare and manage matchday fixtures',
                      onTap: () {
                        context.push(
                          '/fixtures',
                        );
                      },
                    ),

                    _Action(
                      icon: Icons.campaign_rounded,
                      title: 'Announcements',
                      subtitle:
                          'Stay aligned with academy communications',
                      onTap: () {
                        context.push(
                          '/announcements',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 7,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colorScheme.primary
                .withValues(alpha: 0.08),
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
        ),
        onTap: onTap,
      ),
    );
  }
}
