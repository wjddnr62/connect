import 'package:flutter/foundation.dart';

class Log {
  static d(String tag, message) {
    debugPrint('[' + tag + ']' + ':' + message);
  }

  static i(String tag, message) {
    print('[' + tag + ']' + ':' + message);
  }
}
