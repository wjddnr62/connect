

import 'package:connect/data/remote/base_service.dart';
import 'package:http/http.dart';

class UnReadCheckService extends BaseService {
  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl + 'push/api/v1/auth/unread';
  }

  @override
  success(body) {
    return body['unread_count'];
  }

}