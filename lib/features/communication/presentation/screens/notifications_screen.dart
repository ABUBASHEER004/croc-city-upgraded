import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';
import '../../data/notification_service.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in.')),
      );
    }

    final service = NotificationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: <Widget>[
          StreamBuilder<int>(
            stream: service.watchUnreadCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;

              return TextButton.icon(
                onPressed: count == 0
                    ? null
                    : () => service.markAllAsRead(),
                icon: const Icon(Icons.done_all_rounded),
                label: const Text('Read all'),
              );
            },
          ),
        ],
      ),
      body: PremiumDashboardBackground(
        child: StreamBuilder<List<NotificationModel>>(
          stream: service.watchForCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Unable to load notifications right now.\n'
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final items =
                snapshot.data ?? const <NotificationModel>[];

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                32,
              ),
              children: <Widget>[
                PremiumHero(
                  eyebrow: 'Academy communication',
                  title: 'Never miss an important update.',
                  subtitle:
                      'Your academy notifications are saved here so you can read them again whenever you are connected.',
                  icon: Icons.notifications_active_rounded,
                ),
                const SizedBox(height: 18),
                if (items.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No notifications yet.',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Training, fixtures, assignments, attendance, results and academy announcements will appear here.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...items.map<Widget>(
                    (notification) => _NotificationCard(
                      notification: notification,
                      onRead: () => service.markAsRead(
                        notification.id,
                      ),
                      onDelete: () => service.delete(
                        notification.id,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onRead,
    required this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback onRead;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final urgent =
        notification.priority.toLowerCase() == 'urgent';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(
          16,
          10,
          8,
          10,
        ),
        leading: CircleAvatar(
          child: Icon(
            urgent
                ? Icons.priority_high_rounded
                : switch (notification.type.toLowerCase()) {
                    'training' => Icons.fitness_center_rounded,
                    'fixture' => Icons.sports_soccer_rounded,
                    'assignment' => Icons.assignment_rounded,
                    'attendance' => Icons.fact_check_rounded,
                    'result' => Icons.workspace_premium_rounded,
                    _ => Icons.campaign_rounded,
                  },
          ),
        ),
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.read
                      ? FontWeight.w700
                      : FontWeight.w900,
                ),
              ),
            ),
            if (!notification.read)
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${notification.message}\n'
            '${DateFormat('d MMM yyyy · h:mm a').format(notification.createdAt)}',
          ),
        ),
        isThreeLine: true,
        onTap: notification.read ? null : onRead,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'read') onRead();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => const <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'read',
              child: Text('Mark as read'),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
