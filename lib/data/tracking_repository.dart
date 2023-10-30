import 'package:connect/data/remote/tracker/tracker_get_achieve_service.dart';
import 'package:connect/data/remote/tracker/tracker_get_goal_service.dart';
import 'package:connect/data/remote/tracker/tracker_get_graph_service.dart';
import 'package:connect/data/remote/tracker/tracker_get_sample_service.dart';
import 'package:connect/data/remote/tracker/tracker_get_setting_list_service.dart';
import 'package:connect/data/remote/tracker/tracker_get_tracking_service.dart';
import 'package:connect/data/remote/tracker/tracker_post_goal_service.dart';
import 'package:connect/data/remote/tracker/tracker_put_goal_service.dart';
import 'package:connect/data/remote/tracker/tracker_put_service.dart';
import 'package:connect/models/tracker_goal.dart';
import 'package:connect/models/tracking.dart';

class TrackingRepository {
  static Future<dynamic> trackerGetGoal(String date) =>
      TrackerGetGoalService(date: date).start();

  static Future<dynamic> trackerGetSample(int scaleInfo, int scaleDetailInfo) =>
      TrackerGetSampleService(
              scaleInfo: scaleInfo, scaleDetailInfo: scaleDetailInfo)
          .start();

  static Future<dynamic> trackerGetSettingList() =>
      TrackerGetSettingListService().start();

  static Future<dynamic> trackerPostGoal(TrackerGoal trackerGoal) =>
      TrackerPostGoalService(trackerGoal: trackerGoal).start();

  static Future<dynamic> trackerPut(Tracking tracking, String dateTime) =>
      TrackerPutService(tracking: tracking, dateTime: dateTime).start();

  static Future<dynamic> trackerGetTracking(String date) =>
      TrackerGetTrackingService(date: date).start();

  static Future<dynamic> trackerPutGoal(GoalTracking goalTracking, String id) =>
      TrackerPutGoalService(goalTracking: goalTracking, id: id).start();

  static Future<dynamic> trackerGetGraph(String date) =>
      TrackerGetGraphService(date: date).start();

  static Future<dynamic> trackerGetAchieve(String date) =>
      TrackerGetAchieveService(date: date).start();
}
