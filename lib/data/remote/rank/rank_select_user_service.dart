import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/rank.dart';
import 'package:http/src/response.dart';

class RankSelectUserService extends BaseService<RankData> {
  final String date;

  RankSelectUserService({this.date}) : super(withAccessToken: false);

  @override
  Future<Response> request() async {
    return await fetchGet();
  }

  @override
  setUrl() {
    // return '${baseUrl}connect/api/v1/rank/user/$date/$name?';
  }

  @override
  RankData success(body) {
    return body;
  }
}
