import 'package:connect/models/goal.dart';
import 'package:http/src/response.dart';

import '../base_service.dart';

class GoalDataGetService extends BaseService<Goal> {
  GoalDataGetService() : super(withAccessToken: false);

  @override
  Future<Response> request() async => fetchGet();

  @override
  setUrl() => baseUrl + 'connect/api/v1/servey';

  @override
  Goal success(body) {
    Goal goal = Goal.fromJson(body);

    return goal;
  }
}
