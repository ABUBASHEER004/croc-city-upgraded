import 'package:cloud_firestore/cloud_firestore.dart';

class AcademyCalendarEvent {
  final String id, title, description, category, venue, createdBy, createdByName;
  final DateTime startAt, endAt, updatedAt;
  final bool published;

  const AcademyCalendarEvent({required this.id, required this.title, required this.description, required this.category, required this.startAt, required this.endAt, required this.venue, required this.published, required this.createdBy, required this.createdByName, required this.updatedAt});

  factory AcademyCalendarEvent.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    DateTime date(dynamic v, [DateTime? fallback]) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.tryParse(v?.toString() ?? '') ?? fallback ?? DateTime.now();
    }
    final start = date(d['startAt']);
    return AcademyCalendarEvent(
      id: doc.id,
      title: d['title']?.toString() ?? 'Academy Event',
      description: d['description']?.toString() ?? '',
      category: d['category']?.toString() ?? 'General',
      startAt: start,
      endAt: date(d['endAt'], start.add(const Duration(hours: 1))),
      venue: d['venue']?.toString() ?? '',
      published: d['published'] == true,
      createdBy: d['createdBy']?.toString() ?? '',
      createdByName: d['createdByName']?.toString() ?? 'Academy Admin',
      updatedAt: date(d['updatedAt'], start),
    );
  }
}
