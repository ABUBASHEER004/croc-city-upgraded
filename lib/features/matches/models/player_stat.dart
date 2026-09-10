class PlayerStat {
  const PlayerStat({this.id = '', this.title = ''});
  final String id;
  final String title;

  Map<String, dynamic> toMap() => {'id': id, 'title': title};

  factory PlayerStat.fromMap(Map<String, dynamic> map) => PlayerStat(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
      );
}
