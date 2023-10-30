import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/rank.dart';
import 'package:http/src/response.dart';

class RankGetDataService extends BaseService<Rank> {
  final String date;

  RankGetDataService({this.date}) : super(withAccessToken: false);

  @override
  Future<Response> request() async {
    return await fetchGet();
  }

  @override
  setUrl() {
    return '${baseUrl}connect/api/v1/rank/$date';
  }

  @override
  Rank success(body) {
    return Rank.fromJson(body);
  }
}
