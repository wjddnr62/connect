import 'package:connect/data/local/app_dao.dart';
import 'package:connect/models/mission_historys.dart';
import 'package:connect/models/missions.dart';
import 'package:connect/utils/extensions.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:http/http.dart' as http;

import '../base_service.dart';

class GetMissionsService extends BaseService<Map<String, List<Mission>>> {
  final DateTime startDate;
  final DateTime endDate;

  GetMissionsService({@required this.startDate, @required this.endDate});

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  String setUrl() {
    Log.d('GetMissionService', 'start:${startDate.isoYYYYMMDD}');
    Log.d('GetMissionService', 'end:${endDate.isoYYYYMMDD}');

    return baseUrl +
        'connect/api/v2/missions?start=${startDate.isoYYYYMMDD}&end=${endDate.isoYYYYMMDD}';
  }

  @override
  Map<String, List<Mission>> success(body) {
    Map<String, List<Mission>> missions = {};

    for (var data in body) {
      String dateKey = data['date'] as String;

      if (!missions.containsKey(dateKey)) {
        missions.addAll({dateKey: []});
      }

      List<Mission> ms = missions[dateKey];

      for (var missionJson in data['missions']) {
        Mission mission = Mission.fromJson(missionJson);

        /// add only valid missions that have valid url except ACTIVITY mission
        switch (mission.type) {
          case MISSION_TYPE_EXERCISE_BASICS:
          case MISSION_TYPE_VIDEO:
          case MISSION_TYPE_CARD_READING:
            // if (mission.meta == null ||
            //     mission.meta.links == null ||
            //     mission.meta.links.isEmpty) {
            //   break;
            // }
            ms.add(mission);
            break;
          case MISSION_TYPE_ACTIVITY:
          default:
            ms.add(mission);
        }
      }
    }

    return missions;
  }
}

class GetMissionsRenewalService extends BaseService<MissionRenewal> {
  final DateTime startDate;
  final DateTime endDate;

  GetMissionsRenewalService({@required this.startDate, @required this.endDate});

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  String setUrl() {
    Log.d('GetMissionService', 'start:${startDate.isoYYYYMMDD}');
    Log.d('GetMissionService', 'end:${endDate.isoYYYYMMDD}');

    return baseUrl +
        'connect/api/v2/missions?start=${startDate.isoYYYYMMDD}&end=${endDate.isoYYYYMMDD}';
  }

  @override
  MissionRenewal success(body) {
    if (body.isEmpty) {
      return null;
    }
    return MissionRenewal.fromJson(body[0]);
  }
}

class GetMissionDetailService extends BaseService<MissionDetail> {
  final String missionId;

  GetMissionDetailService({@required this.missionId});

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  String setUrl() {
    return baseUrl + 'connect/api/v2/mission?mission_id=$missionId';
  }

  @override
  MissionDetail success(body) {
    MissionDetail missionDetail = MissionDetail.fromJson(body);
    return missionDetail;
  }
}

class ActionService extends BaseService<bool> {
  final String missionId;
  final bool completed;

  ActionService({this.missionId, this.completed});

  @override
  Future<http.Response> request() async {
    return fetchPut();
  }

  @override
  setUrl() {
    return baseUrl + 'connect/api/v2/mission/$missionId?completed=$completed';
  }

  @override
  bool success(body) {
    return body;
  }
}

class PerformHistoryService extends BaseService<List<dynamic>> {
  final DateTime dateTime;
  final int userId;

  PerformHistoryService({this.dateTime, this.userId});

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl +
        'connect/api/v2/mission/statistics/performHistory?user_id=$userId&start=${dateTime.isoYYYYMMDD}&end=${dateTime.isoYYYYMMDD}';
  }

  @override
  List<dynamic> success(body) {
    return body;
  }
}

class PerformPeriodService extends BaseService<List<PerformHistory>> {
  final String startDate;
  final String endDate;

  PerformPeriodService({this.startDate, this.endDate});

  @override
  Future<http.Response> request() {
    // TODO: implement request
    return fetchGet();
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}connect/api/v2/mission/statistics/performPeriod?start=$startDate&end=$endDate';
  }

  @override
  List<PerformHistory> success(body) {
    // TODO: implement success
    List<PerformHistory> performHistory = List();
    for (int i = 0; i < body.length; i++) {
      performHistory.add(PerformHistory.fromJson(body[i]));
    }
    return performHistory;
  }
}
