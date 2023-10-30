import 'package:connect/models/tracking.dart';
import 'package:http/src/response.dart';

import '../base_service.dart';

class TrackerPutGoalService extends BaseService {

  final GoalTracking goalTracking;
  final String id;


  TrackerPutGoalService({this.goalTracking, this.id});

  @override
  Future<Response> request() {
    // TODO: implement request
    return fetchPut(body: jsonEncode(goalTracking.toJson()));
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}connect/api/v1/tracking/goal/$id';
  }

  @override
  success(body) {
    // TODO: implement success
    return body;
  }

}