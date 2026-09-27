
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/notification_service.dart';
import 'unread_badge.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final NotificationService service =
        NotificationService();

    return StreamBuilder<int>(
      stream: service.watchUnreadCount(),
      builder: (
        BuildContext context,
        AsyncSnapshot<int> snapshot,
      ) {
        final int count = snapshot.data ?? 0;

        return IconButton(
          tooltip: 'Notifications',
          onPressed: () {
            context.push('/notifications');
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              const Icon(
                Icons.notifications_outlined,
              ),
              if (count > 0)
                Positioned(
                  right: -5,
                  top: -5,
                  child: UnreadBadge(
                    count: count,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

