import 'package:connect/data/evaluation_repository.dart';
import 'package:connect/data/mission_repository.dart';
import 'package:connect/data/remote/mission/mission_playlog_service.dart';
import 'package:connect/data/schedule_repository.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/missions.dart';
import 'package:connect/models/schedule.dart';
import 'package:connect/utils/extensions.dart';
import 'package:flutter/foundation.dart';

import 'chat_repository.dart';

class ContentsRepository with ChangeNotifier {
  final Map<String, List<Mission>> _missions = {};

  final Map<String, List<Schedule>> _schedules = {};

  Map<String, List<Mission>> get missions => _missions;

  Map<String, List<Schedule>> get schedules => _schedules;

  clearData() {
    _missions.clear();
    _schedules.clear();
  }

  needToUpdateSeverity() async {
    var res = await EvaluationRepository.isCompleteEvaluation();

    if (res == null) {
      return null;
    }

    if (res is ServiceError) {
      return res;
    }

    if (res is Mission) {
      if (res.completed) {
        return null;
      }

      missions.addAll({
        DateTime.now().isoYYYYMMDD: [res]
      });

      notifyListeners();
      return res;
    }
  }

  getDailyMissions({DateTime date}) async {
    var res = await MissionRepository.getDailyMissions(date: date);

    if (res is List<Mission>) {
      _missions.addAll({date.isoYYYYMMDD: res});
    }
  }

  Future<void> getWeeklyMissions({bool update, DateTime date}) async {
    var start = date.weekStart;

    if (!update && missions.containsKey(start.isoYYYYMMDD)) {
      return;
    }

    Map<String, List<Mission>> m = {};

    /// create missions for the week start from 'start'
    for (int i = 0; i < 7; i++) {
      m.addAll({start.add(Duration(days: i)).isoYYYYMMDD: []});
    }

    var res = await MissionRepository.getWeeklyMissions(date: date);

    if (res is ServiceError) {
      _missions.addAll(m);
      return;
    }

    _missions.addAll(res);
  }

  Future<dynamic> getDailySchedules({DateTime date}) async {
    var res = await ScheduleRepository.getSchedule(date: date);
    if (res is ServiceError) {
      return res;
    }

    List<Schedule> sch = _schedules[date.isoYYYYMMDD];

    if (sch == null) {
      sch = [];
      _schedules.addAll({date.isoYYYYMMDD: sch});
    } else {
      sch.clear();
    }

    sch.addAll(res);
  }

  /* Future<void> getWeeklySchedules({bool update, DateTime date}) async {
    if (!update && schedules.containsKey(date.isoYYYYMMDD)) {
      return;
    }

    var res = await ScheduleRepository.getWeeklySchedules(date: date);

    if (res is List<Schedule>) {
      for (var sch in res) {
        List<Schedule> list = _schedules[sch.start.isoYYYYMMDD] ?? [];
        list.add(sch);
        _schedules.addAll({sch.start.isoYYYYMMDD: list});
      }
    }
  }*/

  getWeeklyData({bool update, DateTime date}) async {
    await Future.wait([
      getWeeklyMissions(update: update, date: date),
      // getWeeklySchedules(update: update, date: date)
    ]);

    notifyListeners();
  }

  getAllData({DateTime date, DateTime from, DateTime to}) async {
    await Future.wait([
      getWeeklyMissions(update: true, date: date),
      // getWeeklySchedules(update: true, date: date)
    ]);
    notifyListeners();
  }

  bool hasData(DateTime date) {
    if (!_missions.containsKey(date.isoYYYYMMDD)) {
      return false;
    }

    return true;
  }

  Future<bool> doMission({DateTime date, String id}) async {
    var res = await MissionRepository.complete(id);

    if (res is ServiceError) {
      return false;
    }

    for (Mission m in _missions[date.isoYYYYMMDD]) {
      if (m.id == id) {
        m.completed = true;
        break;
      }
    }

    notifyListeners();

    return true;
  }

  Future<bool> undoMission({DateTime date, String id}) async {
    var res = await MissionRepository.undo(id);

    if (res is ServiceError) {
      return false;
    }

    for (Mission m in _missions[date.isoYYYYMMDD]) {
      if (m.id == id) {
        m.completed = false;
        break;
      }
    }

    notifyListeners();

    return true;
  }

  Future<dynamic> registerVideoCall(
      {DateTime date, String start, String end}) async {
    var res = await ChatRepository.registerVideoCall(date, start, end);

    if (res is ServiceError) {
      return res;
    }

    await getDailySchedules(date: date);

    notifyListeners();

    return res;
  }

  Future<dynamic> cancelVideoCall({Schedule schedule}) async {
    var res = await ChatRepository.requestCancelVideoCall(schedule: schedule);

    if (res is ServiceError) {
      return res;
    }

    await getDailySchedules(date: schedule.start);

    notifyListeners();

    return res;
  }

}
