import '../../../calendar/presentation/widgets/academy_calendar_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../presentation/providers/auth_provider.dart';
import '../../../communication/data/announcement_service.dart';
import '../../../communication/models/announcement.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';
import '../../../finance/presentation/screens/finance_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'student_management_screen.dart';
import '../../../communication/presentation/widgets/notification_bell.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Croc City Command Centre'),
        actions: [
          const NotificationBell(),
          IconButton(onPressed: () => context.push('/announcements'), icon: const Icon(Icons.notifications_outlined)),
          IconButton(onPressed: () => context.push('/profile'), icon: const Icon(Icons.person_outline)),
        ],
      ),
      body: PremiumDashboardBackground(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
            int countRole(String role) => docs.where((doc) => (doc.data()['role']?.toString().trim().toLowerCase() ?? '') == role.toLowerCase()).length;
            final players = countRole('Player');
            final coaches = countRole('Coach');
            final teachers = countRole('Teacher');
            final staff = countRole('Staff');
            final students = countRole('Student');
            final playerParents = docs.where((doc) {
              final role = doc.data()['role']?.toString().trim().toLowerCase() ?? '';
              return role == 'player parent' || role == 'parent';
            }).length;
            final studentParents = countRole('Student Parent');
            final administrators = docs.where((doc) {
              final role = doc.data()['role']?.toString().trim().toLowerCase() ?? '';
              return role == 'admin' || role == 'administrator';
            }).length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 40),
              children: [
                PremiumHero(
                  eyebrow: 'Croc City Football Academy',
                  title: 'One command centre. Every operation.',
                  subtitle: 'A premium overview of players, education, staff, communication, finance and access control.',
                  image: 'assets/images/stadium.jpg',
                  icon: Icons.admin_panel_settings_rounded,
                ),
                const SizedBox(height: 18),
                const Text('Academy overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth > 900
                        ? 250.0
                        : constraints.maxWidth > 560
                            ? (constraints.maxWidth - 10) / 2
                            : constraints.maxWidth;
                    final stats = [
                      (players, 'Total players', Icons.sports_soccer_rounded),
                      (coaches, 'Total coaches', Icons.co_present_rounded),
                      (teachers, 'Total teachers', Icons.school_rounded),
                      (staff, 'Total staff', Icons.badge_rounded),
                      (administrators, 'Total administrators', Icons.admin_panel_settings_rounded),
                      (students, 'Total students', Icons.menu_book_rounded),
                      (playerParents, 'Total player parents', Icons.family_restroom_rounded),
                      (studentParents, 'Total student parents', Icons.groups_rounded),
                      (docs.length, 'Total registered users', Icons.people_alt_rounded),
                    ];
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: stats
                          .map((item) => SizedBox(
                                width: width,
                                child: PremiumStat(value: '${item.$1}', label: item.$2, icon: item.$3),
                              ))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const AcademyCalendarCard(),
                const SizedBox(height: 24),
                _Section(
                  title: 'Football academy',
                  subtitle: 'Players, coaches, training, matches and finance.',
                  children: [
                    _Action(icon: Icons.sports_soccer_rounded, title: 'Player management', subtitle: 'Player profiles, squads and development records.', onTap: () => context.push('/players')),
                    _Action(icon: Icons.groups_rounded, title: 'Teams & coaches', subtitle: 'Manage teams, coach assignments and squad operations.', onTap: () => context.push('/teams')),
                    _Action(icon: Icons.fitness_center_rounded, title: 'Training & attendance', subtitle: 'Training sessions and football attendance.', onTap: () => context.push('/training')),
                    _Action(icon: Icons.sports_soccer_rounded, title: 'Matches & fixtures', subtitle: 'Fixtures, lineups, match events and results.', onTap: () => context.push('/fixtures')),
                    _Action(icon: Icons.calendar_month_rounded, title: 'Academy calendar', subtitle: 'Create, edit, publish and manage academy events.', onTap: () => context.push('/calendar')),
                    _Action(icon: Icons.account_balance_wallet_rounded, title: 'Football finance', subtitle: 'Invoices, payments, scholarships and collections.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceDashboardScreen()))),
                  ],
                ),
                const SizedBox(height: 14),
                _Section(
                  title: 'Education centre',
                  subtitle: 'Teacher-controlled academic operations for linked students.',
                  children: [
                    _Action(icon: Icons.school_rounded, title: 'Students', subtitle: 'Register students and link parents, teachers and student accounts.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentManagementScreen()))),
                    _Action(icon: Icons.assessment_rounded, title: 'Results & report cards', subtitle: 'Publish official PDF results with profile photos.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentManagementScreen(showResults: true)))),
                  ],
                ),
                const SizedBox(height: 14),
                _Section(
                  title: 'Identity & access',
                  subtitle: 'Register every academy role from one controlled dashboard.',
                  children: [
                    _Action(icon: Icons.manage_accounts_rounded, title: 'Register users & roles', subtitle: 'Register players, coaches, teachers, staff, parents, students and administrators.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()))),
                    _Action(icon: Icons.lock_reset_rounded, title: 'Reset passwords', subtitle: 'Issue secure temporary passwords to managed users.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()))),
                  ],
                ),
                const SizedBox(height: 14),
                _Section(
                  title: 'Restricted communication',
                  subtitle: 'Send announcements to one authorised audience at a time.',
                  children: [
                    _Action(icon: Icons.badge_rounded, title: 'Staff-only announcements', subtitle: 'Only Staff accounts receive these messages.', onTap: () => _composeRestricted(context, user, 'Staff')),
                    _Action(icon: Icons.admin_panel_settings_rounded, title: 'Administrator-only announcements', subtitle: 'Only Administrator accounts receive these messages.', onTap: () => _composeRestricted(context, user, 'Admins')),
                    _Action(icon: Icons.campaign_rounded, title: 'All academy announcements', subtitle: 'Create general or role-specific academy communication.', onTap: () => context.push('/announcements')),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Future<void> _composeRestricted(BuildContext context, dynamic user, String audience) async {
    final title = TextEditingController();
    final message = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text('$audience-only announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 10),
            TextField(controller: message, maxLines: 4, decoration: const InputDecoration(labelText: 'Message')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Publish')),
        ],
      ),
    );
    if (confirmed == true && title.text.trim().isNotEmpty && message.text.trim().isNotEmpty) {
      await AnnouncementService().save(
        Announcement(
          id: '',
          title: title.text.trim(),
          message: message.text.trim(),
          publishedAt: DateTime.now(),
          priority: 'Normal',
          audience: audience,
          audiences: [audience],
          publishedBy: user.uid,
          publishedByName: user.fullName,
          active: true,
        ),
      );
    }
    title.dispose();
    message.dispose();
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.subtitle, required this.children});
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(subtitle),
              const SizedBox(height: 10),
              ...children,
            ],
          ),
        ),
      );
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      );
}
