import 'package:flutter/material.dart';

class FixtureCard extends StatelessWidget {
  final String competition;
  final String homeTeam;
  final String awayTeam;
  final String date;
  final String venue;

  const FixtureCard({
    super.key,
    required this.competition,
    required this.homeTeam,
    required this.awayTeam,
    required this.date,
    required this.venue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              competition,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    homeTeam,
                    textAlign: TextAlign.center,
                  ),
                ),

                const Text(
                  "VS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                Expanded(
                  child: Text(
                    awayTeam,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(Icons.calendar_month),
                const SizedBox(width: 10),
                Text(date),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 10),
                Expanded(child: Text(venue)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}