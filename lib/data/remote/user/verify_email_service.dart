import 'package:connect/data/remote/base_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class VerifyEmailService extends BaseService<bool> {
  final token;

  VerifyEmailService({
    @required this.token,
  }) : super(withAccessToken: false);

  @override
  Future<http.Response> request() async {
    return await fetchGet();
  }

  @override
  String setUrl() {
    var ret = baseUrl + 'user/api/v1/users/email/verified?token=$token';
    return ret;
  }

  @override
  bool success(body) {
    return body;
  }
}
