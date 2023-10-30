import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:connect/connect_firebase.dart';
import 'package:connect/conntect_const.dart';
import 'package:connect/models/push_notification.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

/// 반드시 전역에 선언되어 있어야 한다.
Future<dynamic> onBackgroundMessageForAndroid(
    Map<String, dynamic> message) async {
  Log.d('PushMessageHandler', "onBackground : message = $message");
  PushNotificationHandler handler = PushNotificationHandler();
  handler.showNotification(handler._createPushNotification(message));
}

class PushNotificationHandler {
  final _tag = 'PushMessageHandler';

  factory PushNotificationHandler() => _instance;

  PushNotificationHandler._internal();

  static final PushNotificationHandler _instance =
      PushNotificationHandler._internal();

  // ignore: close_sinks
  final PublishSubject<PushNotification> _notificationClickReceiver =
      PublishSubject();

  // ignore: close_sinks
  final PublishSubject<PushNotification> _notificationArriveReceiver =
      PublishSubject();

  PushNotification _pushNotificationOnLaunch;

  PushNotification getAndRemovePushNotificationOnLaunch() {
    var pushNotificationOnLaunch = _pushNotificationOnLaunch;
    _pushNotificationOnLaunch = null;
    return pushNotificationOnLaunch;
  }

  PublishSubject<PushNotification> get notificationClickReceiver =>
      _notificationClickReceiver;

  PublishSubject<PushNotification> get notificationArriveReceiver =>
      _notificationArriveReceiver;

  PushNotification _createPushNotification(Map<String, dynamic> message) {
    String type = Platform.isIOS ? message['type'] : message['data']['type'];

    if (type?.isNotEmpty == true) {
      String historyId = Platform.isIOS
          ? message['history_id']
          : message['data']['history_id'];
      String jsonData =
          Platform.isIOS ? message['json'] : message['data']['json'];
      var jsonMap = json.decode(jsonData);
      return PushNotification(json: jsonMap, historyId: historyId, type: type);
    } else {
      final pushMessage =
          Platform.isIOS ? message['aps']['alert'] : message['data']['message'];
      if (pushMessage != null) {
        final split = pushMessage.split(":");
        if (split != null && split.length >= 2) {
          HashMap<String, dynamic> map = HashMap();
          map['title'] = split[0].trim();
          map['contents'] = split[1].trim();
          return PushNotification(
              json: map, type: NotificationType.sendbird_messasing);
        }
      }
      return null;
    }
  }

  String selectedNotificationPayload;

  Future<void> initializeLocalNotification() async {
    final NotificationAppLaunchDetails notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload = notificationAppLaunchDetails.payload;
      Map<String, dynamic> notificationMap =
          json.decode(notificationAppLaunchDetails.payload);
      var notification = PushNotification(
          json: notificationMap['data']['json'],
          historyId: notificationMap['historyId'],
          type: notificationMap['type']);
      notificationClickReceiver.add(notification);
      if (notification.type == NotificationType.sendbird_messasing) {
        if (notificationClickReceiver.hasListener == false) {
          _pushNotificationOnLaunch = notification;
        }
      }
    }

    final initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      Log.d(_tag, "push : payload = $payload");
      Map<String, dynamic> notificationMap = json.decode(payload);
      var notification = PushNotification(
          json: notificationMap['data']['json'],
          historyId: notificationMap['historyId'],
          type: notificationMap['type']);
      notificationClickReceiver.add(notification);
      if (notification.type == NotificationType.sendbird_messasing) {
        if (notificationClickReceiver.hasListener == false) {
          _pushNotificationOnLaunch = notification;
        }
      }
    });
  }

  void configurePushMessaging() {
    try {
      gFirebaseMessaging.configure(
        //when message received in foreground
        onMessage: (Map<String, dynamic> message) async {
          Log.d(_tag, "onMessage : message = $message");
          notificationArriveReceiver.add(_createPushNotification(message));
          showNotification(_createPushNotification(message));
        },
        //when user clicks notification with app terminated on iOS
        onLaunch: (Map<String, dynamic> message) async {
          Log.d(_tag, "onLaunch : message = $message");
          _pushNotificationOnLaunch = _createPushNotification(message);
        },
        //when user clicks notification in background on iOS
        onResume: (Map<String, dynamic> message) async {
          Log.d(_tag, "onResume : message = $message");
          if (_notificationClickReceiver.hasListener) {
            notificationClickReceiver.add(_createPushNotification(message));
          } else {
            _pushNotificationOnLaunch = _createPushNotification(message);
          }
        },
        //when data message received in background on android (only sendbird)
        onBackgroundMessage:
            Platform.isIOS ? null : onBackgroundMessageForAndroid,
      );
    } on Exception catch (e) {
      Log.d(_tag, '$e');
    }
  }

  Future showNotification(PushNotification pushNotification) async {
    if (pushNotification?.title?.isNotEmpty == true &&
        pushNotification?.contents?.isNotEmpty == true) {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          NotiConst.CHANNEL_ID,
          AppStrings.of(StringKey.notification),
          AppStrings.of(StringKey.notification),
          importance: Importance.max,
          priority: Priority.high,
          color: AppColors.white,
          icon: "ic_stat_noti");
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          DateTime.now().millisecond,
          pushNotification.title,
          pushNotification.contents,
          platformChannelSpecifics,
          payload: json.encode(pushNotification));
    }
  }
}
