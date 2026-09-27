
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/app_user.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';
import '../../data/announcement_service.dart';
import '../../models/announcement.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in.'),
        ),
      );
    }

    final audience = user.isAdmin
        ? 'Everyone'
        : user.isCoach
            ? 'Players'
            : user.isTeacher
                ? 'Students'
                : user.isStaff
                    ? 'Staff'
                    : 'Players';

    final canCompose =
        user.isAdmin || user.isCoach || user.isTeacher;

    final stream = user.isCoach
        ? AnnouncementService().watchSentBy(user.uid)
        : AnnouncementService().watchForUser(
            audience: audience,
            email: user.email,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),
      floatingActionButton: canCompose
          ? FloatingActionButton.extended(
              onPressed: () => _compose(context, user),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New announcement'),
            )
          : null,
      body: PremiumDashboardBackground(
        child: StreamBuilder<List<Announcement>>(
          stream: stream,
          builder: (context, snapshot) {
            final items =
                snapshot.data ?? const <Announcement>[];

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                100,
              ),
              children: <Widget>[
                PremiumHero(
                  eyebrow: 'Academy communication',
                  title: 'Stay informed. Stay connected.',
                  subtitle:
                      'Announcements are filtered to the audiences each account is authorised to receive.',
                  icon: Icons.campaign_rounded,
                ),

                const SizedBox(height: 18),

                if (items.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No announcements for your role yet.',
                      ),
                    ),
                  )
                else
                  ...items.map<Widget>(
                    (announcement) {
                      final priority =
                          announcement.priority?.trim() ?? '';

                      final isUrgent =
                          priority.toLowerCase() == 'urgent';

                      final publishedAt =
                          announcement.publishedAt;

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.all(16),

                          leading: CircleAvatar(
                            child: Icon(
                              isUrgent
                                  ? Icons.priority_high_rounded
                                  : Icons.campaign_rounded,
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
                                const EdgeInsets.only(top: 6),
                            child: Text(
                              '${announcement.message}\n\n'
                              'From ${announcement.publishedByName} · '
                              '${DateFormat('d MMM yyyy').format(publishedAt)}',
                            ),
                          ),

                          isThreeLine: true,

                          trailing: Chip(
                            label: Text(
                              announcement.audience,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Future<void> _compose(
    BuildContext context,
    AppUser user,
  ) async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    bool saving = false;

    final options = user.isAdmin
        ? const <String, String>{
            'Everyone': 'Everyone',
            'Players': 'Players',
            'Coaches': 'Coaches',
            'Students': 'Students',
            'Staff': 'Staff',
            'Admins': 'Admins',
          }
        : user.isCoach
            ? const <String, String>{
                'Players': 'Players',
              }
            : const <String, String>{
                'Students': 'Students',
              };

    String selected = options.keys.first;

    await showDialog<void>(
      context: context,
      builder: (dialog) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Create announcement',
              ),

              content: SizedBox(
                width: 540,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: titleController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Announcement title',
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: messageController,
                        maxLines: 5,
                        decoration:
                            const InputDecoration(
                          labelText: 'Message',
                        ),
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selected,
                        decoration:
                            const InputDecoration(
                          labelText: 'Audience',
                        ),
                        items: options.entries
                            .map<
                                DropdownMenuItem<String>>(
                              (entry) =>
                                  DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(entry.value),
                              ),
                            )
                            .toList(),
                        onChanged: saving
                            ? null
                            : (value) {
                                if (value == null) {
                                  return;
                                }

                                setState(() {
                                  selected = value;
                                });
                              },
                      ),

                      const SizedBox(height: 10),

                      Text(
                        user.isCoach
                            ? 'Coach announcements are delivered only to your players.'
                            : user.isTeacher
                                ? 'Teacher announcements are delivered only to students assigned to you.'
                                : selected == 'Staff'
                                    ? 'Only staff members will receive this announcement.'
                                    : selected == 'Admins'
                                        ? 'Only administrators will receive this announcement.'
                                        : 'Only the selected audience will receive this announcement.',
                        style:
                            Theme.of(context)
                                .textTheme
                                .bodySmall,
                      ),
                    ],
                  ),
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
                          final title =
                              titleController.text.trim();
                          final message =
                              messageController.text.trim();

                          if (title.isEmpty ||
                              message.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter both a title and message.',
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            saving = true;
                          });

                          try {
                            var recipientEmails =
                                <String>[];

                            var recipientUserIds =
                                <String>[];

                            final firestore =
                                FirebaseFirestore.instance;

                            // Coach → assigned players.
                            if (user.isCoach) {
                              final playerSnapshot =
                                  await firestore
                                      .collection('players')
                                      .where(
                                        'coachId',
                                        isEqualTo: user.uid,
                                      )
                                      .get();

                              recipientEmails =
                                  playerSnapshot.docs
                                      .map(
                                        (doc) =>
                                            doc.data()['email']
                                                ?.toString()
                                                .trim()
                                                .toLowerCase() ??
                                            '',
                                      )
                                      .where(
                                        (email) =>
                                            email.isNotEmpty,
                                      )
                                      .toList();
                            }

                            // Admin → all players.
                            else if (user.isAdmin &&
                                selected == 'Players') {
                              final playerSnapshot =
                                  await firestore
                                      .collection('users')
                                      .where(
                                        'role',
                                        isEqualTo: 'Player',
                                      )
                                      .get();

                              recipientEmails =
                                  playerSnapshot.docs
                                      .map(
                                        (doc) =>
                                            doc.data()['email']
                                                ?.toString()
                                                .trim()
                                                .toLowerCase() ??
                                            '',
                                      )
                                      .where(
                                        (email) =>
                                            email.isNotEmpty,
                                      )
                                      .toList();
                            }

                            // Admin → all students.
                            else if (user.isAdmin &&
                                selected == 'Students') {
                              final studentSnapshot =
                                  await firestore
                                      .collection('users')
                                      .where(
                                        'role',
                                        isEqualTo: 'Student',
                                      )
                                      .get();

                              recipientUserIds =
                                  studentSnapshot.docs
                                      .map(
                                        (doc) => doc.id,
                                      )
                                      .toList();

                              recipientEmails =
                                  studentSnapshot.docs
                                      .map(
                                        (doc) =>
                                            doc.data()['email']
                                                ?.toString()
                                                .trim()
                                                .toLowerCase() ??
                                            '',
                                      )
                                      .where(
                                        (email) =>
                                            email.isNotEmpty,
                                      )
                                      .toList();
                            }

                            await AnnouncementService().save(
                              Announcement(
                                id: '',
                                title: title,
                                message: message,
                                publishedAt: DateTime.now(),
                                priority: 'Normal',
                                audience: selected,
                                audiences: <String>[
                                  selected,
                                ],
                                recipientEmails:
                                    recipientEmails,
                                recipientUserIds:
                                    recipientUserIds,
                                publishedBy: user.uid,
                                publishedByName:
                                    user.fullName,
                                active: true,
                              ),
                            );

                            if (dialog.mounted) {
                              Navigator.pop(dialog);

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Announcement published successfully.',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (dialog.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not publish announcement: $e',
                                  ),
                                ),
                              );
                            }
                          } finally {
                            if (dialog.mounted) {
                              setState(() {
                                saving = false;
                              });
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
        );
      },
    );

    titleController.dispose();
    messageController.dispose();
  }
}

