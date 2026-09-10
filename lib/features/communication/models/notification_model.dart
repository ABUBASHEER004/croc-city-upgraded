class NotificationModel {
  const NotificationModel({this.id = '', this.title = ''});
  final String id;
  final String title;

  Map<String, dynamic> toMap() => {'id': id, 'title': title};

  factory NotificationModel.fromMap(Map<String, dynamic> map) => NotificationModel(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
      );
}
