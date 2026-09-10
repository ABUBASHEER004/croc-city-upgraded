import 'package:cloud_firestore/cloud_firestore.dart';

class Fixture {
  const Fixture({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.date,
    this.competition = '',
    this.venue = '',
    this.status = 'Scheduled',
    this.teamId = '',
    this.coachId = '',
    this.notes = '',
    this.homeScore,
    this.awayScore,
  });

  final String id;
  final String homeTeam;
  final String awayTeam;
  final DateTime date;
  final String competition;
  final String venue;
  final String status;
  final String teamId;
  final String coachId;
  final String notes;
  final int? homeScore;
  final int? awayScore;

  bool get isLive => status.toLowerCase() == 'live';
  bool get isFinished => status.toLowerCase() == 'finished';

  String get dateLabel => '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year} • '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'date': Timestamp.fromDate(date),
        'competition': competition,
        'venue': venue,
        'status': status,
        'teamId': teamId,
        'coachId': coachId,
        'notes': notes,
        'homeScore': homeScore,
        'awayScore': awayScore,
      };

  factory Fixture.fromMap(String id, Map<String, dynamic> map) {
    DateTime dateValue(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
    }

    int? intValue(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    return Fixture(
      id: id,
      homeTeam: map['homeTeam']?.toString() ?? '',
      awayTeam: map['awayTeam']?.toString() ?? '',
      date: dateValue(map['date']),
      competition: map['competition']?.toString() ?? '',
      venue: map['venue']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Scheduled',
      teamId: map['teamId']?.toString() ?? '',
      coachId: map['coachId']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
      homeScore: intValue(map['homeScore']),
      awayScore: intValue(map['awayScore']),
    );
  }

  Fixture copyWith({
    String? id,
    String? homeTeam,
    String? awayTeam,
    DateTime? date,
    String? competition,
    String? venue,
    String? status,
    String? teamId,
    String? coachId,
    String? notes,
    int? homeScore,
    int? awayScore,
  }) =>
      Fixture(
        id: id ?? this.id,
        homeTeam: homeTeam ?? this.homeTeam,
        awayTeam: awayTeam ?? this.awayTeam,
        date: date ?? this.date,
        competition: competition ?? this.competition,
        venue: venue ?? this.venue,
        status: status ?? this.status,
        teamId: teamId ?? this.teamId,
        coachId: coachId ?? this.coachId,
        notes: notes ?? this.notes,
        homeScore: homeScore ?? this.homeScore,
        awayScore: awayScore ?? this.awayScore,
      );
}
