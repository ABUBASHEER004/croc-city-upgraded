import 'package:flutter/material.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New announcement'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Announcement(
            title: 'Parents Meeting',
            message:
                'Parents and guardians are invited to the academy hall for an important academy update.',
            date: 'Today',
          ),
          _Announcement(
            title: 'Training Kit Collection',
            message:
                'Players should collect their new training kits from the academy office before Friday.',
            date: 'Yesterday',
          ),
          _Announcement(
            title: 'Matchday Reminder',
            message:
                'Selected players should report to the academy at the time communicated by their coach.',
            date: 'This week',
          ),
        ],
      ),
    );
  }
}

class _Announcement extends StatelessWidget {
  const _Announcement({
    required this.title,
    required this.message,
    required this.date,
  });

  final String title;
  final String message;
  final String date;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                child: Icon(Icons.campaign_outlined),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          date,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(message),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
