import '../../../calendar/presentation/widgets/academy_calendar_card.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/app_user.dart';
import '../../../attendance/data/attendance_service.dart';
import '../../../communication/data/announcement_service.dart';
import '../../../communication/models/announcement.dart';
import '../../../matches/data/fixture_firestore_service.dart';
import '../../../matches/models/fixture.dart';
import '../../../players/data/models/player.dart';
import '../../../players/presentation/providers/player_provider.dart';
import '../../../players/data/player_result_service.dart';
import '../../../training/data/models/training_session.dart';
import '../../../training/data/training_service.dart';
import '../widgets/premium_ui.dart';
import '../../../../constants/app_colors.dart';
import '../../../communication/presentation/widgets/notification_bell.dart';

class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  final TrainingService _training = TrainingService();
  final AnnouncementService _announcements = AnnouncementService();
  final FixtureFirestoreService _fixtures = FixtureFirestoreService();
  final AttendanceService _attendance = AttendanceService();
  final PlayerResultService _results = PlayerResultService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<PlayerProvider>()
          .listenToPlayerByEmail(widget.user.email);
    });
  }

  Future<void> _refresh() async {
    if (!mounted) return;

    context
        .read<PlayerProvider>()
        .listenToPlayerByEmail(widget.user.email);
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final player =
        playerProvider.players.isEmpty ? null : playerProvider.players.first;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Dashboard'),
        actions: [
          const NotificationBell(),
          IconButton(
            onPressed: () => context.push('/player/coach'),
            icon: const Icon(Icons.sports_outlined),
            tooltip: 'Choose coach',
          ),
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: PremiumDashboardBackground(
        child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _PlayerHeader(
              user: widget.user,
              player: player,
            ),
            const AcademyCalendarCard(compact: true),
            const SizedBox(height: 18),

            if (player != null && player.coachId.isEmpty) ...[
              const SizedBox(height: 14),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_search_outlined),
                  ),
                  title: const Text(
                    'Choose your coach',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: const Text(
                    'Select the coach responsible for your development.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/player/coach'),
                ),
              ),
            ],

            const SizedBox(height: 22),

            Text(
              'Your live academy feed',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 10),

            if (player == null)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'Ask the academy administrator to add your sign-in email '
                    'to your player profile. Once linked, your coach, '
                    'attendance and squad information will appear here '
                    'automatically.',
                  ),
                ),
              )
            else ...[
              _LiveTraining(
                stream: _training.watchSessions(),
                player: player,
              ),
              _LiveFixtures(
                stream: _fixtures.watchFixtures(),
                player: player,
              ),
              _LiveAttendance(
                stream: _attendance.watchPlayerAttendance(player.id),
              ),
              _LiveAnnouncements(
                stream: _announcements.watchForUser(audience: 'Players', email: widget.user.email),
              ),
              _LiveResults(stream: _results.watchResults(player.id)),
            ],
          ],
        ),
        ),
      ),
    );
  }
}


