class Conversation {
  const Conversation({this.id = '', this.title = ''});
  final String id;
  final String title;

  Map<String, dynamic> toMap() => {'id': id, 'title': title};

  factory Conversation.fromMap(Map<String, dynamic> map) => Conversation(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
      );
}
