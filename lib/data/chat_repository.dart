import 'package:connect/data/remote/chat/chat_services.dart';
import 'package:connect/data/remote/video/video_call_join_service.dart';
import 'package:connect/models/schedule.dart';

class ChatRepository {
  static String _formatDate(DateTime dateTime) {
    int month = dateTime.month;
    String monthString = month < 10 ? '0$month' : '$month';

    int day = dateTime.day;
    String dayString = day < 10 ? '0$day' : '$day';

    return '${dateTime.year}-$monthString-$dayString';
  }

  static Future<dynamic> registerVideoCall(
      DateTime date, String start, String end) async {
    return await RequestRegisterVideoCallService(
      RequestSchedule(
        startDate: _formatDate(date),
        startTime: start,
        endDate: _formatDate(date),
        endTime: end,
        zoneOffset: DateTime.now().timeZoneOffset.inMinutes,
      ),
    ).start();
  }

  static Future<dynamic> joinVideoCall(String id) async {
    return await VideoCallJoinService(id).start();
  }

  static Future<dynamic> getTextChatToken() async {
    return await GetTextChatToken().start();
  }

  static Future<dynamic> requestCancelVideoCall(
      {final Schedule schedule}) async {
    assert(schedule != null);
    return await CancelVideoCall(id: schedule.id).start();
  }
}
