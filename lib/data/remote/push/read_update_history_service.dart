import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/push_history.dart';
import 'package:http/src/response.dart' as http;

class ReadUpdateHistoryService extends BaseService<bool> {
  PushHistory history;

  ReadUpdateHistoryService(this.history);

  @override
  Future<http.Response> request() async {
    return fetchPut(body: json.encode({'is_read': true}));
  }

  @override
  setUrl() {
    return '${baseUrl}push/api/v1/auth/history/${history.notify.historyId}';
  }

  @override
  bool success(body) {
    return true;
  }
}
