import 'package:connect/connect_firebase.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/utils/logger/log.dart';

class UserLogger {
  static final String _tagEvent = 'EVENT';
  static final String _tagScreen = 'SCREEN';

  static Future<void> logEventName(
      {String eventName, Map<String, dynamic> param}) {
    if (eventName == null || eventName.isEmpty) {
      return Future.value();
    }

    Log.d(_tagEvent, '$eventName');
    return gAnalytics.logEvent(name: eventName, parameters: param);
  }

  static Future<void> logEvent({BaseBlocEvent blocEvent}) {
    if (blocEvent == null || blocEvent.tag == null || blocEvent.tag.isEmpty) {
      return Future.value();
    }

    Log.d(_tagEvent, '${blocEvent.tag}');
    return gAnalytics.logEvent(name: blocEvent.tag);
  }

  static Future<void> logState({BaseBlocState blocState}) {
    if (blocState == null || blocState.tag == null || blocState.tag.isEmpty) {
      return Future.value();
    }

    Log.d(_tagEvent, '${blocState.tag}');
    return gAnalytics.logEvent(name: blocState.tag);
  }

  static Future<void> screen({String screen}) {
    if (screen == null || screen.isEmpty || screen == 'null') {
      return Future.value();
    }

    if (screen == '/splash_after_login_before_profile_page' ||
        screen == '/splash_after_login_after_profile_page') {
      screen = '/splash_page';
    }

    screen = screen.substring(1, screen.length);

    Log.d(_tagScreen, screen.isEmpty ? 'splash_page' : screen);
    return gAnalytics.setCurrentScreen(
        screenName: screen.isEmpty ? 'splash_page' : screen);
  }
}
