import 'package:connect/models/schedule.dart';
import 'package:connect/utils/extensions.dart';
import 'package:http/http.dart' as http;

import '../base_service.dart';

class GetDailyScheduleService extends BaseService<List<Schedule>> {
  final DateTime date;

  GetDailyScheduleService(this.date) : assert(date != null);

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl +
        'therapist/api/v1/connect/schedule/patient/${date.year}/${date.month}/${date.day}?zone_offset=${date.timeZoneOffset.inMinutes}';
  }

  @override
  List<Schedule> success(body) {
    return _success(body);
  }
}

class GetWeeklySchedulesService extends BaseService<List<Schedule>> {
  final DateTime date;

  GetWeeklySchedulesService(this.date) : assert(date != null);

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    var mon = date.weekStart;
    return baseUrl +
        'therapist/api/v1/connect/schedule/patient/weekly/${mon.year}/${mon.month}/${mon.day}?zone_offset=${mon.timeZoneOffset.inMinutes}';
  }

  @override
  List<Schedule> success(body) {
    return _success(body);
  }
}

class GetUpcomingSchedulesService extends BaseService<List<Schedule>> {
  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl +
        'therapist/api/v1/connect/schedule/patient/upcoming?zone_offset=${DateTime.now().timeZoneOffset.inMinutes}';
  }

  @override
  List<Schedule> success(body) {
    return _success(body);
  }
}

List<Schedule> _success(body) {
  List<Schedule> schedules = [];

  if (body is List) {
    for (var schedule in body) {
      schedules.add(Schedule.fromJson(schedule));
    }
  }

  return schedules;
}

class GetPossibleTimeSlotsService extends BaseService<List<TimeSlot>> {
  final DateTime date;

  GetPossibleTimeSlotsService(this.date);

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl +
        'therapist/api/v1/connect/workinghours/therapist/${date.year}/${date.month}/${date.day}?zone_offset=${date.timeZoneOffset.inMinutes}';
  }

  @override
  List<TimeSlot> success(body) {
    List<TimeSlot> ret = [];

    if (body == null) {
      return ret;
    }

    for (var timeSlot in body) {
      ret.add(TimeSlot.fromJson(timeSlot));
    }

    return ret;
  }
}

class GetScheduleDetailService extends BaseService<Schedule> {
  final String id;

  GetScheduleDetailService(this.id);

  @override
  Future<http.Response> request() async {
    return await fetchGet();
  }

  @override
  setUrl() {
    return baseUrl + 'therapist/api/v1/connect/schedule/$id';
  }

  @override
  Schedule success(body) {
    return Schedule.fromJson(body);
  }
}
