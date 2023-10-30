import 'package:connect/feature/chat/text/chat_state.dart';
import 'package:connect/utils/date_format.dart';

class Chat {
  String msg;
  String sender;
  String requestId;
  DateTime sendDate;
  ChatState state;

  Chat(this.sender, this.msg, this.requestId, this.sendDate,
      {this.state = ChatState.PENDING});

  bool isTherapist(String myOwnId) {
    return sender != myOwnId;
  }

  String getTimeString() {
    return DateFormat.formatIntl("hh:mm a", sendDate);
  }
}
