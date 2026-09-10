class Lineup {
  const Lineup({this.id = '', this.title = ''});
  final String id;
  final String title;

  Map<String, dynamic> toMap() => {'id': id, 'title': title};

  factory Lineup.fromMap(Map<String, dynamic> map) => Lineup(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
      );
}
