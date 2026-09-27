
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/app_user.dart';
import '../../../calendar/presentation/widgets/academy_calendar_card.dart';
import '../../../communication/data/announcement_service.dart';
import '../../../communication/models/announcement.dart';
import '../widgets/premium_ui.dart';
import '../../../communication/presentation/widgets/notification_bell.dart';

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            10,
            18,
            40,
          ),
          children: <Widget>[
            PremiumHero(
              eyebrow: 'Academy Operations',
              title: 'Keep the academy moving.',
              subtitle:
                  'A focused staff workspace with staff-only announcements and operational updates.',
              image: 'assets/images/stadium.jpg',
              icon: Icons.badge_rounded,
            ),

            const SizedBox(height: 18),

            const AcademyCalendarCard(
              compact: true,
            ),

            const SizedBox(height: 18),

            const PremiumStat(
              value: 'STAFF',
              label: 'Private workspace',
              icon: Icons.verified_user_rounded,
            ),

            const SizedBox(height: 22),

            PremiumSection(
              title: 'Staff announcements',
              child: StreamBuilder<List<Announcement>>(
                stream: AnnouncementService()
                    .watchForAudience('Staff'),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<Announcement>> snapshot,
                ) {
                  final List<Announcement> list =
                      snapshot.data ??
                          const <Announcement>[];

                  if (list.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text(
                          'No staff announcements yet.',
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: list.map<Widget>(
                      (Announcement announcement) {
                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: const CircleAvatar(
                              child: Icon(
                                Icons.campaign_rounded,
                              ),
                            ),
                            title: Text(
                              announcement.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(
                                top: 6,
                              ),
                              child: Text(
                                '${announcement.message}\n'
                                'From ${announcement.publishedByName} · '
                                '${DateFormat('d MMM yyyy').format(announcement.publishedAt)}',
                              ),
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

