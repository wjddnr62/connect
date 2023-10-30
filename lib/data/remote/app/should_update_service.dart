import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class ShouldUpdateService extends BaseService<bool> {
  ShouldUpdateService({bool withAccessToken = false})
      : super(withAccessToken: withAccessToken);

  @override
  Future<Response> request() => fetchGet();

  @override
  setUrl() => baseUrl + 'connect/api/v1/app/version?version=$gVersion';

  @override
  bool success(body) => body;
}
