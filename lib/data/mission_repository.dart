import 'package:connect/data/remote/mission/feedback_service.dart';
import 'package:connect/data/remote/mission/mission_service.dart';
import 'package:connect/models/error.dart';
import 'package:connect/utils/extensions.dart';

class MissionRepository {
  static Future<dynamic> getDailyMissions({DateTime date}) async {
    var response =
        await GetMissionsService(startDate: date, endDate: date).start();
    if (response is ServiceError) {
      return response;
    }

    if (response == null) {
      return null;
    }

    return response[0];
  }

  static Future<dynamic> getWeeklyMissions({DateTime date}) {
    return GetMissionsService(startDate: date.weekStart, endDate: date.weekEnd)
        .start();
  }

  static Future<dynamic> getMissions({DateTime date}) {
    return GetMissionsRenewalService(startDate: date, endDate: date).start();
  }

  static Future<dynamic> complete(String id) {
    return ActionService(missionId: id, completed: true).start();
  }

  static Future<dynamic> undo(String id) {
    return ActionService(missionId: id, completed: false).start();
  }

  static Future<dynamic> feedback() {
    return FeedbackService().start();
  }

  static Future<dynamic> getPerformHistory({DateTime date, int userId}) {
    return PerformHistoryService(dateTime: date, userId: userId).start();
  }

  static Future<dynamic> getPerformPeriod({String startDate, String endDate}) {
    return PerformPeriodService(startDate: startDate, endDate: endDate).start();
  }
}
