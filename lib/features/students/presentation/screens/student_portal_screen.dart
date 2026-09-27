
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/app_user.dart';
import '../../../calendar/presentation/widgets/academy_calendar_card.dart';
import '../../../communication/data/announcement_service.dart';
import '../../../communication/models/announcement.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';
import '../../../finance/presentation/screens/finance_dashboard_screen.dart';
import '../../data/academic_service.dart';
import '../../data/models/student.dart';
import '../../data/student_service.dart';
import '../../../communication/presentation/widgets/notification_bell.dart';

class StudentPortalScreen extends StatelessWidget {
  const StudentPortalScreen({
    super.key,
    required this.userName,
    required this.uid,
    this.parent = false,
  });

  final String userName;
  final String uid;
  final bool parent;

  @override
  Widget build(BuildContext context) {
    final service = StudentService();

    return Scaffold(
      appBar: AppBar(
        actions: const <Widget>[
          NotificationBell(),
        ],
        title: Text(
          parent
              ? 'Student Parent Portal'
              : 'Student Dashboard',
        ),
      ),
      body: StreamBuilder<List<Student>>(
        stream: service.watchStudents(
          parentId: parent ? uid : null,
          userId: parent ? null : uid,
        ),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<Student>> snapshot,
        ) {
          final List<Student> students =
              snapshot.data ?? const <Student>[];

          if (parent) {
            return _parentView(
              context,
              students,
              service,
            );
          }

          return _studentView(
            context,
            students.isEmpty ? null : students.first,
          );
        },
      ),
    );
  }

  Widget _parentView(
    BuildContext context,
    List<Student> students,
    StudentService service,
  ) {
    return PremiumDashboardBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          32,
        ),
        children: <Widget>[
          PremiumHero(
            eyebrow: 'Education Centre',
            title: 'Welcome, $userName',
            subtitle:
                'Stay connected to attendance, academic progress, assignments and published results.',
            image: 'assets/images/stadium.jpg',
            icon: Icons.school_rounded,
          ),

          const SizedBox(height: 16),

          const AcademyCalendarCard(
            compact: true,
          ),

          const SizedBox(height: 18),

          if (students.isNotEmpty)
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const FinanceDashboardScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.payments_rounded,
              ),
              label: const Text(
                'Fees & Payments',
              ),
            ),

          if (students.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'No student has been linked to this parent account yet.',
                ),
              ),
            ),

          ...students.map<Widget>(
            (Student student) {
              return _StudentCard(
                student: student,
                service: service,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _studentView(
    BuildContext context,
    Student? student,
  ) {
    return PremiumDashboardBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          36,
        ),
        children: <Widget>[
          PremiumHero(
            eyebrow: 'Croc City Education Centre',
            title: 'Learn. Grow. Achieve.',
            subtitle:
                'Your private academic dashboard for announcements, assignments, attendance and results.',
            image: 'assets/images/football.jpg',
            icon: Icons.school_rounded,
          ),

          const SizedBox(height: 16),

          const AcademyCalendarCard(
            compact: true,
          ),

          const SizedBox(height: 18),

          if (student == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Your student profile has not been linked yet. '
                  'Please contact the academy administrator.',
                ),
              ),
            )
          else
            _StudentWorkspace(
              student: student,
            ),
        ],
      ),
    );
  }
}

class _StudentWorkspace extends StatelessWidget {
  const _StudentWorkspace({
    required this.student,
  });

  final Student student;

