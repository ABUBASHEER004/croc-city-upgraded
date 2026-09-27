
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isUrgent =
        notification.priority.toLowerCase() == 'urgent';

    final IconData notificationIcon =
        switch (notification.type.toLowerCase()) {
      'training' => Icons.fitness_center_rounded,
      'fixture' => Icons.sports_soccer_rounded,
      'assignment' => Icons.assignment_rounded,
      'attendance' => Icons.fact_check_rounded,
      'result' => Icons.workspace_premium_rounded,
      _ => Icons.notifications_active_rounded,
    };

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        child: Icon(
          isUrgent
              ? Icons.priority_high_rounded
              : notificationIcon,
        ),
      ),
      title: Text(
        notification.title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        '${notification.message}\n'
        '${DateFormat('d MMM · h:mm a').format(notification.createdAt)}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: notification.read
          ? null
          : const Icon(
              Icons.circle,
              size: 9,
            ),
    );
  }
}
