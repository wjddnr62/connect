import 'package:flutter/foundation.dart';

class PushMessage {
  final int id;
  final String title;
  final String body;
  final String payload;

  PushMessage(
      {@required this.id,
      @required this.title,
      @required this.body,
      @required this.payload});
}
