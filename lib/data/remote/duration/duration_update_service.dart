import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class DurationUpdateService extends BaseService {
  final String date;

  DurationUpdateService({this.date});

  @override
  Future<Response> request() async {
    return await fetchPut(
        body: jsonEncode({'durationDate': date, 'addDurationMin': "1"}));
  }

  @override
  setUrl() {
    return '${baseUrl}connect/api/v1/durationLog';
  }

  @override
  success(body) {
    return true;
  }
}
