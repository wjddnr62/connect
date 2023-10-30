import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/goal.dart';
import 'package:http/src/response.dart';

class GoalUserDataGetService extends BaseService<dynamic> {
  @override
  Future<Response> request() async {
    // TODO: implement request
    return fetchGet();
  }

  @override
  setUrl() {
    return '${baseUrl}connect/api/v1/servey/user';
  }

  @override
  dynamic success(body) {
    return body;
  }
}
