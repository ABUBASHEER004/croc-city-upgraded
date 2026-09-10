import 'package:flutter/material.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
  });

  final String title;
  final String description;
  final String date;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                child: const Icon(Icons.campaign_outlined),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(description),
                    const SizedBox(height: 8),
                    Text(date,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
