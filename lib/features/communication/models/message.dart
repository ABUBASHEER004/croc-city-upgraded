class Message {
  const Message({this.id = '', this.title = ''});
  final String id;
  final String title;

  Map<String, dynamic> toMap() => {'id': id, 'title': title};

  factory Message.fromMap(Map<String, dynamic> map) => Message(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
      );
}
