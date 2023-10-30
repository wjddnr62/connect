import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class DurationRegistService extends BaseService {
  final String date;

  DurationRegistService({this.date});

  @override
  Future<Response> request() async {
    return await fetchPost(body: jsonEncode({'durationDate': date}));
  }

  @override
  setUrl() {
    return '${baseUrl}connect/api/v1/durationLog';
  }

  @override
  success(body) {
    return body;
  }
}
