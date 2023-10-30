import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/auth.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:http/http.dart' as http;

import '../../../connect_config.dart';

class LoginService extends BaseService<Auth> {
  final email;
  final password;

  LoginService({
    @required this.email,
    @required this.password,
  }) : super(withAccessToken: false, jsonContentType: false);

  @override
  Future<http.Response> request() async {
    return await fetchPost(
        body: <String, String>{'username': email, 'password': password});
  }

  @override
  Auth success(body) {
    Log.d('LoginService', 'body = $body');
    Auth ret = Auth.fromJson(body);
    return ret;
  }

  @override
  String setUrl() {
    return baseUrl +
        'uaa/oauth/token?client_id=connect&response_type=code&grant_type=password&scope=ui';
  }
}
