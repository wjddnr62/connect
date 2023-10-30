import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class SocialExistService extends BaseService<bool> {
  final sid;

  SocialExistService({@required this.sid}) : super(withAccessToken: false);

  @override
  Future<Response> request() async {
    return await fetchGet();
  }

  @override
  setUrl() {
    return baseUrl + 'user/api/v1/users/social/exist/$sid';
  }

  @override
  bool success(body) {
    return body;
  }
}
