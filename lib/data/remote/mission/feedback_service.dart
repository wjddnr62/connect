import 'package:connect/data/remote/base_service.dart';
import 'package:http/http.dart';

class FeedbackService extends BaseService<String> {
  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl + 'connect/api/v1/mission/currentStatus';
  }

  @override
  String success(body) {
    if (body == null) {
      return 'No message yet.';
    }

    return body['message'];
  }
}
