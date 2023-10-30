import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/tracker_goal.dart';
import 'package:http/src/response.dart';

class TrackerGetGoalService extends BaseService<TrackerGoal> {
  final String date;

  TrackerGetGoalService({this.date});

  @override
  Future<Response> request() {
    // TODO: implement request
    return fetchGet();
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}connect/api/v1/tracking/goal/$date';
  }

  @override
  TrackerGoal success(body) {
    // TODO: implement success
    return TrackerGoal.fromJson(body);
  }
}
