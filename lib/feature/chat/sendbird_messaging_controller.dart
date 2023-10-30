import 'dart:async';

import 'package:connect/utils/logger/log.dart';
import 'package:connect/utils/push/push_notification_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sendbird_plugin/flutter_sendbird_plugin.dart';
import 'package:rxdart/rxdart.dart';
import 'package:connect/utils/extensions.dart';

typedef SendBirdMessagingCallback = void Function(SendBirdMessagingResult);

class SendBirdMessagingController extends WidgetsBindingObserver {
  static const _tag = 'SendBirdMessagingController';

  factory SendBirdMessagingController() => _instance;

  SendBirdMessagingController.private();

  static final SendBirdMessagingController _instance =
      SendBirdMessagingController.private();

  final SendBirdMessaging _sendBirdMessaging = SendBirdMessaging();

  static const messageNotificationType = "sendbird_message";
  static const messagePayload = messageNotificationType;

  static const CONNECTION_HANDLER_ID = "connection/own";
  static const CHANNEL_HANDLER_ID = "channel/theraphist/single";

  bool _didConnectedAndJoined = false;
  bool _didDeviceTokenRegistered = false;

  String _userId;
  String _userName;
  String _accessToken;
  String _pushToken;
  String _therapistId;

  StreamSubscription _callbackSubscription;

  final unreadMessageCountStreamController = StreamController.broadcast();

  get onUnreadMessageCountReceived {
    return unreadMessageCountStreamController.stream
        .throttleTime(Duration(milliseconds: 500))
        .asyncMap(
            (dynamic d) async => await getUnreadMessageCount().then((onValue) {
                  return onValue;
                }));
  }

  int reconnectTime;

  void init(String appId) {
    _sendBirdMessaging.init(appId);

    WidgetsBinding.instance.addObserver(this);
    _callbackSubscription =
        _sendBirdMessaging.callbackStream.listen((result) async {
      Log.d(_tag, "[callback]state=" + result.state.toString());
      callbacks.forEach((callback) => callback(result));
      switch (result.state) {
        case SendBirdMessagingState.MessageReceived:
          if (callbacks.isEmpty) {
            var message = result.data['message'];

            if (message is SendBirdMessage) {
              unreadMessageCountStreamController.add("onMessagedReceived");
              await PushNotificationHandler().showNotification(message.toPushNotification());
            }
          }
          break;
        case SendBirdMessagingState.Reconnect:
          reconnectTime =
              reconnectTime ?? DateTime.now().millisecondsSinceEpoch;
          break;
        case SendBirdMessagingState.Reconnected:
          _sendBirdMessaging.refreshChannel();
          break;
        case SendBirdMessagingState.ChannelRefreshed:
          if (reconnectTime != null) {
            Log.d(
                _tag,
                "fecthTime=" +
                    DateTime.fromMicrosecondsSinceEpoch(reconnectTime)
                        .toString());
            _sendBirdMessaging.fetchNextMessages(reconnectTime, 100, false);
          }
          reconnectTime = null;
          break;
        case SendBirdMessagingState.ChannelRefreshError:
          Log.d(_tag,
              "[connectAndJoin]Failed To Refresh Channel, Attempt to Join");
          _join();
          break;
        case SendBirdMessagingState.Joined:
          _didConnectedAndJoined = true;
          if (_userName != null && _userName.isNotEmpty)
            _sendBirdMessaging.updateUserInfo(_userName);
          break;
        case SendBirdMessagingState.JoinError:
          _sendBirdMessaging.disconnect();
          _didConnectedAndJoined = false;
          break;
        case SendBirdMessagingState.NextMessagesFetched:
          if (callbacks.isEmpty) {
//            var messageList = result.data['messages'];
//            for (var message in messageList) {
//              if (message is SendBirdMessage) {
//                await PushNotificationHandler().showNotification(message.toPushNotification());
//              }
//            }
            unreadMessageCountStreamController.add("onMessageFetched");
          }
          break;
        default:
          break;
      }
    });
  }

