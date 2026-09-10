class Match {
  const Match({this.id = '', this.title = ''});
  final String id;
  final String title;

  Map<String, dynamic> toMap() => {'id': id, 'title': title};

  factory Match.fromMap(Map<String, dynamic> map) => Match(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
      );
}
