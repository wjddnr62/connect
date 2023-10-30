import 'package:connect/data/remote/schedule/schedule_service.dart';

class ScheduleRepository {
  static Future<dynamic> getUpcomingSchedule() async {
    return await GetUpcomingSchedulesService().start();
  }

  static Future<dynamic> getSchedule({DateTime date}) async {
    return await GetDailyScheduleService(date).start();
  }

  static Future<dynamic> getWeeklySchedules({DateTime date}) async {
    return await GetWeeklySchedulesService(date).start();
  }

  static Future<dynamic> getTimeSlot(DateTime date) async {
    return await GetPossibleTimeSlotsService(date).start();
  }

  static Future<dynamic> getScheduleDetail(String id) async {
    return await GetScheduleDetailService(id).start();
  }
}
