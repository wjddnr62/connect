import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/diary.dart';
import 'package:http/src/response.dart';

class DiaryGetUserDataService extends BaseService<List<dynamic>> {

  final String date;

  DiaryGetUserDataService({this.date});

  @override
  Future<Response> request() async {
    return await fetchGet();
  }

  @override
  setUrl() {
    return '${baseUrl}connect/api/v1/diary/user/me/$date';
  }

  @override
  List<dynamic> success(body) {
    return body;
  }
}
