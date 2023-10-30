import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/tracker_goal.dart';
import 'package:http/src/response.dart';

class TrackerPostGoalService extends BaseService {
  final TrackerGoal trackerGoal;

  TrackerPostGoalService({this.trackerGoal});

  @override
  Future<Response> request() {
    // TODO: implement request
    return fetchPost(body: jsonEncode(trackerGoal.toJson()));
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}connect/api/v1/tracking/goal';
  }

  @override
  success(body) {
    // TODO: implement success
    return body;
  }
}
