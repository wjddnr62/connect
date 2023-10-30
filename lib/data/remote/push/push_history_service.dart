import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/push_history.dart';
import 'package:http/http.dart' as http;

class PushHistoryService extends BaseService<PushHistoryList> {
  final int page;
  final int size;

  PushHistoryService(this.page, this.size);

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return "${baseUrl}push/api/v1/auth/history?page=$page&size=$size&service_name=connect";
  }

  @override
  PushHistoryList success(body) {
    return PushHistoryList.fromJson(body);
  }
}
