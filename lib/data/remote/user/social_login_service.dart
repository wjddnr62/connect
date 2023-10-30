import 'package:connect/models/auth.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:http/src/response.dart';

import '../base_service.dart';

class SocialLoginService extends BaseService<Auth> {
  final sid;

  SocialLoginService({@required this.sid})
      : super(withAccessToken: false, jsonContentType: false);

  @override
  Future<Response> request() async {
    return await fetchPost(body: {
      'client_id': 'connect',
      'response_type': 'code',
      'grant_type': 'social_login',
      'scope': 'ui',
      'sid': sid
    });
  }

  @override
  setUrl() {
    return baseUrl + 'uaa/oauth/token';
  }

  @override
  Auth success(body) {
    Log.d('SocialLoginService', 'body = $body');
    return Auth.fromJson(body);
  }
}
