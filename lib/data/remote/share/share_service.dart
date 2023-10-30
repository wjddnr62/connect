import 'package:http/src/response.dart';

import '../base_service.dart';

class GetShareContentService extends BaseService<String> {
  @override
  Future<Response> request() async => fetchGet();

  @override
  setUrl() => baseUrl + 'connect/api/v1/share/contents';

  @override
  String success(body) => body['message'];

}