  void dispose() {
    Log.d(_tag, "[dispose]");
    _callbackSubscription?.cancel();
    _callbackSubscription = null;
    removeConnectionAndChannelHandler();
    WidgetsBinding.instance.removeObserver(this);
  }

  List<SendBirdMessagingCallback> callbacks = new List();

  void addCallback(SendBirdMessagingCallback callback) {
    callbacks.add(callback);
  }

  void removeCallback(SendBirdMessagingCallback callback) {
    callbacks.remove(callback);
  }

  Future<bool> connectAndJoin(String userId, String userName,
      String accessToken, String pushToken, String strokeCoach) async {
    _userId = userId;
    _userName = userName;
    _accessToken = accessToken;
    _pushToken = pushToken;
    _therapistId = strokeCoach;

    SendBirdConnectionState connectionState =
        await _sendBirdMessaging.getConnectionState();
    Log.d(_tag, "[connectAndJoin]connectionState=$connectionState");
    if (_didConnectedAndJoined == false) {
      Log.d(_tag, "[connectAndJoin] Connect has been called");
      _sendBirdMessaging.connect(_userId, _accessToken);
    } else {
      switch (connectionState) {
        case SendBirdConnectionState.CONNECTING:
          break;
        case SendBirdConnectionState.OPEN:
          return true;
        case SendBirdConnectionState.CLOSED:
          Log.d(_tag, "[connectAndJoin] Reconnect has been called");
          _sendBirdMessaging.reconnect();
          break;
      }
    }
    subscribeCallback();
    return false;
  }

  void subscribeCallback() {
     StreamSubscription subscription;
    subscription = _sendBirdMessaging.callbackStream.listen((result) {
      Log.d(_tag, "[connectAndJoin]callback state=" + result.state.toString());
      switch (result.state) {
        case SendBirdMessagingState.Connected:
        case SendBirdMessagingState.Reconnected:
          if (_didDeviceTokenRegistered) {
            Log.d(_tag, "[connectAndJoin]join");
            _join();
          } else {
            Log.d(_tag, "[connectAndJoin]registerPushToken");
            _sendBirdMessaging.registerPushToken(_pushToken);
          }
          break;
        case SendBirdMessagingState.ConnectError:
          subscription.cancel();
          break;
        case SendBirdMessagingState.PushTokenRegistered:
          _didDeviceTokenRegistered = true;
          _join();
          break;
        case SendBirdMessagingState.PushTokenRegisterError:
          subscription.cancel();
          _sendBirdMessaging.disconnect();
          _didDeviceTokenRegistered = false;
          break;
        case SendBirdMessagingState.Joined:
          subscription.cancel();
          //연결 성공
          _didConnectedAndJoined = true;
          addConnectionAndChannelHandler();

          unreadMessageCountStreamController.add("onChannelJoined");
          break;
        case SendBirdMessagingState.JoinError:
          subscription.cancel();
          _sendBirdMessaging.disconnect();
          _didDeviceTokenRegistered = false;
          break;
        default:
          break;
      }
    });
  }

  void reconnect() {
    _sendBirdMessaging.reconnect();
    subscribeCallback();
  }

  void _join() {
    var channelName = "personal_channel_$_userId";
    _sendBirdMessaging.join(channelName, [_userId, _therapistId]);
  }

  Future<String> sendMessage(String message) {
    return _sendBirdMessaging.sendMessage(message);
  }

  void resendMessage(String requestId) {
    _sendBirdMessaging.resendMessage(requestId);
  }

  void fetchPrevMessages(int timestamp, int limit, bool reserve) {
    _sendBirdMessaging.fetchPrevMessages(timestamp, limit, reserve);
  }

  void fetchNextMessages(int timestamp, int limit, bool reserve) {
    _sendBirdMessaging.fetchNextMessages(timestamp, limit, reserve);
  }

  void markAsRead() {
    _sendBirdMessaging.markAsRead();
  }

  void startTyping() {
    _sendBirdMessaging.startTyping();
  }

  void endTyping() {
    _sendBirdMessaging.endTyping();
  }