  @override
  Widget build(BuildContext context) {
    final academic = AcademicService();
    final announcements = AnnouncementService();
    final service = StudentService();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(18),
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: student.photoUrl.isEmpty
                  ? null
                  : NetworkImage(student.photoUrl),
              child: student.photoUrl.isEmpty
                  ? Text(
                      student.firstName.isEmpty
                          ? '?'
                          : student.firstName[0]
                              .toUpperCase(),
                    )
                  : null,
            ),
            title: Text(
              student.fullName,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: Text(
              '${student.studentId} · ${student.className}',
            ),
          ),
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------------
        // ANNOUNCEMENTS
        // ------------------------------------------------------------
        PremiumSection(
          title: 'Announcements',
          child: StreamBuilder<List<Announcement>>(
            stream: announcements.watchForUser(
              audience: 'Students',
              userId: student.userId,
            ),
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
                      'No announcements yet.',
                    ),
                  ),
                );
              }

              return Column(
                children: list
                    .take(5)
                    .map<Widget>(
                  (Announcement announcement) {
                    return ListTile(
                      leading: const Icon(
                        Icons.campaign_rounded,
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
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        DateFormat('d MMM').format(
                          announcement.publishedAt,
                        ),
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------------
        // ASSIGNMENTS
        // ------------------------------------------------------------
        PremiumSection(
          title: 'Assignments',
          child:
              StreamBuilder<List<Map<String, dynamic>>>(
            stream: academic
                .watchAssignmentsForStudent(
              student.id,
              userId: student.userId,
            ),
            builder: (
              BuildContext context,
              AsyncSnapshot<
                  List<Map<String, dynamic>>> snapshot,
            ) {
              final List<Map<String, dynamic>> list =
                  snapshot.data ??
                      const <Map<String, dynamic>>[];

              if (list.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'No assignments have been published.',
                    ),
                  ),
                );
              }

              return Column(
                children: list
                    .take(6)
                    .map<Widget>(
                  (Map<String, dynamic> assignment) {
                    final due =
                        assignment['dueDate'];

                    final dueText =
                        due is Timestamp
                            ? DateFormat('d MMM').format(
                                due.toDate(),
                              )
                            : 'Open';

                    return ListTile(
                      leading: const Icon(
                        Icons.assignment_rounded,
                      ),
                      title: Text(
                        assignment['title']
                                ?.toString() ??
                            'Assignment',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        assignment['description']
                                ?.toString() ??
                            '',
                      ),
                      trailing: Text(
                        dueText,
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------------
        // ATTENDANCE
        // ------------------------------------------------------------
        PremiumSection(
          title: 'Attendance',
          child:
              StreamBuilder<List<Map<String, dynamic>>>(
            stream:
                academic.watchAttendanceForStudent(
              student.id,
            ),
            builder: (
              BuildContext context,
              AsyncSnapshot<
                  List<Map<String, dynamic>>> snapshot,
            ) {
              final List<Map<String, dynamic>> list =
                  snapshot.data ??
                      const <Map<String, dynamic>>[];

              if (list.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'No attendance records yet.',
                    ),
                  ),
                );
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: list
                    .take(10)
                    .map<Widget>(
                  (Map<String, dynamic> attendance) {
                    final date =
                        attendance['date'];

                    final dateText =
                        date is Timestamp
                            ? DateFormat('d MMM').format(
                                date.toDate(),
                              )
                            : '';

                    final status =
                        attendance['status']
                                ?.toString() ??
                            '';

                    return Chip(
                      label: Text(
                        '$status · $dateText',
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------------
        // RESULTS
        // ------------------------------------------------------------
        PremiumSection(
          title: 'Results',
          child:
              StreamBuilder<List<Map<String, dynamic>>>(
            stream: service.watchResults(
              student.id,
            ),
            builder: (
              BuildContext context,
              AsyncSnapshot<
                  List<Map<String, dynamic>>> snapshot,
            ) {
              final List<Map<String, dynamic>> results =
                  snapshot.data ??
                      const <Map<String, dynamic>>[];

              if (results.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'No results have been published yet.',
                    ),
                  ),
                );
              }

              return Column(
                children: results
                    .map<Widget>(
                  (Map<String, dynamic> result) {
                    final url =
                        result['pdfUrl']?.toString();

                    final term =
                        result['term']?.toString() ??
                            '';

                    final session =
                        result['session']?.toString() ??
                            '';

                    return ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf_rounded,
                      ),
                      title: Text(
                        '$term · $session',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: const Text(
                        'Official academic report',
                      ),
                      trailing: url == null ||
                              url.trim().isEmpty
                          ? const Icon(
                              Icons.pending_outlined,
                            )
                          : FilledButton.tonal(
                              onPressed: () {
                                _openPdf(url);
                              },
                              child: const Text(
                                'Open PDF',
                              ),
                            ),
                    );
                  },
                ).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  static Future<void> _openPdf(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.student,
    required this.service,
  });

  final Student student;
  final StudentService service;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        top: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              student.fullName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),

            Text(
              '${student.studentId} · ${student.className}',
            ),

            const SizedBox(height: 10),

            StreamBuilder<List<Map<String, dynamic>>>(
              stream: service.watchResults(
                student.id,
                parentId: student.parentId,
              ),
              builder: (
                BuildContext context,
                AsyncSnapshot<
                    List<Map<String, dynamic>>> snapshot,
              ) {
                final List<Map<String, dynamic>> results =
                    snapshot.data ??
                        const <Map<String, dynamic>>[];

                if (results.isEmpty) {
                  return const Text(
                    'No results have been published yet.',
                  );
                }

                return Column(
                  children: results
                      .map<Widget>(
                    (Map<String, dynamic> result) {
                      final url =
                          result['pdfUrl']?.toString();

                      final term =
                          result['term']?.toString() ??
                              '';

                      final session =
                          result['session']
                                  ?.toString() ??
                              '';

                      return ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading: const Icon(
                          Icons.picture_as_pdf_rounded,
                        ),
                        title: Text(
                          '$term · $session',
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        trailing: url == null ||
                                url.trim().isEmpty
                            ? const Icon(
                                Icons.pending_outlined,
                              )
                            : FilledButton.tonal(
                                onPressed: () {
                                  _openPdf(url);
                                },
                                child: const Text(
                                  'Open PDF',
                                ),
                              ),
                      );
                    },
                  ).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _openPdf(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}

