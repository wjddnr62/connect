import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class DiaryUserWriteCheckService extends BaseService {
  final String date;

  DiaryUserWriteCheckService({this.date});

  @override
  Future<Response> request() async {
    return await fetchGet();
  }

  @override
  setUrl() {
    return '${baseUrl}connect/api/v1/diary/user/me/exists/$date';
  }

  @override
  success(body) {
    return body;
  }
}
