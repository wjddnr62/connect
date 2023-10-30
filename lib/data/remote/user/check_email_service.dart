import 'package:connect/data/remote/base_service.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:http/http.dart' as http;

import '../../../connect_config.dart';

class CheckEmailService extends BaseService<bool> {
  final email;

  CheckEmailService({@required this.email}) : super(withAccessToken: false);

  @override
  Future<http.Response> request() async {
    return await fetchGet();
  }

  @override
  bool success(body) {
    Log.d('CheckEmailService', 'body = $body');
    return body;
  }

  @override
  String setUrl() {
    return baseUrl + 'user/api/v1/users/email/exist/$email?type=patient';
  }
}
