import 'package:connect/data/remote/push/all_read_history_service.dart';
import 'package:connect/data/remote/push/push_history_service.dart';
import 'package:connect/data/remote/push/read_update_history_service.dart';
import 'package:connect/data/remote/push/unread_check_service.dart';
import 'package:connect/models/push_history.dart';

class PushRepository {
  static Future<dynamic> getPushHistory(int page, int size) {
//      return _createMock();
    return PushHistoryService(page, size).start();
  }

//  static Future<PushHistory> _createMock() {
//
//    var res = PushHistory(contents:List<PushNotification>.generate(10, (index) {
//      return PushNotification(created: DateTime.now().toIso8601String(), title: "", body: "테스트 $index", isRead: false);
//    });, page_info:PageInfo(page_number: 0, total_count: 10, total_page: 1));
//
//    return Future.value(res);
//  }

  static Future<dynamic> readUpdate(PushHistory history) {
    return ReadUpdateHistoryService(history).start();
  }

  static Future<dynamic> readAllUpdate() {
    return AllReadHistoryService().start();
  }

  static Future<dynamic> unreadCheck() {
    return UnReadCheckService().start();
  }
}
