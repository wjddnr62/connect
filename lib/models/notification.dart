class NotificationMessage {
  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime created;

  NotificationMessage(
      {this.id, this.type, this.title, this.body, this.created});

  factory NotificationMessage.fromJson(Map<String, dynamic> map) {
    DateTime dateTime = DateTime.parse(map['created'] as String);
    return NotificationMessage(
      id: map['id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      created: dateTime,
    );
  }
}
