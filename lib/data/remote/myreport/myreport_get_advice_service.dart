import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class MyReportGetAdviceService extends BaseService<dynamic> {
  @override
  Future<Response> request() {
    // TODO: implement request
    return fetchGet();
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}connect/api/v1/advice';
  }

  @override
  success(body) {
    // TODO: implement success
    return body['message'];
  }
}