  void disconnect(SendBirdMessagingCallback callback) {
    if (_didConnectedAndJoined == false) {
      callback(SendBirdMessagingResult(SendBirdMessagingState.DisconnectError,
          "not yet connected to sendbird", null));
      return;
    }
    _sendBirdMessaging.unregisterPushToken(_pushToken);
    StreamSubscription subscription;
    subscription = _sendBirdMessaging.callbackStream.listen((result) {
      switch (result.state) {
        case SendBirdMessagingState.PushTokenUnregistered:
          _sendBirdMessaging.disconnect();
          break;
        case SendBirdMessagingState.PushTokenUnregisterError:
          subscription.cancel();
          callback(result);
          break;
        case SendBirdMessagingState.Disconnected:
          subscription.cancel();
          callback(result);
          removeConnectionAndChannelHandler();
          _didConnectedAndJoined = false;
          break;
        case SendBirdMessagingState.DisconnectError:
          subscription.cancel();
          callback(result);
          break;
        default:
          break;
      }
    });
  }

  Future<SendBirdConnectionState> getConnectionState() async {
    return _sendBirdMessaging.getConnectionState();
  }

  void addConnectionAndChannelHandler() {
    if (_didConnectedAndJoined) {
      _sendBirdMessaging.addConnectionHandler(CONNECTION_HANDLER_ID);
      _sendBirdMessaging.addChannelHandler(CHANNEL_HANDLER_ID);
    }
  }

  void removeConnectionAndChannelHandler() {
    if (_didConnectedAndJoined) {
      _sendBirdMessaging.removeConnectionHandler(CONNECTION_HANDLER_ID);
      _sendBirdMessaging.removeChannelHandler(CHANNEL_HANDLER_ID);
    }
  }

  Future<int> getUnreadMessageCount() async {
    var count = await _sendBirdMessaging.getUnreadMessageCount();
    Log.d(_tag, "[unreadMessageCount]count=" + count.toString());
    return _sendBirdMessaging.getUnreadMessageCount();
  }

  void clearUnsentMessages() {
    _sendBirdMessaging.clearUnsentMessages();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_didConnectedAndJoined == false) {
      return;
    }
    switch (state) {
      case AppLifecycleState.paused:
        Log.d(_tag,
            "[didChangeAppLifecycleState]App Paused, removeConnectionAndChannelHandler");
        removeConnectionAndChannelHandler();
        reconnectTime = reconnectTime ?? DateTime.now().millisecondsSinceEpoch;
        break;
      case AppLifecycleState.resumed:
        Log.d(_tag,
            "[didChangeAppLifecycleState]App Resumed, addConnectionAndChannelHandler");
        addConnectionAndChannelHandler();
        final connectionState = await _sendBirdMessaging.getConnectionState();
        Log.d(_tag,
            "[didChangeAppLifecycleState] sendbird connectionState=$connectionState");
        if (connectionState == SendBirdConnectionState.CONNECTING) {
          //connectionHandler 등록이 reconnect 응답이 오는 것보다 늦어서 재전송함
          callbacks.forEach((callback) => callback(SendBirdMessagingResult(
              SendBirdMessagingState.Reconnect, null, null)));
        }
        break;
      default:
        break;
    }
  }

  Future<void> connectAndRegisterPushToken(String userId,
      String accessToken, String pushToken) async {

    _sendBirdMessaging.connect(userId, accessToken);

    StreamSubscription subscription;
    subscription = _sendBirdMessaging.callbackStream.listen((result) {
      Log.d(_tag, "[connectAndRegisterPushToken]callback state=" + result.state.toString());
      switch (result.state) {
        case SendBirdMessagingState.Connected:
          _sendBirdMessaging.registerPushToken(pushToken);
          break;
        case SendBirdMessagingState.ConnectError:
          subscription.cancel();
          _sendBirdMessaging.disconnect();
          break;
        case SendBirdMessagingState.PushTokenRegistered:
          subscription.cancel();
          _sendBirdMessaging.disconnect();
          break;
        case SendBirdMessagingState.PushTokenRegisterError:
          subscription.cancel();
          _sendBirdMessaging.disconnect();
          break;
        default:
          break;
      }
    });
  }
}
