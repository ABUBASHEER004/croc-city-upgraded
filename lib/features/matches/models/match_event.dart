class MatchEvent {
  const MatchEvent({this.id = '', this.title = ''});
  final String id;
  final String title;

  Map<String, dynamic> toMap() => {'id': id, 'title': title};

  factory MatchEvent.fromMap(Map<String, dynamic> map) => MatchEvent(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
      );
}
