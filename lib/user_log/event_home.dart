import 'package:connect/utils/logger/log.dart';

import '../connect_firebase.dart';

class EventHome {
  static const _tag = 'EVENT';

  static Future<void> openNotificationList() {
    Log.d(_tag, 'home_open_notifications');
    return gAnalytics.logEvent(name: 'home_open_notification_list');
  }

  static Future<void> openDrawer() {
    Log.d(_tag, 'home_open_drawer');
    return gAnalytics.logEvent(name: 'home_open_drawer');
  }

  static Future<void> openTextChat() {
    Log.d(_tag, 'home_open_text_chat');
    return gAnalytics.logEvent(name: 'home_open_text_chat');
  }
}
