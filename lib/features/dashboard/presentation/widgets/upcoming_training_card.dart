import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpcomingTrainingCard extends StatelessWidget {
  final String teamName;
  final String venue;
  final DateTime trainingDate;
  final String coachName;
  final VoidCallback? onTap;

  const UpcomingTrainingCard({
    super.key,
    required this.teamName,
    required this.venue,
    required this.trainingDate,
    required this.coachName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  color: Colors.green,
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teamName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            venue,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat(
                            'EEE, MMM d • h:mm a',
                          ).format(trainingDate),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(Icons.person,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            coachName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}