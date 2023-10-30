import 'package:collection/collection.dart';
import 'package:connect/connect_firebase.dart';
import 'package:connect/data/chat_repository.dart';
import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/chat/text/chat_model.dart';
import 'package:connect/feature/chat/text/chat_state.dart';
import 'package:connect/feature/splash/splash_bloc.dart';
import 'package:connect/feature/user/account/account_bloc.dart';
import 'package:connect/models/chat.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/models/stroke_coach.dart';
import 'package:connect/models/working_hours.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter_sendbird_plugin/flutter_sendbird_plugin.dart';

class TextChatBloc extends BaseBloc {
  static const _tag = 'TextChatBloc';

  StrokeCoach strokeCoach;
  WorkingHours workingHours;
  var ownId = "";
  final chatList = List<Chat>();
  var isKeyboardFocus = false;

  TextChatBloc() : super(ChatUIRefreshState()) {
    gSendBirdMessagingController.addCallback(onSendBirdMessagingCallback);
  }

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    debugPrint("$runtimeType / event receive ! $event");

    if (event is ChatJoinRequestEvent) {
      if (!(await _chatJoin(event.fcmToken))) {
        yield MyOTInfoNotSet();
        return;
      }

      yield ChatUIRefreshState();
      return;
    }

    if (event is ChatSendEvent) {
      debugPrint("Message send!");
      final requestId =
          await gSendBirdMessagingController.sendMessage(event.chat);
      final chat = Chat(ownId, event.chat, requestId, DateTime.now());
      chatList.insert(0, chat);
      yield ChatAddState(chat);
      return;
    }

    if (event is ChatMoveToTherapistInfoEvent) {
      yield ChatMoveToTherapistInfoState();
      return;
    }

    if (event is ChatUIRefreshEvent) {
      yield ChatUIRefreshState();
      return;
    }

    if (event is ChatChannelEvent) {
      yield ChatChannelState(event._data);
    }

    if (event is ChatMaxScrollEvent) {
      var lastTime = _getLastTime();
      debugPrint("max scroll event!!!");
      await initChatList(time: lastTime);
    }

    if (event is ChatResendEvent) {
      event.chat.state = ChatState.PENDING;
      gSendBirdMessagingController.resendMessage(event.chat.requestId);
      yield ChatUIRefreshState();
    }

    if (event is ChatErrorEvent) {
      yield ChatErrorState(event.errorMessage);
    }

    if (event is ChatConnectingEvent) {
      yield ChatConnectingState();
    }

