import 'package:flutter/material.dart';

class FixtureCard extends StatelessWidget {
  const FixtureCard({
    super.key,
    required this.competition,
    required this.homeTeam,
    required this.awayTeam,
    required this.date,
    required this.venue,
  });

  final String competition;
  final String homeTeam;
  final String awayTeam;
  final String date;
  final String venue;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(competition,
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(homeTeam,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('VS'),
                  ),
                  Expanded(
                    child: Text(awayTeam,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(date)),
                  const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(venue)),
                ],
              ),
            ],
          ),
        ),
      );
}
