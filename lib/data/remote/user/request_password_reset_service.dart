import 'package:connect/data/remote/base_service.dart';
import 'package:http/http.dart' as http;

class RequestPasswordResetService extends BaseService<bool> {
  final email;

  RequestPasswordResetService({
    @required this.email,
    bool withAccessToken,
  }) : super(withAccessToken: false);

  @override
  Future<http.Response> request() async {
    return fetchPost();
  }

  @override
  setUrl() {
    return baseUrl + 'user/api/v1/users/resetPassword/$email';
  }

  @override
  bool success(body) {
    return body;
  }
}