    return;
  }

  int getListTileCount() {
    return _createChatTileList().length;
  }

  DateTime _getLastTime() {
    var time = DateTime.now();

    for (final chat in chatList)
      time = chat.sendDate.millisecondsSinceEpoch < time.millisecondsSinceEpoch
          ? chat.sendDate
          : time;

    return time;
  }

  // return DateTime or Chat
  dynamic getListTileItem(int index, int definedMaxSize) {
    var list = _createChatTileList().toList();
    if (list.length != definedMaxSize) {
      debugPrint(
          "defined size and current size not match!!!! : ${list.length} / $definedMaxSize");
    }
    return list[index];
  }

  Iterable<dynamic> _createChatTileList() {
    final chatDateGroup = groupBy(chatList, (Chat chat) {
      final date =
          DateTime(chat.sendDate.year, chat.sendDate.month, chat.sendDate.day);
      return date;
    });
    var res = chatDateGroup.entries.map((entry) {
      final List<dynamic> returnList = List.from(entry.value);
      returnList.add(entry.key);
      return returnList;
    }).expand((item) => item);

    return res;
  }

  Future<bool> _chatJoin(String fcmToken) async {
    Profile profile;
    try {
      profile = (await UserRepository.getProfile() as Profile);
      strokeCoach = profile.strokeCoach;

      /// 근무시간이 없으면 오류가 발생
      /// 근무시간이 있더라도 현재 시간하고 비교하고 있지 않기 때문에 주석 처리함
//      workingHours = await StrokeCoachRepository.getStrokeCoachWorkingHours();
    } catch (e) {
      debugPrint("Error !! $e");
      return false;
    }

    if (strokeCoach?.id == null) {
      return false;
    }

    final id = await AppDao.userId;
    String token;
    try {
      token =
          (await ChatRepository.getTextChatToken() as ChatToken).accessToken;
    } catch (e) {
      debugPrint("Error !! $e");
      return false;
    }
    ownId = id.toString();
    debugPrint(
        "chat join preapared! token : $token / [$ownId , ${strokeCoach.id} ]");
    debugPrint("img : ${strokeCoach.image}");
    //연결된적이 있으면 reconnect , 현재 connectAndJoin 상태면 호출할 필요가 없다.
    var connectAndJoined = await gSendBirdMessagingController.connectAndJoin(
        profile.id.toString(),
        profile.name,
        token,
        gFcmId,
        strokeCoach.id.toString());
    if (connectAndJoined) {
      initChatList(time: null);
    }
    return true;
  }

  Future<void> dispose() async {
    chatList.clear();
    strokeCoach = null;
    isKeyboardFocus = false;
    await gSendBirdMessagingController.clearUnsentMessages();
    await gSendBirdMessagingController
        .removeCallback(onSendBirdMessagingCallback);
    gSendBirdMessagingController.unreadMessageCountStreamController
        .add("onTextChatPagePop");
  }

  void onSendBirdMessagingCallback(SendBirdMessagingResult result) {
    switch (result.state) {
      case SendBirdMessagingState.Joined:
        Log.d(_tag,
            "[onSendBirdMessagingCallback]Succeeded to Join Channel : state =$result.state");
        initChatList(time: null);
        break;
      case SendBirdMessagingState.JoinError:
        Log.d(_tag, "[onSendBirdMessagingCallback]Failed to Join Channel");
        break;
      case SendBirdMessagingState.MessageSent:
      case SendBirdMessagingState.MessageResent:
        updateSendStatus(result: result, state: ChatState.SUCCESS);
        break;
      case SendBirdMessagingState.MessageSendError:
      case SendBirdMessagingState.MessageResendError:
        updateSendStatus(
            requestId: result.data["request_id"], state: ChatState.ERROR);
        break;
      case SendBirdMessagingState.PreviousMessagesFetched:
        gSendBirdMessagingController.markAsRead();
        messageFetch(result, true);
        break;
      case SendBirdMessagingState.MessageReceived:
        gSendBirdMessagingController.markAsRead();
        if (_addChatDistinct(result.data["message"], false))
          add(ChatChannelEvent(result));
        break;
      case SendBirdMessagingState.Reconnect:
        add(ChatConnectingEvent());
        break;
      case SendBirdMessagingState.NextMessagesFetched:
        gSendBirdMessagingController.markAsRead();
        messageFetch(result, false);
        if (_addChatDistinct(result.data["message"], false))
          add(ChatChannelEvent(result));
        break;
      default:
        Log.d(_tag, "[onSendBirdMessagingCallback]state : ${result.state}");
        if (result.error != null) {
          add(ChatErrorEvent(result.error));
        }
        break;
    }
  }

  void messageFetch(SendBirdMessagingResult result, isPrevious) {
    final List<dynamic> messages = result.data["messages"];

    var fetchRequire = true;

    for (final msg in messages) {
      fetchRequire = _addChatDistinct(msg, isPrevious) ? true : fetchRequire;
    }

    if (fetchRequire) {
      debugPrint("fetch list!");
      add(ChatChannelEvent(result));
    }
  }

  void updateSendStatus(
      {SendBirdMessagingResult result,
      String requestId,
      @required ChatState state}) {
    if (result == null && requestId == null)
      throw Exception("SendData and requestId all Null!!!");

    final id = requestId ?? result.data["request_id"];
    final targetMsg = chatList.singleWhere((e) {
      return e.requestId == id && !e.isTherapist(ownId);
    });
    targetMsg.state = state;
    add(ChatChannelEvent(result));
  }

  bool _addChatDistinct(msg, isPrevious) {
    final sender = msg.senderId;
    final requestId = msg.requestId;

//    for (final exist in chatList) {
//      if (exist.sender == sender && exist.requestId == requestId) {
//        return false;
//      }
//    }

    final chat = Chat(sender, msg.message, requestId,
        DateTime.fromMillisecondsSinceEpoch(msg.createdAt),
        state: ChatState.SUCCESS);
    isPrevious ? chatList.add(chat) : chatList.insert(0, chat);
    return true;
  }

  Future<void> initChatList({@required DateTime time}) async {
    if (time == null) {
      chatList.clear();
      add(ChatUIRefreshEvent());
    }

    final timestamp = (time ?? DateTime.now()).millisecondsSinceEpoch;
    gSendBirdMessagingController.fetchPrevMessages(timestamp, 30, true);
  }

  Future<void> startTyping() async {
    gSendBirdMessagingController.startTyping();
  }

  Future<void> endTyping() async {
    gSendBirdMessagingController.endTyping();
  }
}

class ChatSendEvent extends BaseBlocEvent {
  final String chat;

  ChatSendEvent(this.chat);
}

class ChatChannelEvent extends BaseBlocEvent {
  final SendBirdMessagingResult _data;
  final DateTime eventTime = DateTime.now();

  ChatChannelEvent(this._data);

  @override
  List<Object> get props => [eventTime];
}

class ChatMoveToTherapistInfoEvent extends BaseBlocEvent {}

class ChatUIRefreshEvent extends BaseBlocEvent {}

class ChatMaxScrollEvent extends BaseBlocEvent {}

class ChatResendEvent extends BaseBlocEvent {
  final Chat chat;

  ChatResendEvent(this.chat);
}

class ChatJoinRequestEvent extends BaseBlocEvent {
  final String fcmToken;

  ChatJoinRequestEvent(this.fcmToken);
}

class ChatErrorEvent extends BaseBlocEvent {
  final String errorMessage;

  ChatErrorEvent(this.errorMessage);
}

class ChatConnectingEvent extends BaseBlocEvent {}

class ChatAddState extends BaseBlocState {
  final Chat chat;

  ChatAddState(this.chat);

  @override
  List<Object> get props => [chat];
}

class ChatChannelState extends BaseBlocState {
  final SendBirdMessagingResult _data;
  final DateTime eventTime = DateTime.now();

  ChatChannelState(this._data);

  @override
  List<Object> get props => [eventTime];
}

class ChatUIRefreshState extends BaseBlocState {
  @override
  List<Object> get props => [DateTime.now()];
}

class ChatMoveToTherapistInfoState extends BaseBlocState {
  final _key = DateTime.now();

  @override
  List<Object> get props => [_key];
}

class ChatErrorState extends BaseBlocState {
  final String errorMessage;

  ChatErrorState(this.errorMessage);
}

class ChatConnectingState extends BaseBlocState {
  @override
  List<Object> get props => [DateTime.now()];
}
