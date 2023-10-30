import 'package:connect/data/remote/base_service.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RegisterUserService extends BaseService<bool> {
  final email;
  final password;
  final role;
  final emailVerificationToken;
  final String name;
  final String birthday;

  RegisterUserService({
    @required this.email,
    @required this.password,
    @required this.role,
    @required this.emailVerificationToken,
    @required this.name,
    this.birthday
  }) : super(withAccessToken: false);

  @override
  Future<http.Response> request() async {
    Map<String, dynamic> body = {
      'email': email,
      'password': password,
      'type': role,
      'name': name ?? "",
      'birthday': birthday,
      'zone_offset': DateTime.now().timeZoneOffset.inMinutes.toString()
      // 'token': emailVerificationToken,
    };

    Log.d('RegisterUserService', 'body = ${jsonEncode(body)}');
    return fetchPost(
      body: jsonEncode(body),
    );
  }

  @override
  setUrl() {
    return baseUrl + 'user/api/v1/users/registerConnect';
  }

  @override
  bool success(body) {
    return body;
  }
}
