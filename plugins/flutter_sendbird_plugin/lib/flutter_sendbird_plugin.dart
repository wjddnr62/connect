
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum SendBirdMessagingState {
  Connected,
  ConnectError,
  Joined,
  JoinError,
  MessageSent,
  MessageSendError,
  MessageReceived,
  Disconnected,
  DisconnectError,
  PreviousMessagesFetched,
  PreviousMessagesError,
  NextMessagesFetched,
  NextMessagesError,
  MessageResent,
  MessageResendError,
  PushTokenRegistered,
  PushTokenRegisterError,
  PushTokenUnregistered,
  PushTokenUnregisterError,
  Reconnect,
  Reconnected,
  ReconnectError,
  ChannelRefreshed,
  ChannelRefreshError,
}

enum SendBirdConnectionState { CONNECTING, OPEN, CLOSED }

typedef void SendBirdMessagingCallback(SendBirdMessagingResult result);

class SendBirdMessaging {
  factory SendBirdMessaging() => _instance;

  static final SendBirdMessaging _instance = SendBirdMessaging.private(
      const MethodChannel('sendbird_messaging/method_channel'),
      const EventChannel('sendbird_messaging/event_channel'));

  final MethodChannel _methodChannel;
  final Stream<SendBirdMessagingResult> _callbackStream;

  SendBirdMessaging.private(
      MethodChannel methodChannel, EventChannel eventChannel)
      : _methodChannel = methodChannel,
        _callbackStream = eventChannel.receiveBroadcastStream().map((data) {
          if (data is Map) {
            var dataState = data["state"] as String;
            var state = SendBirdMessagingState.values
                .firstWhere((e) => describeEnum(e) == dataState);
            var error = data["error"] as String;
            Map<String, dynamic> resultData;
            switch (state) {
              case SendBirdMessagingState.Connected:
                break;
              case SendBirdMessagingState.ConnectError:
                break;
              case SendBirdMessagingState.Joined:
                break;
              case SendBirdMessagingState.JoinError:
                break;
              case SendBirdMessagingState.MessageSent:
              case SendBirdMessagingState.MessageResent:
                resultData = {'request_id': data["request_id"]};
                break;
              case SendBirdMessagingState.MessageSendError:
              case SendBirdMessagingState.MessageResendError:
                resultData = {'request_id': data["request_id"]};
                break;
              case SendBirdMessagingState.MessageReceived:
                resultData = {
                  'message': SendBirdMessage(
                      data['sender_nickname'],
                      data['sender_id'],
                      data['request_id'],
                      data['message'],
                      data['created_at'])
                };
                break;
              case SendBirdMessagingState.Disconnected:
                break;
              case SendBirdMessagingState.DisconnectError:
                break;
              case SendBirdMessagingState.NextMessagesFetched:
              case SendBirdMessagingState.PreviousMessagesFetched:
                var messages = data["messages"];
                var messageList = List<SendBirdMessage>();
                if (messages != null && (messages is List)) {
                  for (var message in messages) {
                    messageList.add(SendBirdMessage(
                        message['sender_nickname'],
                        message['sender_id'],
                        message['request_id'],
                        message['message'],
                        message['created_at']));
                  }
                }
                resultData = {'messages': messageList};
                break;
              case SendBirdMessagingState.PreviousMessagesError:
              case SendBirdMessagingState.NextMessagesError:
                break;
              case SendBirdMessagingState.MessageResent:
                resultData = {'request_id': data["request_id"]};
                break;
              case SendBirdMessagingState.MessageResendError:
                break;
              case SendBirdMessagingState.PushTokenRegistered:
                break;
              case SendBirdMessagingState.PushTokenRegisterError:
                break;
              case SendBirdMessagingState.PushTokenUnregistered:
                break;
              case SendBirdMessagingState.PushTokenUnregisterError:
                break;
              case SendBirdMessagingState.Reconnect:
                break;
              case SendBirdMessagingState.Reconnected:
                break;
              case SendBirdMessagingState.ReconnectError:
                break;
              case SendBirdMessagingState.ChannelRefreshed:
                break;
              case SendBirdMessagingState.ChannelRefreshError:
                break;
            }
            return SendBirdMessagingResult(state, error, resultData);
          }
          return null;
        });

  void dispose() {}

  Stream<SendBirdMessagingResult> get callbackStream {
    return _callbackStream;
  }

  Future<void> init(String appId) async {
    await _methodChannel.invokeMethod('init', <String, dynamic>{
      'app_id': appId,
    });
  }

