import 'package:flutter/material.dart';

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.campaign),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
        trailing: Text(
          date,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}