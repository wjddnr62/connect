import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart' as http;

class AllReadHistoryService extends BaseService<bool> {
  @override
  Future<http.Response> request() async {
    return fetchPut();
  }

  @override
  setUrl() {
    return '${baseUrl}push/api/v1/auth/history/read_all';
  }

  @override
  bool success(body) {
    return true;
  }
}
