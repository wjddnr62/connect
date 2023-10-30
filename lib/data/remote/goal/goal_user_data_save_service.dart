import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class GoalUserDataSaveService extends BaseService {
  final List<String> serveys;

  GoalUserDataSaveService({this.serveys}) : super(withAccessToken: false);

  @override
  Future<Response> request() async {
    return await fetchPost(body: jsonEncode({'serveys': serveys}));
  }

  @override
  setUrl() {
    return '${baseUrl}connect/api/v1/servey/user';
  }

  @override
  success(body) {
    return body;
  }
}
