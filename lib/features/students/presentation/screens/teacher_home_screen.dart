
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/app_user.dart';
import '../../../calendar/presentation/widgets/academy_calendar_card.dart';
import '../../../communication/data/announcement_service.dart';
import '../../../communication/models/announcement.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';
import '../../data/academic_service.dart';
import '../../data/models/student.dart';
import '../../data/student_service.dart';
import '../../../communication/presentation/widgets/notification_bell.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  @override
  State<TeacherHomeScreen> createState() =>
      _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final _students = StudentService();
  final _academic = AcademicService();
  final _announcements = AnnouncementService();

  Stream<List<Student>> get _myStudents =>
      _students.watchStudents(
        teacherId: widget.user.uid,
      );

  Future<void> _newAssignment(
    List<Student> students,
  ) async {
    final title = TextEditingController();
    final description = TextEditingController();
    final selected = <String>{};
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Publish assignment'),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: title,
                      decoration: const InputDecoration(
                        labelText: 'Assignment title',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: description,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText:
                            'Instructions / description',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Students',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    CheckboxListTile(
                      value: selected.length ==
                              students.length &&
                          students.isNotEmpty,
                      onChanged: (_) {
                        setState(() {
                          if (selected.length ==
                              students.length) {
                            selected.clear();
                          } else {
                            selected.addAll(
                              students.map<String>(
                                (student) => student.id,
                              ),
                            );
                          }
                        });
                      },
                      title: const Text(
                        'Select all students',
                      ),
                    ),
                    ...students.map<Widget>(
                      (student) => CheckboxListTile(
                        value: selected.contains(
                          student.id,
                        ),
                        onChanged: (_) {
                          setState(() {
                            if (selected.contains(
                              student.id,
                            )) {
                              selected.remove(
                                student.id,
                              );
                            } else {
                              selected.add(
                                student.id,
                              );
                            }
                          });
                        },
                        title: Text(
                          student.fullName,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
          const NotificationBell(),
              TextButton(
                onPressed: saving
                    ? null
                    : () => Navigator.pop(dialog),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (title.text.trim().isEmpty ||
                            selected.isEmpty) {
                          return;
                        }

                        setState(() => saving = true);

                        try {
                          await _academic
                              .publishAssignment(
                            title: title.text,
                            description:
                                description.text,
                            teacherId:
                                widget.user.uid,
                            studentIds:
                                selected.toList(),
                            studentUserIds: students
                                .where(
                                  (student) =>
                                      selected.contains(
                                        student.id,
                                      ) &&
                                      student.userId
                                          .isNotEmpty,
                                )
                                .map<String>(
                                  (student) =>
                                      student.userId,
                                )
                                .toList(),
                          );

                          if (dialog.mounted) {
                            Navigator.pop(dialog);
                          }
                        } finally {
                          if (dialog.mounted) {
                            setState(
                              () => saving = false,
                            );
                          }
                        }
                      },
                child: Text(
                  saving ? 'Publishing…' : 'Publish',
                ),
              ),
            ],
          );
        },
      ),
    );

    title.dispose();
    description.dispose();
  }

  Future<void> _takeAttendance(
    List<Student> students,
  ) async {
    final statuses = <String, String>{
      for (final student in students)
        student.id: 'Present',
    };

    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Take student attendance',
            ),
            content: SizedBox(
              width: 620,
              child: ListView(
                shrinkWrap: true,
                children: students
                    .map<Widget>(
                      (student) => ListTile(
                        title: Text(
                          student.fullName,
                        ),
                        subtitle: Text(
                          student.className,
                        ),
                        trailing:
                            DropdownButton<String>(
                          value: statuses[student.id],
                          items: const <DropdownMenuItem<
                              String>>[
                            DropdownMenuItem(
                              value: 'Present',
                              child: Text('Present'),
                            ),
                            DropdownMenuItem(
                              value: 'Absent',
                              child: Text('Absent'),
                            ),
                            DropdownMenuItem(
                              value: 'Late',
                              child: Text('Late'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(
                              () => statuses[
                                      student.id] =
                                  value ?? 'Present',
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: saving
                    ? null
                    : () => Navigator.pop(dialog),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        setState(
                          () => saving = true,
                        );

                        try {
                          for (final student
                              in students) {
                            await _academic
                                .markAttendance(
                              studentId: student.id,
                              studentName:
                                  student.fullName,
                              teacherId:
                                  widget.user.uid,
                              date: DateTime.now(),
                              status:
                                  statuses[student.id] ??
                                      'Present',
                            );
                          }

                          if (dialog.mounted) {
                            Navigator.pop(dialog);
                          }
                        } finally {
                          if (dialog.mounted) {
                            setState(
                              () => saving = false,
                            );
                          }
                        }
                      },
                child: Text(
                  saving
                      ? 'Saving…'
                      : 'Save attendance',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _sendAnnouncement(
    List<Student> students,
  ) async {
    final title = TextEditingController();
    final message = TextEditingController();
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Teacher announcement',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: message,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'This announcement will be delivered only '
                  'to students assigned to you.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: saving
                    ? null
                    : () => Navigator.pop(dialog),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (title.text.trim().isEmpty ||
                            message.text.trim().isEmpty) {
                          return;
                        }

                        setState(
                          () => saving = true,
                        );

                        try {
                          final recipientUserIds =
                              students
                                  .where(
                                    (student) =>
                                        student.userId
                                            .isNotEmpty,
                                  )
                                  .map<String>(
                                    (student) =>
                                        student.userId,
                                  )
                                  .toList();

                          await _announcements.save(
                            Announcement(
                              id: '',
                              title: title.text.trim(),
                              message:
                                  message.text.trim(),
                              publishedAt:
                                  DateTime.now(),
                              priority: 'Normal',
                              audience: 'Students',
                              audiences: const [
                                'Students',
                              ],
                              recipientUserIds:
                                  recipientUserIds,
                              publishedBy:
                                  widget.user.uid,
                              publishedByName:
                                  widget.user.fullName,
                              active: true,
                            ),
                          );

                          if (dialog.mounted) {
                            Navigator.pop(dialog);
                          }
                        } finally {
                          if (dialog.mounted) {
                            setState(
                              () => saving = false,
                            );
                          }
                        }
                      },
                child: Text(
                  saving ? 'Sending…' : 'Send',
                ),
              ),
            ],
          );
        },
      ),
    );

    title.dispose();
    message.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teacher Dashboard',
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              context.push('/profile');
            },
            icon: const Icon(
              Icons.person_outline,
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Student>>(
        stream: _myStudents,
        builder: (context, snapshot) {
          final students =
              snapshot.data ?? const <Student>[];

          return PremiumDashboardBackground(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  10,
                  18,
                  40,
                ),
                children: <Widget>[
                  PremiumHero(
                    eyebrow: 'Academic Faculty',
                    title:
                        'Teach with clarity. Track every learner.',
                    subtitle:
                        'Your private workspace for attendance, '
                        'assignments and student communication.',
                    image:
                        'assets/images/football.jpg',
                    icon: Icons.school_rounded,
                  ),

                  const SizedBox(height: 16),

                  const AcademyCalendarCard(
                    compact: true,
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      SizedBox(
                        width: 180,
                        child: PremiumStat(
                          value:
                              '${students.length}',
                          label:
                              'Assigned students',
                          icon:
                              Icons.groups_rounded,
                        ),
                      ),
                      const SizedBox(
                        width: 180,
                        child: PremiumStat(
                          value: 'LIVE',
                          label:
                              'Academic workspace',
                          icon: Icons
                              .auto_awesome_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  PremiumSection(
                    title: 'Teaching tools',
                    child: Column(
                      children: <Widget>[
                        _Action(
                          icon:
                              Icons.campaign_rounded,
                          title:
                              'Announcements',
                          subtitle:
                              'Send announcements only '
                              'to your assigned students',
                          onTap: () =>
                              _sendAnnouncement(
                            students,
                          ),
                        ),
                        _Action(
                          icon:
                              Icons.fact_check_rounded,
                          title: 'Attendance',
                          subtitle:
                              'Take attendance for your students',
                          onTap: () =>
                              _takeAttendance(
                            students,
                          ),
                        ),
                        _Action(
                          icon:
                              Icons.assignment_rounded,
                          title: 'Assignments',
                          subtitle:
                              'Publish assignments to selected students',
                          onTap: () =>
                              _newAssignment(
                            students,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  PremiumSection(
                    title: 'My students',
                    child: students.isEmpty
                        ? const Card(
                            child: Padding(
                              padding:
                                  EdgeInsets.all(18),
                              child: Text(
                                'No students have been linked '
                                'to this teacher yet. Ask an '
                                'administrator to assign students '
                                'to your account.',
                              ),
                            ),
                          )
                        : Column(
                            children: students
                                .map<Widget>(
                                  (student) => Card(
                                    child: ListTile(
                                      leading:
                                          CircleAvatar(
                                        child: Text(
                                          student.firstName
                                                  .isEmpty
                                              ? '?'
                                              : student
                                                  .firstName[0]
                                                  .toUpperCase(),
                                        ),
                                      ),
                                      title: Text(
                                        student.fullName,
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.w800,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${student.className} · '
                                        '${student.studentId}',
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),

                  const SizedBox(height: 18),

                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.lock_outline_rounded,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Student announcements are private '
                              'to the students assigned to this teacher.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
        ),
        onTap: onTap,
      ),
    );
  }
}

