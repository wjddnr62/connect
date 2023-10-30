import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/rank.dart';
import 'package:http/src/response.dart';

class RankGetDataMeService extends BaseService<dynamic> {
  final String date;

  RankGetDataMeService({this.date});

  @override
  Future<Response> request() async {
    return await fetchGet();
  }

  @override
  setUrl() {
    return '${baseUrl}connect/api/v1/rank/user/$date';
  }

  @override
  dynamic success(body) {
    if (body != null) {
      return RankData.fromJson(body);
    } else {
      return null;
    }
  }
}