  Future<void> connect(String userId, String accessToken) async {
    await _methodChannel.invokeMethod('connect',
        <String, dynamic>{'user_id': userId, 'access_token': accessToken});
  }

  Future<void> disconnect() async {
    await _methodChannel.invokeMethod('disconnect', <String, dynamic>{});
  }

  Future<void> updateUserInfo(String nickname) async {
    await _methodChannel.invokeMethod('updateUserInfo', <String, dynamic>{
      'nickname': nickname,
    });
  }

  Future<void> registerPushToken(String pushToken) async {
    await _methodChannel.invokeMethod('registerPushToken', <String, dynamic>{
      'push_token': pushToken,
    });
  }

  Future<void> unregisterPushToken(String pushToken) async {
    await _methodChannel.invokeMethod('unregisterPushToken', <String, dynamic>{
      'push_token': pushToken,
    });
  }

  Future<void> join(String channelName, List<String> userIds) async {
    await _methodChannel.invokeMethod('join',
        <String, dynamic>{'channel_name': channelName, 'user_ids': userIds});
  }

  Future<void> fetchMessage(int timestamp, int limit, bool reserve) async {
    await _methodChannel.invokeMethod("fetchMessage", <String, dynamic>{
      'timestamp': timestamp,
      'limit': limit,
      'reserve': reserve
    });
  }

  Future<void> fetchPrevMessages(int timestamp, int limit, bool reserve) async {
    await _methodChannel.invokeMethod(
        "fetchPreviousMessages", <String, dynamic>{
      'timestamp': timestamp,
      'limit': limit,
      'reserve': reserve
    });
  }

  Future<void> fetchNextMessages(int timestamp, int limit, bool reserve) async {
    await _methodChannel.invokeMethod("fetchNextMessages", <String, dynamic>{
      'timestamp': timestamp,
      'limit': limit,
      'reserve': reserve
    });
  }

  Future<String> sendMessage(String message) async {
    return await _methodChannel
        .invokeMethod("sendMessage", <String, dynamic>{'message': message});
  }

  Future<void> resendMessage(String requestId) async {
    await _methodChannel.invokeMethod(
        "resendMessage", <String, dynamic>{'request_id': requestId});
  }

  Future<void> markAsRead() async {
    await _methodChannel.invokeMethod("markAsRead", <String, dynamic>{});
  }

  Future<void> startTyping() async {
    await _methodChannel.invokeMethod("startTyping", <String, dynamic>{});
  }

  Future<void> endTyping() async {
    await _methodChannel.invokeMethod("endTyping", <String, dynamic>{});
  }

  Future<void> reconnect() async {
    await _methodChannel.invokeMethod("reconnect", <String, dynamic>{});
  }

  Future<void> refreshChannel() async {
    await _methodChannel.invokeMethod("refreshChannel", <String, dynamic>{});
  }

  Future<SendBirdConnectionState> getConnectionState() async {
    String connectionState = await _methodChannel
        .invokeMethod("getConnectionState", <String, dynamic>{});
    return SendBirdConnectionState.values
        .firstWhere((e) => describeEnum(e) == connectionState);
  }

  Future<void> addConnectionHandler(String handlerId) async {
    await _methodChannel.invokeMethod(
        "addConnectionHandler", <String, dynamic>{'handler_id': handlerId});
  }

  Future<void> removeConnectionHandler(String handlerId) async {
    await _methodChannel.invokeMethod(
        "removeConnectionHandler", <String, dynamic>{'handler_id': handlerId});
  }

  Future<void> addChannelHandler(String handlerId) async {
    await _methodChannel.invokeMethod(
        "addChannelHandler", <String, dynamic>{'handler_id': handlerId});
  }

  Future<void> removeChannelHandler(String handlerId) async {
    await _methodChannel.invokeMethod(
        "removeChannelHandler", <String, dynamic>{'handler_id': handlerId});
  }

  Future<int> getUnreadMessageCount() async {
    return await _methodChannel
        .invokeMethod("getUnreadMessageCount", <String, dynamic>{});
  }

  Future<void> clearUnsentMessages() async {
    await _methodChannel
        .invokeMethod("clearUnsentMessages", <String, dynamic>{});
  }
}

class SendBirdMessagingResult {
  SendBirdMessagingState state;
  String error;
  Map<String, dynamic> data;

  SendBirdMessagingResult(this.state, this.error, this.data);
}

class SendBirdMessage {
  String senderNickname;
  String senderId;
  String requestId;
  String message;
  int createdAt;

  SendBirdMessage(this.senderNickname, this.senderId, this.requestId,
      this.message, this.createdAt);
}
