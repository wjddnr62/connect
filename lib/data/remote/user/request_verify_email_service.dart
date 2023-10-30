import 'package:connect/data/remote/base_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RequestVerifyEmailService extends BaseService<String> {
  final email;
  final uuid;

  RequestVerifyEmailService({
    @required this.email,
    this.uuid,
  }) : super(withAccessToken: false);

  @override
  Future<http.Response> request() async {
    return await fetchGet();
  }

  @override
  String setUrl() {
    var ret = baseUrl +
        'user/api/v1/users/email/verify/$email?uuid=$uuid&from=CONNECT';
    return ret;
  }

  @override
  String success(body) {
    return body['token'];
  }
}
