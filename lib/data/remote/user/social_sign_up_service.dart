import 'package:connect/data/remote/base_service.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:http/src/response.dart';

class SocialSignUpService extends BaseService<bool> {
  final role;
  final email;
  final password;
  final socialInfo;

  SocialSignUpService(
      {@required this.role,
      @required this.email,
      @required this.password,
      @required this.socialInfo})
      : super(withAccessToken: false);

  @override
  Future<Response> request() async {
    Map<String, dynamic> body = {
      'type': role,
      'email': email,
      'password': password,
      'social_info': socialInfo,
      'zone_offset': DateTime.now().timeZoneOffset.inMinutes.toString()
    };

    Log.d('SocialSignUpService', 'body = ${jsonEncode(body)}');
    return fetchPost(body: jsonEncode(body));
  }

  @override
  setUrl() {
    return baseUrl + 'user/api/v1/users/registerWithSocial';
  }

  @override
  bool success(body) {
    return body;
  }
}