class _LiveResults extends StatelessWidget {
  const _LiveResults({required this.stream});
  final Stream<List<Map<String, dynamic>>> stream;
  @override
  Widget build(BuildContext context) => StreamBuilder<List<Map<String, dynamic>>>(stream: stream, builder: (context, snapshot) {
    final results = snapshot.data ?? const <Map<String, dynamic>>[];
    return _Section(icon: Icons.assessment_rounded, title: 'Results', child: results.isEmpty ? const Text('No published player results yet.') : Column(children: results.take(4).map((r) {
      final url = r['pdfUrl']?.toString();
      return ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(child: Icon(Icons.emoji_events_rounded)), title: Text('${r['term'] ?? ''} · ${r['session'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(r['coachComment']?.toString() ?? 'Performance report'), trailing: url == null ? null : FilledButton.tonal(onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication), child: const Text('Open')));
    }).toList()));
  });
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({
    required this.user,
    required this.player,
  });

  final AppUser user;
  final Player? player;

  @override
  Widget build(BuildContext context) {
    final currentPlayer = player;
    final playerPhoto = currentPlayer?.photoUrl.trim() ?? '';
    final userPhoto = user.photoUrl?.trim() ?? '';
    final profilePhoto = playerPhoto.isNotEmpty ? playerPhoto : userPhoto;
    final hasProfilePhoto = profilePhoto.isNotEmpty;

    final subtitle = currentPlayer == null
        ? 'Your academy profile is being linked'
        : '#${currentPlayer.jerseyNumber}  ·  ${currentPlayer.position.isEmpty ? 'Academy player' : currentPlayer.position}';

    return Column(
      children: [
        Container(
          height: 258,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/stadium.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.primaryDark),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark.withValues(alpha: .94),
                      AppColors.primary.withValues(alpha: .76),
                      Colors.black.withValues(alpha: .72),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: -18,
                bottom: -14,
                child: Opacity(
                  opacity: .98,
                  child: SizedBox(
                    width: 185,
                    height: 235,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(110),
                        topRight: Radius.circular(110),
                      ),
                      child: hasProfilePhoto
                          ? Image.network(
                              profilePhoto,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/player_placeholder.jpg',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/images/player_placeholder.jpg',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 155, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withValues(alpha: .16)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sports_soccer_rounded, color: AppColors.secondary, size: 16),
                          SizedBox(width: 7),
                          Text(
                            'PLAYER CENTRE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Welcome back,',
                      style: TextStyle(color: Colors.white.withValues(alpha: .70), fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        height: 1.04,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: .76), fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (currentPlayer != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PremiumStat(
                  value: '#${currentPlayer.jerseyNumber}',
                  label: 'Jersey number',
                  icon: Icons.tag_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PremiumStat(
                  value: currentPlayer.position.isEmpty ? '—' : currentPlayer.position,
                  label: 'Playing position',
                  icon: Icons.sports_soccer_outlined,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LiveTraining extends StatelessWidget {
  const _LiveTraining({
    required this.stream,
    required this.player,
  });

  final Stream<List<TrainingSession>> stream;
  final Player player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TrainingSession>>(
      stream: stream,
      builder: (context, snapshot) {
        final sessions = (snapshot.data ?? <TrainingSession>[])
            .where(
              (session) =>
                  session.teamId.isEmpty ||
                  session.teamId == player.teamId ||
                  session.coachId == player.coachId,
            )
            .where(
              (session) => session.scheduledAt.isAfter(
                DateTime.now().subtract(
                  const Duration(hours: 2),
                ),
              ),
            )
            .take(3)
            .toList();

        if (snapshot.hasError) {
          return const _Section(
            icon: Icons.fitness_center_outlined,
            title: 'Training',
            child: Text(
              'Unable to load training updates right now.',
            ),
          );
        }

        return _Section(
          icon: Icons.fitness_center_outlined,
          title: 'Training',
          child: sessions.isEmpty
              ? const Text(
                  'No upcoming training published.',
                )
              : Column(
                  children: sessions.map((session) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(
                          Icons.sports_soccer_outlined,
                        ),
                      ),
                      title: Text(
                        session.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        '${DateFormat('EEE, d MMM · h:mm a').format(session.scheduledAt)}'
                        ' · '
                        '${session.location.isEmpty ? 'Venue TBA' : session.location}',
                      ),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }
}

class _LiveFixtures extends StatelessWidget {
  const _LiveFixtures({
    required this.stream,
    required this.player,
  });

  final Stream<List<Fixture>> stream;
  final Player player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Fixture>>(
      stream: stream,
      builder: (context, snapshot) {
        final fixtures = (snapshot.data ?? <Fixture>[])
            .where(
              (fixture) =>
                  fixture.teamId.isEmpty ||
                  fixture.teamId == player.teamId ||
                  fixture.coachId == player.coachId,
            )
            .take(3)
            .toList();

        if (snapshot.hasError) {
          return const _Section(
            icon: Icons.sports_soccer_outlined,
            title: 'Matches',
            child: Text(
              'Unable to load fixtures right now.',
            ),
          );
        }

        return _Section(
          icon: Icons.sports_soccer_outlined,
          title: 'Matches',
          child: fixtures.isEmpty
              ? const Text(
                  'No fixtures published.',
                )
              : Column(
                  children: fixtures.map((fixture) {
                    return ListTile(
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        '${DateFormat('EEE, d MMM · h:mm a').format(fixture.date)}'
                        ' · '
                        '${fixture.venue.isEmpty ? 'Venue TBA' : fixture.venue}',
                      ),
                      trailing: fixture.isLive
                          ? const Chip(
                              label: Text('LIVE'),
                            )
                          : null,
                    );
                  }).toList(),
                ),
        );
      },
    );
  }
}

class _LiveAttendance extends StatelessWidget {
  const _LiveAttendance({
    required this.stream,
  });

  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      ) {
        final docs = snapshot.data?.docs ??
            <QueryDocumentSnapshot<Map<String, dynamic>>>[];

        final recent = docs.take(5).toList();

        if (snapshot.hasError) {
          return const _Section(
            icon: Icons.fact_check_outlined,
            title: 'Attendance',
            child: Text(
              'Unable to load attendance right now.',
            ),
          );
        }

        return _Section(
          icon: Icons.fact_check_outlined,
          title: 'Attendance',
          child: recent.isEmpty
              ? const Text(
                  'Your attendance will appear after your coach records a session.',
                )
              : Column(
                  children: recent.map((doc) {
                    final data = doc.data();

                    final status =
                        data['status']?.toString() ?? 'Recorded';

                    final dateKey =
                        data['dateKey']?.toString() ?? 'Academy session';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(
                          Icons.check_circle_outline,
                        ),
                      ),
                      title: Text(
                        status,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(dateKey),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }
}

class _LiveAnnouncements extends StatelessWidget {
  const _LiveAnnouncements({
    required this.stream,
  });

  final Stream<List<Announcement>> stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Announcement>>(
      stream: stream,
      builder: (context, snapshot) {
        final announcements = (snapshot.data ?? <Announcement>[])
            .where((announcement) => announcement.active)
            .take(3)
            .toList();

        if (snapshot.hasError) {
          return const _Section(
            icon: Icons.campaign_outlined,
            title: 'Announcements & Coach Updates',
            child: Text(
              'Unable to load announcements right now.',
            ),
          );
        }

        return _Section(
          icon: Icons.campaign_outlined,
          title: 'Announcements & Coach Updates',
          child: announcements.isEmpty
              ? const Text(
                  'No new announcements.',
                )
              : Column(
                  children: announcements.map((announcement) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(
                          Icons.campaign_outlined,
                        ),
                      ),
                      title: Text(
                        announcement.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        announcement.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        DateFormat('d MMM')
                            .format(announcement.publishedAt),
                      ),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(icon),
                ),
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
            const SizedBox(height: 10),
            child,
         ],
            ),
          ),
        );
      
  }
}
